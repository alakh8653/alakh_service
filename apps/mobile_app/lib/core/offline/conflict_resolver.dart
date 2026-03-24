/// Conflict resolution strategies for sync conflicts.
///
/// When the same resource has been modified both locally and remotely while
/// offline, one of these strategies is applied to resolve the conflict.
library conflict_resolver;

import '../utils/logger.dart';

// ── Conflict model ────────────────────────────────────────────────────────────

/// Represents a detected synchronisation conflict.
class SyncConflict {
  const SyncConflict({
    required this.resourceId,
    required this.resourceType,
    required this.localVersion,
    required this.remoteVersion,
    required this.localUpdatedAt,
    required this.remoteUpdatedAt,
  });

  /// The identifier of the conflicting resource.
  final String resourceId;

  /// The resource type (e.g. `'booking'`, `'profile'`).
  final String resourceType;

  /// The locally modified version.
  final Map<String, dynamic> localVersion;

  /// The version fetched from the server.
  final Map<String, dynamic> remoteVersion;

  /// Timestamp of the local modification.
  final DateTime localUpdatedAt;

  /// Timestamp of the remote modification.
  final DateTime remoteUpdatedAt;
}

/// The resolved outcome of a [SyncConflict].
class ConflictResolution {
  const ConflictResolution({
    required this.resolvedData,
    required this.strategy,
  });

  /// The data to persist (either local, remote, or a merge).
  final Map<String, dynamic> resolvedData;

  /// The strategy that produced this resolution.
  final ConflictStrategy strategy;
}

/// Available conflict resolution strategies.
enum ConflictStrategy {
  /// Always use the server version.
  serverWins,

  /// Always use the local (client) version.
  clientWins,

  /// Use whichever version has the most recent timestamp.
  lastWriteWins,

  /// Attempt a field-level merge (non-conflicting fields from both sides).
  merge,

  /// Flag for manual user resolution (not resolved automatically).
  manual,
}

// ── Resolver ──────────────────────────────────────────────────────────────────

/// Abstract interface for conflict resolution.
abstract class ConflictResolver {
  /// Resolves [conflict] and returns the winning [ConflictResolution].
  ConflictResolution resolve(SyncConflict conflict);
}

/// Always chooses the server (remote) version.
class ServerWinsResolver implements ConflictResolver {
  const ServerWinsResolver();

  @override
  ConflictResolution resolve(SyncConflict conflict) => ConflictResolution(
        resolvedData: conflict.remoteVersion,
        strategy: ConflictStrategy.serverWins,
      );
}

/// Always chooses the local (client) version.
class ClientWinsResolver implements ConflictResolver {
  const ClientWinsResolver();

  @override
  ConflictResolution resolve(SyncConflict conflict) => ConflictResolution(
        resolvedData: conflict.localVersion,
        strategy: ConflictStrategy.clientWins,
      );
}

/// Picks whichever version has the later `updated_at` timestamp.
class LastWriteWinsResolver implements ConflictResolver {
  const LastWriteWinsResolver();

  @override
  ConflictResolution resolve(SyncConflict conflict) {
    final useLocal =
        conflict.localUpdatedAt.isAfter(conflict.remoteUpdatedAt);
    return ConflictResolution(
      resolvedData:
          useLocal ? conflict.localVersion : conflict.remoteVersion,
      strategy: ConflictStrategy.lastWriteWins,
    );
  }
}

/// Performs a shallow field-level merge.
///
/// - Fields present only in the local version are kept.
/// - Fields present only in the remote version are kept.
/// - Fields present in both are resolved by last-write-wins.
class MergeResolver implements ConflictResolver {
  const MergeResolver();

  final _log = const _StaticLog();

  @override
  ConflictResolution resolve(SyncConflict conflict) {
    final merged = <String, dynamic>{...conflict.remoteVersion};

    for (final entry in conflict.localVersion.entries) {
      if (!merged.containsKey(entry.key)) {
        // Local-only field – keep it
        merged[entry.key] = entry.value;
      } else if (conflict.localUpdatedAt.isAfter(conflict.remoteUpdatedAt)) {
        // Both sides modified – local wins if newer
        merged[entry.key] = entry.value;
      }
    }

    _log.d('Merge resolved: ${conflict.resourceId}');
    return ConflictResolution(
      resolvedData: merged,
      strategy: ConflictStrategy.merge,
    );
  }
}

/// Composite resolver that delegates to different strategies per resource type.
class StrategyMapResolver implements ConflictResolver {
  const StrategyMapResolver({
    required this.strategyMap,
    required this.defaultResolver,
  });

  /// Maps resource types to their preferred [ConflictResolver].
  final Map<String, ConflictResolver> strategyMap;

  /// Fallback resolver for resource types not listed in [strategyMap].
  final ConflictResolver defaultResolver;

  @override
  ConflictResolution resolve(SyncConflict conflict) {
    final resolver =
        strategyMap[conflict.resourceType] ?? defaultResolver;
    return resolver.resolve(conflict);
  }
}

class _StaticLog {
  const _StaticLog();
  void d(String msg) {
    // ignore: avoid_print
    print('[ConflictResolver] $msg');
  }
}
