import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerTime {
  final String name;
  final String time;

  PrayerTime({required this.name, required this.time});
}

class PrayerService {
  static Future<List<PrayerTime>> getPrayerTimes() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.aladhan.com/v1/timingsByCity?city=Cairo&country=Egypt&method=5',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return [
          PrayerTime(name: 'Fajr', time: _formatTime(timings['Fajr'])),
          PrayerTime(name: 'Dhuhr', time: _formatTime(timings['Dhuhr'])),
          PrayerTime(name: 'Asr', time: _formatTime(timings['Asr'])),
          PrayerTime(name: 'Maghrib', time: _formatTime(timings['Maghrib'])),
          PrayerTime(name: 'Isha', time: _formatTime(timings['Isha'])),
        ];
      } else {
        throw Exception('Failed to load prayer times');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }
}