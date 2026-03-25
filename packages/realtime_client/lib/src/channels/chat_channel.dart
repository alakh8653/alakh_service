import '../realtime_service.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        id: map['id'] as String,
        roomId: map['roomId'] as String,
        senderId: map['senderId'] as String,
        content: map['content'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

class ChatChannel {
  ChatChannel({required RealtimeService realtimeService})
      : _service = realtimeService;

  final RealtimeService _service;

  static const String _messageEvent = 'chat:message';
  static const String _sendMessageEvent = 'chat:send';
  static const String _joinRoomEvent = 'chat:join';
  static const String _leaveRoomEvent = 'chat:leave';

  Stream<ChatMessage> get messages => _service.on<ChatMessage>(
        _messageEvent,
        (data) => ChatMessage.fromMap(data as Map<String, dynamic>),
      );

  void joinRoom(String roomId) =>
      _service.emit(_joinRoomEvent, {'roomId': roomId});

  void leaveRoom(String roomId) =>
      _service.emit(_leaveRoomEvent, {'roomId': roomId});

  void sendMessage(String roomId, String content) =>
      _service.emit(_sendMessageEvent, {'roomId': roomId, 'content': content});

  void unsubscribe() => _service.off(_messageEvent);
}
