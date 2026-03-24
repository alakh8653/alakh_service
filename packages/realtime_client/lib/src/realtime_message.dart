import 'package:equatable/equatable.dart';

/// A real-time message sent/received via WebSocket.
class RealtimeMessage extends Equatable {
  final String event;
  final String topic;
  final Map<String, dynamic> payload;
  final String? ref;
  final String? joinRef;

  const RealtimeMessage({
    required this.event,
    required this.topic,
    required this.payload,
    this.ref,
    this.joinRef,
  });

  factory RealtimeMessage.fromJson(Map<String, dynamic> json) {
    return RealtimeMessage(
      topic: json['topic'] as String? ?? '',
      event: json['event'] as String? ?? '',
      payload: (json['payload'] as Map<String, dynamic>?) ?? {},
      ref: json['ref'] as String?,
      joinRef: json['join_ref'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'event': event,
        'payload': payload,
        if (ref != null) 'ref': ref,
        if (joinRef != null) 'join_ref': joinRef,
      };

  @override
  List<Object?> get props => [event, topic, payload, ref, joinRef];

  @override
  String toString() =>
      'RealtimeMessage(topic: $topic, event: $event, ref: $ref)';
}
