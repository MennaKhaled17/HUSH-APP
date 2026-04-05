class PrayerTime {
  final String name;
  final String arabicName;
  final DateTime time;
  bool prayed;

  PrayerTime({
    required this.name,
    required this.arabicName,
    required this.time,
    this.prayed = false,
  });

  String get formattedTime {
    final h = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  bool get isPast => DateTime.now().isAfter(time);

  Map<String, dynamic> toMap() => {
        'name': name,
        'time': time.millisecondsSinceEpoch,
        'prayed': prayed ? 1 : 0,
      };

  factory PrayerTime.fromMap(Map<String, dynamic> map) => PrayerTime(
        name: map['name'],
        arabicName: '',
        time: DateTime.fromMillisecondsSinceEpoch(map['time']),
        prayed: map['prayed'] == 1,
      );
}