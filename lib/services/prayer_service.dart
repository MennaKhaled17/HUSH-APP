import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prayer_time.dart';

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1/timings';

  static const Map<String, int> methods = {
    'Egyptian': 5,
    'MWL': 3,
    'ISNA': 2,
    'Umm al-Qura': 4,
  };

  static const Map<String, String> prayerArabic = {
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
  };

  Future<List<PrayerTime>> fetchPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 5,
    DateTime? date,
  }) async {
    final d = date ?? DateTime.now();
    final dateStr = '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-${d.year}';

    final uri = Uri.parse(
      '$_baseUrl/$dateStr?latitude=$latitude&longitude=$longitude&method=$method',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;
        return _parseTimings(timings, d);
      } else {
        throw Exception('Failed to fetch prayer times: ${response.statusCode}');
      }
    } catch (e) {
      return _fallbackTimes(d);
    }
  }

  List<PrayerTime> _parseTimings(Map<String, dynamic> timings, DateTime date) {
    final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return prayerNames.map((name) {
      final timeStr = timings[name] as String;
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return PrayerTime(
        name: name,
        arabicName: prayerArabic[name] ?? '',
        time: DateTime(date.year, date.month, date.day, hour, minute),
      );
    }).toList();
  }

  List<PrayerTime> _fallbackTimes(DateTime date) {
    final times = [
      [4, 52], [12, 15], [15, 48], [18, 27], [19, 56],
    ];
    final names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    return List.generate(
      5,
      (i) => PrayerTime(
        name: names[i],
        arabicName: prayerArabic[names[i]] ?? '',
        time: DateTime(date.year, date.month, date.day, times[i][0], times[i][1]),
      ),
    );
  }

  PrayerTime? getNextPrayer(List<PrayerTime> prayers) {
    final now = DateTime.now();
    try {
      return prayers.firstWhere((p) => p.time.isAfter(now));
    } catch (_) {
      return null;
    }
  }

  int getNextPrayerIndex(List<PrayerTime> prayers) {
    final now = DateTime.now();
    for (int i = 0; i < prayers.length; i++) {
      if (prayers[i].time.isAfter(now)) return i;
    }
    return -1;
  }
}