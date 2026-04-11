// platform_service.dart
// Conditional import picks the real implementation on mobile/desktop,
// and the no-op stub on web. Both files export the same `PlatformService`
// class, so callers just use PlatformService.method() with no alias needed.

export 'app_state_mobile.dart'
    if (dart.library.html) 'app_state_web.dart';