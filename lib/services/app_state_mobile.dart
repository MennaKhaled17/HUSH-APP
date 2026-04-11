import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class PlatformService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final _audioPlayer = AudioPlayer();

  static Future<void> initNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'azan_channel',
          'Azan Notifications',
          channelDescription: 'Prayer time azan notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> sendNotification({
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'hush_channel',
          'HUSH',
          channelDescription: 'Prayer and focus notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> playAzan() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/Abdul-Basit.mp3'));
    } catch (_) {}
  }

  static Future<void> playGraceAlert() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/alert.mp3'));
    } catch (_) {}
  }
}