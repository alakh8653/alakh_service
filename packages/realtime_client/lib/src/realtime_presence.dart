import 'package:equatable/equatable.dart';

/// An entry in the presence state map.
class PresenceEntry extends Equatable {
  final String userId;
  final Map<String, dynamic> meta;
  final DateTime joinedAt;

  const PresenceEntry({
    required this.userId,
    required this.meta,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [userId, meta, joinedAt];
}

/// Tracks online presence of users in a channel.
class RealtimePresence {
  final Map<String, PresenceEntry> _state = {};

  Map<String, PresenceEntry> get state => Map.unmodifiable(_state);
  List<String> get onlineUsers => _state.keys.toList();
  int get count => _state.length;
  bool isOnline(String userId) => _state.containsKey(userId);

  void syncState(Map<String, dynamic> newState) {
    _state.clear();
    newState.forEach((userId, data) {
      final metas = (data as Map<String, dynamic>)['metas'] as List<dynamic>?;
      final meta = (metas?.isNotEmpty == true
          ? metas!.first as Map<String, dynamic>
          : <String, dynamic>{});
      _state[userId] =
          PresenceEntry(userId: userId, meta: meta, joinedAt: DateTime.now());
    });
  }

  void syncDiff(Map<String, dynamic> diff) {
    final joins = diff['joins'] as Map<String, dynamic>? ?? {};
    final leaves = diff['leaves'] as Map<String, dynamic>? ?? {};
    joins.forEach((userId, data) {
      final metas =
          ((data as Map<String, dynamic>)['metas'] as List<dynamic>?) ?? [];
      final meta = metas.isNotEmpty
          ? metas.first as Map<String, dynamic>
          : <String, dynamic>{};
      _state[userId] =
          PresenceEntry(userId: userId, meta: meta, joinedAt: DateTime.now());
    });
    for (final userId in leaves.keys) {
      _state.remove(userId);
    }
  }

  void clear() => _state.clear();
}
