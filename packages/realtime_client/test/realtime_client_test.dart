import 'package:realtime_client/realtime_client.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeConfig', () {
    test('default values', () {
      final c = RealtimeConfig(url: 'ws://localhost:4000/socket');
      expect(c.maxReconnectAttempts, 5);
      expect(c.heartbeatInterval, const Duration(seconds: 30));
    });

    test('uri appends params', () {
      final c = RealtimeConfig(
          url: 'ws://localhost/socket', params: {'token': 'abc'});
      expect(c.uri.queryParameters['token'], 'abc');
    });
  });

  group('RealtimeMessage', () {
    test('fromJson/toJson roundtrip', () {
      final m = RealtimeMessage(
          event: 'test', topic: 'room:1', payload: {'k': 'v'}, ref: '1');
      expect(RealtimeMessage.fromJson(m.toJson()), equals(m));
    });

    test('null fields omitted from toJson', () {
      final m =
          RealtimeMessage(event: 'e', topic: 't', payload: {});
      expect(m.toJson().containsKey('ref'), isFalse);
    });
  });

  group('MessageSerializer', () {
    test('serialize/deserialize roundtrip', () {
      final s = MessageSerializer();
      final m = RealtimeMessage(
          event: 'test', topic: 'room:1', payload: {'x': 1}, ref: '5');
      expect(s.deserialize(s.serialize(m)), equals(m));
    });

    test('returns null for invalid JSON', () {
      expect(MessageSerializer().deserialize('bad'), isNull);
    });
  });

  group('RealtimeConnection', () {
    test('isConnected', () {
      const c =
          RealtimeConnection(status: RealtimeConnectionStatus.connected);
      expect(c.isConnected, isTrue);
    });
  });

  group('RealtimePresence', () {
    test('syncState and isOnline', () {
      final p = RealtimePresence();
      p.syncState({'u1': {'metas': [{}]}});
      expect(p.isOnline('u1'), isTrue);
      expect(p.count, 1);
    });

    test('syncDiff joins and leaves', () {
      final p = RealtimePresence();
      p.syncState({'u1': {'metas': [{}]}});
      p.syncDiff({'joins': {'u2': {'metas': [{}]}}, 'leaves': {'u1': {}}});
      expect(p.isOnline('u1'), isFalse);
      expect(p.isOnline('u2'), isTrue);
    });
  });
}
