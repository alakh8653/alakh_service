/// Notification types supported by the AlakhService platform.
enum NotificationPayloadType {
  booking,
  chat,
  payment,
  queue,
  dispatch,
  promotion,
  system,
}

/// Typed representation of a push or local notification payload.
///
/// Parsed from FCM [RemoteMessage.data] for consistent handling across
/// foreground, background, and terminated app states.
class NotificationPayload {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String? action;

  const NotificationPayload({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.imageUrl,
    this.action,
  });

  /// A sentinel empty payload — used as the initial value of the stream.
  static const NotificationPayload _empty = NotificationPayload(
    id: '',
    type: '',
    title: '',
    body: '',
    data: {},
  );

  /// Returns an empty payload. Useful as a null-object / stream seed.
  static NotificationPayload empty() => _empty;

  /// Whether this payload carries no meaningful data.
  bool get isEmpty => id.isEmpty && title.isEmpty;

  /// Parses the [type] string into a typed [NotificationPayloadType].
  NotificationPayloadType get notificationType {
    switch (type) {
      case 'booking':
        return NotificationPayloadType.booking;
      case 'chat':
        return NotificationPayloadType.chat;
      case 'payment':
        return NotificationPayloadType.payment;
      case 'queue':
        return NotificationPayloadType.queue;
      case 'dispatch':
        return NotificationPayloadType.dispatch;
      case 'promotion':
        return NotificationPayloadType.promotion;
      default:
        return NotificationPayloadType.system;
    }
  }

  /// Constructs a [NotificationPayload] from a raw data map.
  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    return NotificationPayload(
      id: map['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: map['type'] as String? ?? 'system',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      data: Map<String, dynamic>.from(map),
      imageUrl: map['image_url'] as String?,
      action: map['action'] as String?,
    );
  }

  @override
  String toString() =>
      'NotificationPayload(id: $id, type: $type, title: $title)';
}
