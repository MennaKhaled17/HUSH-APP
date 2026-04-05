import 'package:flutter/material.dart';
import '../../models/prayer_time.dart';
import '../../services/prayer_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  List<PrayerTime> _prayers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prayers = await PrayerService.getPrayerTimes();
      setState(() {
        _prayers = prayers;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text('PRAYER',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 6)),
            const Text('Cairo, Egypt',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 28),
            if (_loading)
              const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF4CAF7D)))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _prayers.length,
                  itemBuilder: (context, i) {
                    final p = _prayers[i];
                    final now = TimeOfDay.now();
                    final parts = p.time.split(' ');
                    final timeParts = parts[0].split(':');
                    int hour = int.parse(timeParts[0]);
                    final minute = int.parse(timeParts[1]);
                    if (parts[1] == 'PM' && hour != 12) hour += 12;
                    if (parts[1] == 'AM' && hour == 12) hour = 0;
                    final done = hour < now.hour ||
                        (hour == now.hour && minute <= now.minute);
                    final isNext = !done &&
                        (_prayers
                            .where((x) {
                              final xp = x.time.split(' ');
                              final xt = xp[0].split(':');
                              int xh = int.parse(xt[0]);
                              final xm = int.parse(xt[1]);
                              if (xp[1] == 'PM' && xh != 12) xh += 12;
                              if (xp[1] == 'AM' && xh == 12) xh = 0;
                              return xh < now.hour ||
                                  (xh == now.hour && xm <= now.minute);
                            })
                            .length ==
                        i);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isNext
                            ? const Color(0xFF4CAF7D).withOpacity(0.1)
                            : const Color(0xFF141414),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isNext
                              ? const Color(0xFF4CAF7D).withOpacity(0.4)
                              : done
                                  ? const Color(0xFF4CAF7D)
                                      .withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: TextStyle(
                                      color: done
                                          ? const Color(0xFF4CAF7D)
                                          : Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(
                                isNext
                                    ? 'Next prayer'
                                    : done
                                        ? 'Completed'
                                        : 'Upcoming',
                                style: TextStyle(
                                    color: isNext
                                        ? const Color(0xFF4CAF7D)
                                        : Colors.white24,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(p.time,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              Icon(
                                done
                                    ? Icons.check_circle_rounded
                                    : isNext
                                        ? Icons.radio_button_checked
                                        : Icons
                                            .radio_button_unchecked_rounded,
                                color: done || isNext
                                    ? const Color(0xFF4CAF7D)
                                    : Colors.white24,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}