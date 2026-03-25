/// Master barrel file for `apps/mobile_app/lib/core`.
///
/// Exports every sub-barrel so feature code can import the entire
/// foundation layer with a single statement:
///
/// ```dart
/// import 'package:mobile_app/core/core.dart';
/// ```
library core;

export 'accessibility/accessibility.dart';
export 'analytics/analytics.dart';
export 'cache/cache.dart';
export 'config/config.dart';
export 'di/di.dart';
export 'errors/errors.dart';
export 'network/network.dart';
export 'offline/offline.dart';
export 'permissions/permissions.dart';
export 'realtime/realtime.dart';
export 'routing/routing.dart';
export 'security/security.dart';
export 'theme/theme.dart';
export 'utils/utils.dart';
