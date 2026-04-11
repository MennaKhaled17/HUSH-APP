import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions.defaultOptions,
  );

  // Emergency bypass log — sensitive, must be secure
  static Future<void> logEmergencyBypass(String prayerName) async {
    final existing = await _storage.read(key: 'emergency_log') ?? '';
    final entry = '$existing\n${DateTime.now().toIso8601String()} - $prayerName';
    await _storage.write(key: 'emergency_log', value: entry);
  }

  static Future<String> getEmergencyLog() async {
    return await _storage.read(key: 'emergency_log') ?? 'No bypasses logged';
  }

  // Keep non-sensitive stuff in SharedPreferences, only move sensitive keys here
}