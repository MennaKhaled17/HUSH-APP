import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class _T {
  static const Color bg       = Color(0xFF0F1117);
  static const Color sheet    = Color(0xFFF0F0EE);
  static const Color lime     = Color(0xFFC8F135);
  static const Color darkText = Color(0xFF111111);
  static const Color heroText = Color(0xFFF0EDE6);
  static const Color heroSub  = Color(0xFF888B9A);
  static const Color gold     = Color(0xFFFFB300);
  static const Color goldBg   = Color(0xFFFFF8E1);
  static const Color green    = Color(0xFF34B775);
  static const Color purple   = Color(0xFF8B6FD4);
  static const Color purpleBg = Color(0xFFEFEBFA);
}

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final top = MediaQuery.of(context).padding.top;

    // ── Derived values ──────────────────────────────────────────
    final focusHours = appState.totalFocusMinutes ~/ 60;
    final focusMins  = appState.totalFocusMinutes % 60;
    final prayedToday = appState.prayersKeptToday;
    final streak = appState.streakDays;

    // Prayer completion % today
    final prayerPct = prayedToday / 5.0;

    // Focus level label
    String focusLevel;
    Color focusLevelColor;
    if (appState.totalFocusMinutes < 60) {
      focusLevel = 'Just getting started';
      focusLevelColor = _T.heroSub;
    } else if (appState.totalFocusMinutes < 300) {
      focusLevel = 'Building momentum';
      focusLevelColor = _T.lime;
    } else if (appState.totalFocusMinutes < 1000) {
      focusLevel = 'In the zone';
      focusLevelColor = _T.green;
    } else {
      focusLevel = 'Deep work master';
      focusLevelColor = _T.gold;
    }

    // Streak label
    String streakLabel;
    if (streak == 0) {
      streakLabel = 'Start today 🌱';
    } else if (streak < 3) {
      streakLabel = 'Keep it going!';
    } else if (streak < 7) {
      streakLabel = 'You\'re on fire 🔥';
    } else {
      streakLabel = 'Unstoppable 🏆';
    }

    return Scaffold(
      backgroundColor: _T.bg,
      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: _T.bg,
                  padding: EdgeInsets.fromLTRB(22, top + 18, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: _T.heroSub, size: 20),
                          ),
                          const SizedBox(width: 14),
                          const Text(
                            'YOUR PROGRESS',
                            style: TextStyle(
                              color: _T.heroSub,
                              fontSize: 11,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _T.goldBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded,
                                    color: _T.gold, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  '$streak day streak',
                                  style: const TextStyle(
                                    color: _T.gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'How are\nyou doing?',
                        style: TextStyle(
                          color: _T.heroText,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        focusLevel,
                        style: TextStyle(
                          color: focusLevelColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── White sheet ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: _T.sheet,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Big 2-stat row ─────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _BigStatCard(
                              label: 'Focus time',
                              value: focusHours > 0
                                  ? '${focusHours}h ${focusMins}m'
                                  : '${focusMins}m',
                              sub: 'total all time',
                              icon: Icons.bolt_rounded,
                              iconColor: _T.purple,
                              iconBg: _T.purpleBg,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BigStatCard(
                              label: 'Prayer streak',
                              value: '$streak',
                              sub: streakLabel,
                              icon: Icons.local_fire_department_rounded,
                              iconColor: _T.gold,
                              iconBg: _T.goldBg,
                              valueSuffix: 'd',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Today's prayers ────────────────────────
                      _SectionLabel(label: "TODAY'S PRAYERS"),
                      const SizedBox(height: 12),
                      _PrayerProgressCard(
                        prayers: appState.prayers,
                        prayedCount: prayedToday,
                        pct: prayerPct,
                      ),
                      const SizedBox(height: 16),

                      // ── Focus breakdown ────────────────────────
                      _SectionLabel(label: 'FOCUS BREAKDOWN'),
                      const SizedBox(height: 12),
                      _FocusBreakdownCard(appState: appState),
                      const SizedBox(height: 16),

                      // ── Streak visual ──────────────────────────
                      _SectionLabel(label: 'YOUR STREAK'),
                      const SizedBox(height: 12),
                      _StreakVisualCard(streak: streak),
                      const SizedBox(height: 16),

                      // ── Motivational footer ────────────────────
                      _MotivationCard(
                        streak: streak,
                        prayedToday: prayedToday,
                        totalFocusMinutes: appState.totalFocusMinutes,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: _T.darkText.withValues(alpha: 0.38),
        fontSize: 11,
        letterSpacing: 2.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Big Stat Card ────────────────────────────────────────────────────────────
class _BigStatCard extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color iconColor, iconBg;
  final String? valueSuffix;

  const _BigStatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.valueSuffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: _T.darkText,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              if (valueSuffix != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 2),
                  child: Text(
                    valueSuffix!,
                    style: TextStyle(
                      color: _T.darkText.withValues(alpha: 0.4),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _T.darkText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              color: _T.darkText.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Prayer Progress Card ─────────────────────────────────────────────────────
class _PrayerProgressCard extends StatelessWidget {
  final List prayers;
  final int prayedCount;
  final double pct;

  const _PrayerProgressCard({
    required this.prayers,
    required this.prayedCount,
    required this.pct,
  });

  @override
  Widget build(BuildContext context) {
    final names = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$prayedCount of 5 prayed',
                      style: const TextStyle(
                        color: _T.darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pct == 1.0
                          ? 'All done today 🎉'
                          : prayedCount == 0
                              ? 'Start your day with Fajr'
                              : '${5 - prayedCount} prayer${5 - prayedCount > 1 ? 's' : ''} left',
                      style: TextStyle(
                        color: _T.darkText.withValues(alpha: 0.45),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _CircleProgress(pct: pct),
            ],
          ),
          const SizedBox(height: 20),
          // Prayer dots row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final prayed = i < prayers.length ? prayers[i].prayed as bool : false;
              final name = i < names.length ? names[i] : '?';
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: prayed ? _T.green : const Color(0xFFF5F5F5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: prayed ? _T.green : const Color(0xFFE0E0E0),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        prayed ? Icons.check_rounded : Icons.circle_outlined,
                        color: prayed ? Colors.white : const Color(0xFFCCCCCC),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: TextStyle(
                      color: prayed ? _T.green : _T.darkText.withValues(alpha: 0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Circle Progress ──────────────────────────────────────────────────────────
class _CircleProgress extends StatelessWidget {
  final double pct;
  const _CircleProgress({required this.pct});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(56, 56),
            painter: _ArcPainter(pct: pct),
          ),
          Center(
            child: Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(
                color: _T.darkText,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double pct;
  const _ArcPainter({required this.pct});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx - 4;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final bgPaint = Paint()
      ..color = const Color(0xFFEEEEEE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);
    if (pct > 0) {
      final fgPaint = Paint()
        ..color = _T.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, -1.5708, pct * 6.2832, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.pct != pct;
}

// ─── Focus Breakdown Card ─────────────────────────────────────────────────────
class _FocusBreakdownCard extends StatelessWidget {
  final AppState appState;
  const _FocusBreakdownCard({required this.appState});

  @override
  Widget build(BuildContext context) {
    final total = appState.totalFocusMinutes;
    final hours = total ~/ 60;
    final mins = total % 60;

    // Milestone progress
    const milestones = [60, 300, 600, 1200, 3000];
    const milestoneLabels = ['1h', '5h', '10h', '20h', '50h'];
    int nextMilestone = milestones.last;
    String nextLabel = milestoneLabels.last;
    for (int i = 0; i < milestones.length; i++) {
      if (total < milestones[i]) {
        nextMilestone = milestones[i];
        nextLabel = milestoneLabels[i];
        break;
      }
    }
    final milestoneProgress = (total / nextMilestone).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161820),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A0E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt_rounded, color: _T.lime, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hours > 0 ? '$hours hrs $mins min' : '$mins min',
                    style: const TextStyle(
                      color: _T.heroText,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'total focus time',
                    style: TextStyle(color: _T.heroSub, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Milestone bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Next milestone: $nextLabel',
                style: const TextStyle(
                  color: _T.heroSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(milestoneProgress * 100).round()}%',
                style: const TextStyle(
                  color: _T.lime,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: milestoneProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A2D38),
              valueColor: const AlwaysStoppedAnimation<Color>(_T.lime),
            ),
          ),
          const SizedBox(height: 16),

          // Focus modes used
          const Text(
            'Modes available',
            style: TextStyle(color: _T.heroSub, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: appState.focusModes.map((m) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A0E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                m.name,
                style: const TextStyle(
                  color: _T.lime,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Streak Visual Card ───────────────────────────────────────────────────────
class _StreakVisualCard extends StatelessWidget {
  final int streak;
  const _StreakVisualCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    // Show last 14 days as dots
    const totalDots = 14;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$streak',
                style: const TextStyle(
                  color: _T.darkText,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'day streak',
                    style: TextStyle(
                      color: _T.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    streak == 0
                        ? 'Start today!'
                        : streak == 1
                            ? 'First day 🌱'
                            : streak < 7
                                ? 'Keep going!'
                                : 'Incredible 🏆',
                    style: TextStyle(
                      color: _T.darkText.withValues(alpha: 0.45),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.local_fire_department_rounded,
                  color: _T.gold, size: 40),
            ],
          ),
          const SizedBox(height: 20),

          // Dot grid: last 14 days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalDots, (i) {
              // i=0 is 13 days ago, i=13 is today
              final daysAgo = totalDots - 1 - i;
              final filled = daysAgo < streak;
              final isToday = daysAgo == 0;
              return Column(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200 + i * 30),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: filled
                          ? (isToday ? _T.lime : _T.green)
                          : const Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: _T.lime, width: 2)
                          : null,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: _T.lime,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '13 days ago',
                style: TextStyle(
                  color: _T.darkText.withValues(alpha: 0.3),
                  fontSize: 10,
                ),
              ),
              Text(
                'Today',
                style: TextStyle(
                  color: _T.lime.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Motivation Card ──────────────────────────────────────────────────────────
class _MotivationCard extends StatelessWidget {
  final int streak, prayedToday, totalFocusMinutes;
  const _MotivationCard({
    required this.streak,
    required this.prayedToday,
    required this.totalFocusMinutes,
  });

  String get _message {
    if (prayedToday == 5 && streak >= 7) {
      return 'You\'re showing up every single day. That\'s what separates those who dream from those who achieve.';
    } else if (prayedToday == 5) {
      return 'All 5 prayers done today. Every day you show up, you become more of who you want to be.';
    } else if (streak >= 7) {
      return 'A $streak-day streak is no accident. It\'s a choice you\'ve made every single day.';
    } else if (totalFocusMinutes >= 60) {
      return 'Every minute of focus you log is a brick in the wall of the life you\'re building.';
    } else {
      return 'Every expert was once a beginner. Your journey starts with one session, one prayer, one day.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF161820),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2D38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A0E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text('✦', style: TextStyle(color: _T.lime, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'REMEMBER THIS',
                style: TextStyle(
                  color: _T.heroSub,
                  fontSize: 10,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _message,
            style: const TextStyle(
              color: _T.heroText,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}