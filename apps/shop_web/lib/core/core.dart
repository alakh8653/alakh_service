/// Barrel file that re-exports the entire core layer of the Shop Web app.
///
/// Import this file instead of individual core paths to keep feature-layer
/// imports concise.
library;

// Errors
export 'errors/shop_error_handler.dart';
export 'errors/shop_exceptions.dart';

// Network
export 'network/shop_api_client.dart';
export 'network/shop_api_endpoints.dart';
export 'network/shop_api_interceptors.dart';

// Security
export 'security/shop_auth_service.dart';
export 'security/shop_session_manager.dart';

// Analytics
export 'analytics/shop_analytics_events.dart';
export 'analytics/shop_analytics_service.dart';

// Routing
export 'routing/shop_route_guards.dart';
export 'routing/shop_route_names.dart';
export 'routing/shop_router.dart';
