import 'package:flutter/services.dart';

class AppBlockerService {
  static const _channel = MethodChannel('com.hush/app_blocker');

  static Future<void> blockApps(List<String> apps) async {
    try {
      await _channel.invokeMethod('blockApps', {'apps': apps});
    } catch (_) {
      // Platform may not support this
    }
  }

  static Future<void> unblockAll() async {
    try {
      await _channel.invokeMethod('unblockAll');
    } catch (_) {}
  }
}