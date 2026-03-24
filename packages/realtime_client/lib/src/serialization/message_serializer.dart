import 'dart:convert';
import '../realtime_message.dart';

/// Serializes/deserializes WebSocket messages.
class MessageSerializer {
  String serialize(RealtimeMessage message) => jsonEncode(message.toJson());

  RealtimeMessage? deserialize(String data) {
    try {
      return RealtimeMessage.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  RealtimeMessage? deserializeBytes(List<int> bytes) {
    try {
      return deserialize(utf8.decode(bytes));
    } catch (_) {
      return null;
    }
  }
}
