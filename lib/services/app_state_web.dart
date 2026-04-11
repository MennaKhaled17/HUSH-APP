// Web stub — flutter_local_notifications and audioplayers are not supported on web.
// All methods here are intentional no-ops.

class PlatformService {
  static Future<void> initNotifications() async {}
  static Future<void> cancelAllNotifications() async {}

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {}

  static Future<void> sendNotification({
    required String title,
    required String body,
  }) async {}

  static Future<void> playAzan() async {}
  static Future<void> playGraceAlert() async {}
}