/// Cache eviction policies and TTL configuration.
library cache_policy;

/// Defines how long a cache entry remains valid before it must be refreshed.
class CachePolicy {
  const CachePolicy({
    required this.ttl,
    this.staleWhileRevalidate = false,
    this.maxStaleAge,
  });

  /// Time-to-live – entries older than this are considered expired.
  final Duration ttl;

  /// If `true`, expired entries are returned immediately while a background
  /// refresh is triggered (stale-while-revalidate strategy).
  final bool staleWhileRevalidate;

  /// When [staleWhileRevalidate] is enabled, the maximum age beyond which
  /// stale entries are NOT returned (hard expiry).
  final Duration? maxStaleAge;

  // ── Common presets ────────────────────────────────────────────────────────

  /// No caching – always fetch fresh data.
  static const CachePolicy noCache = CachePolicy(ttl: Duration.zero);

  /// Very short cache – suitable for frequently changing data (30 seconds).
  static const CachePolicy veryShort =
      CachePolicy(ttl: Duration(seconds: 30));

  /// Short cache – suitable for semi-dynamic data (5 minutes).
  static const CachePolicy short = CachePolicy(ttl: Duration(minutes: 5));

  /// Medium cache – suitable for moderately stable data (30 minutes).
  static const CachePolicy medium = CachePolicy(ttl: Duration(minutes: 30));

  /// Long cache – suitable for relatively stable data (2 hours).
  static const CachePolicy long = CachePolicy(ttl: Duration(hours: 2));

  /// Very long cache – suitable for static/config data (24 hours).
  static const CachePolicy veryLong = CachePolicy(ttl: Duration(hours: 24));

  /// Permanent cache – never expires (cleared only on app update or logout).
  static const CachePolicy permanent =
      CachePolicy(ttl: Duration(days: 365));

  /// Stale-while-revalidate preset for lists (5-minute TTL, 1-hour max stale).
  static const CachePolicy staleList = CachePolicy(
    ttl: Duration(minutes: 5),
    staleWhileRevalidate: true,
    maxStaleAge: Duration(hours: 1),
  );

  /// Returns `true` if [cachedAt] + [ttl] < [now].
  bool isExpired(DateTime cachedAt, {DateTime? now}) {
    if (ttl == Duration.zero) return true;
    final expiry = cachedAt.add(ttl);
    return (now ?? DateTime.now()).isAfter(expiry);
  }

  /// Returns `true` when a stale entry should still be returned but
  /// refreshed in the background.
  bool isStaleButUsable(DateTime cachedAt, {DateTime? now}) {
    if (!staleWhileRevalidate) return false;
    if (!isExpired(cachedAt, now: now)) return false;
    if (maxStaleAge == null) return true;
    final hardExpiry = cachedAt.add(maxStaleAge!);
    return !(now ?? DateTime.now()).isAfter(hardExpiry);
  }

  @override
  String toString() =>
      'CachePolicy(ttl: $ttl, swr: $staleWhileRevalidate, maxStale: $maxStaleAge)';
}
