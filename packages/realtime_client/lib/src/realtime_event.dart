/// Constants for real-time event types.
abstract class RealtimeEvent {
  static const String phxJoin = 'phx_join';
  static const String phxLeave = 'phx_leave';
  static const String phxReply = 'phx_reply';
  static const String phxError = 'phx_error';
  static const String phxClose = 'phx_close';
  static const String heartbeat = 'heartbeat';
  static const String message = 'new_message';
  static const String presence = 'presence_state';
  static const String presenceDiff = 'presence_diff';
  static const String join = 'join';
  static const String leave = 'leave';
  static const String error = 'error';
  static const String phoenixTopic = 'phoenix';
}
