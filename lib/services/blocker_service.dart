import 'package:flutter/services.dart';

class BlockerService {
  static const _channel = MethodChannel('com.menakhaled.hush/blocker');

  static Future<void> startBlocking(List<String> apps) async {
    await _channel.invokeMethod('startBlocking', {'apps': apps});
  }

  static Future<void> stopBlocking() async {
    await _channel.invokeMethod('stopBlocking');
  }
}