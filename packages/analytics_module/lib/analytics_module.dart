/// AlakhService Analytics Module
///
/// Provides a unified analytics interface supporting multiple backends
/// (Firebase Analytics, Mixpanel, custom), predefined event constants,
/// and a mixin for automatic screen-view tracking in BLoC/Cubit classes.
library analytics_module;

export 'src/analytics_service.dart';
export 'src/analytics_events.dart';
export 'src/analytics_provider.dart';
export 'src/mixins/analytics_mixin.dart';
