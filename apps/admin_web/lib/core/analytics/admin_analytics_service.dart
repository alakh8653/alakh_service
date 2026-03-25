import 'package:logger/logger.dart';

class AdminAnalyticsService {
  final Logger _logger;

  String? _userId;
  String? _userRole;

  AdminAnalyticsService()
      : _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 0,
            colors: true,
            printEmojis: false,
          ),
        );

  void setUser(String userId, String role) {
    _userId = userId;
    _userRole = role;
    _logger.i('[Analytics] User set: $userId ($role)');
  }

  void trackEvent(String event, {Map<String, dynamic>? properties}) {
    final payload = <String, dynamic>{
      'event': event,
      'timestamp': DateTime.now().toIso8601String(),
      if (_userId != null) 'userId': _userId,
      if (_userRole != null) 'role': _userRole,
      if (properties != null) ...properties,
    };
    _logger.d('[Analytics] Event: $event', error: payload);
  }

  void trackPageView(String pageName) {
    trackEvent(
      'page_view',
      properties: {
        'page': pageName,
        'path': pageName,
      },
    );
  }

  void trackError(String error, {Map<String, dynamic>? context}) {
    final payload = <String, dynamic>{
      'error': error,
      'timestamp': DateTime.now().toIso8601String(),
      if (_userId != null) 'userId': _userId,
      if (_userRole != null) 'role': _userRole,
      if (context != null) ...context,
    };
    _logger.e('[Analytics] Error tracked: $error', error: payload);
  }

  void clearUser() {
    _userId = null;
    _userRole = null;
  }
}
