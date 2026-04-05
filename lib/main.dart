import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'models/prayer_time.dart';
import 'services/prayer_service.dart';
import 'screens/prayer_screen.dart';
void main() {
  runApp(const HushApp());
}

class HushApp extends StatelessWidget {
  const HushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUSH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        primaryColor: const Color(0xFF4CAF7D),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PrayerScreen(),
    FocusScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF4CAF7D),
          unselectedItemColor: Colors.white30,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mosque_outlined),
              activeIcon: Icon(Icons.mosque_rounded),
              label: 'Prayer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer_rounded),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// ── HOME ──────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PrayerTime> _prayers = [];
  bool _loading = true;
  String _nextPrayer = '';
  String _nextPrayerTime = '';

  @override
  void initState() {
    super.initState();
    _loadPrayers();
  }

  Future<void> _loadPrayers() async {
    try {
      final prayers = await PrayerService.getPrayerTimes();
      final now = TimeOfDay.now();

      PrayerTime next = prayers.last;
      for (final p in prayers) {
        final parts = p.time.split(' ');
        final timeParts = parts[0].split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        if (parts[1] == 'PM' && hour != 12) hour += 12;
        if (parts[1] == 'AM' && hour == 12) hour = 0;
        if (hour > now.hour ||
            (hour == now.hour && minute > now.minute)) {
          next = p;
          break;
        }
      }

      setState(() {
        _prayers = prayers;
        _nextPrayer = next.name;
        _nextPrayerTime = next.time;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good morning,',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 13)),
                    const Text('HUSH',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 6)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF7D).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color:
                            const Color(0xFF4CAF7D).withOpacity(0.3)),
                  ),
                  child: const Text('Cairo, EG',
                      style: TextStyle(
                          color: Color(0xFF4CAF7D), fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Next prayer card
            _GlowCard(
              glowColor: const Color(0xFF4CAF7D),
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF4CAF7D)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NEXT PRAYER',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                letterSpacing: 2.5)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_nextPrayer,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 42,
                                    fontWeight: FontWeight.w300)),
                            Text(_nextPrayerTime,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Focus card
            _GlowCard(
              glowColor: Colors.white12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('FOCUS MODE',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                              letterSpacing: 2.5)),
                      const SizedBox(height: 6),
                      const Text('Off',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w300)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF7D),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Start',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text('TODAY',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    letterSpacing: 2.5)),
            const SizedBox(height: 12),

            if (_loading)
              const Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF4CAF7D)))
            else
              ..._prayers.map((p) {
                final now = TimeOfDay.now();
                final parts = p.time.split(' ');
                final timeParts = parts[0].split(':');
                int hour = int.parse(timeParts[0]);
                final minute = int.parse(timeParts[1]);
                if (parts[1] == 'PM' && hour != 12) hour += 12;
                if (parts[1] == 'AM' && hour == 12) hour = 0;
                final done = hour < now.hour ||
                    (hour == now.hour && minute <= now.minute);
                return _prayerRow(p.name, p.time, done);
              }),
          ],
        ),
      ),
    );
  }

  Widget _prayerRow(String name, String time, bool done) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done
              ? const Color(0xFF4CAF7D).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name,
              style: TextStyle(
                  color:
                      done ? const Color(0xFF4CAF7D) : Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(time,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 13)),
              const SizedBox(width: 10),
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: done
                    ? const Color(0xFF4CAF7D)
                    : Colors.white24,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── PRAYER ────────────────────────────────────────────
class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Prayer Screen — coming soon',
            style: TextStyle(color: Colors.white38)),
      ),
    );
  }
}

// ── FOCUS ─────────────────────────────────────────────
class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Focus Screen — coming soon',
            style: TextStyle(color: Colors.white38)),
      ),
    );
  }
}

// ── SETTINGS ──────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: Text('Settings Screen — coming soon',
            style: TextStyle(color: Colors.white38)),
      ),
    );
  }
}

// ── SHARED WIDGET ─────────────────────────────────────
class _GlowCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;

  const _GlowCard({required this.child, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: glowColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}