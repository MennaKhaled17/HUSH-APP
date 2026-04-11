import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_state.dart';
import 'stats_screen.dart';
import '../models/focus_session.dart';

// ─── Top-level helper ─────────────────────────────────────────────────────────
String _getInitials(String name) {
  final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

class _DesignTokens {
  static const Color heroBg       = Color(0xFF0F1117);
  static const Color sheetBg      = Color(0xFFF0F0EE);
  static const Color lime         = Color(0xFFC8F135);
  static const Color limeDim      = Color(0xFF8FAA24);
  static const Color darkText     = Color(0xFF111111);
  static const Color heroText     = Color(0xFFF0EDE6);
  static const Color heroSub      = Color(0xFF888B9A);
  static const Color tileBg       = Color(0xFFFFFFFF);
  static const Color tileBorder   = Color(0xFFE8E8E8);
  static const Color streakCard   = Color(0xFF1A1D25);
  static const Color streakBorder = Color(0xFF2A2D38);
  static const Color focusCard    = Color(0xFF161820);
  static const Color pillBg       = Color(0xFF1E3A0E);
  static const Color pillText     = Color(0xFFA8D44A);
  static const Color iconBgGreen  = Color(0xFFE8F8EF);
  static const Color iconBgPurple = Color(0xFFEFEBFA);
  static const Color iconBgGray   = Color(0xFFF0F0F0);
}

class HomeScreen extends StatefulWidget {
  final void Function(int)? onTabSwitch;

  const HomeScreen({super.key, this.onTabSwitch});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Timer? _countdownTimer;
  String _userName = '';

  late final AnimationController _heroCtrl;
  late final AnimationController _sheetCtrl;
  late final AnimationController _streakCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _barCtrl;

  late final Animation<double>   _heroFade;
  late final Animation<Offset>   _heroSlide;
  late final Animation<double>   _greetFade;
  late final Animation<Offset>   _greetSlide;
  late final Animation<double>   _headlineFade;
  late final Animation<Offset>   _headlineSlide;
  late final Animation<double>   _streakFade;
  late final Animation<Offset>   _streakSlide;
  late final Animation<double>   _sheetFade;
  late final Animation<Offset>   _sheetSlide;
  late final Animation<double>   _streakCount;
  late final Animation<double>   _dotPulse;
  late final Animation<double>   _barScale;

  int _displayedStreak = 0;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _heroFade     = CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    _heroSlide    = Tween(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));

    _greetFade    = CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.1, 0.5, curve: Curves.easeOut));
    _greetSlide   = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.1, 0.5, curve: Curves.easeOutCubic)));

    _headlineFade = CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.2, 0.7, curve: Curves.easeOut));
    _headlineSlide= Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic)));

    _streakFade   = CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.4, 0.9, curve: Curves.easeOut));
    _streakSlide  = Tween(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)));

    _sheetCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _sheetFade  = CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut);
    _sheetSlide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));

    _streakCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _streakCount = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _streakCtrl, curve: Curves.easeOutCubic));
    _streakCount.addListener(() {
      final appState = context.read<AppState>();
      setState(() => _displayedStreak = (_streakCount.value * appState.streakDays).round());
    });

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _dotPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _barCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _barScale = Tween<double>(begin: 0.92, end: 1.0).animate(
        CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutBack));

    _loadUserName();
    _startCountdown();
    _runEntrance();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (name.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNameDialog());
    } else {
      setState(() => _userName = name);
    }
  }

  Future<void> _showNameDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('What should we call you?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_name', name);
              setState(() => _userName = name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _runEntrance() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _heroCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 420));
    _sheetCtrl.forward();
    _streakCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _barCtrl.forward();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final appState = context.read<AppState>();
    final next = appState.nextPrayer;
    if (next != null) {
      final now = DateTime.now();
      final prayerTime = DateTime(now.year, now.month, now.day, next.time.hour, next.time.minute);
      final diff = prayerTime.difference(now);
      if (diff.isNegative) setState(() {});
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _heroCtrl.dispose();
    _sheetCtrl.dispose();
    _streakCtrl.dispose();
    _pulseCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'GOOD MORNING';
    if (h < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final activeMode = appState.activeFocusMode;
    final isActive = appState.timerRunning;

    return Scaffold(
      backgroundColor: _DesignTokens.heroBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _AnimatedHeroSection(
                  greeting: _greeting(),
                  streakDays: _displayedStreak,
                  activeMode: activeMode,
                  isActive: isActive,
                  userName: _userName,
                  onAvatarTap: _showNameDialog,
                  heroFade: _heroFade,
                  heroSlide: _heroSlide,
                  greetFade: _greetFade,
                  greetSlide: _greetSlide,
                  headlineFade: _headlineFade,
                  headlineSlide: _headlineSlide,
                  streakFade: _streakFade,
                  streakSlide: _streakSlide,
                  dotPulse: _dotPulse,
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _sheetFade,
                  child: SlideTransition(
                    position: _sheetSlide,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: _DesignTokens.sheetBg,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 28),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            child: Text(
                              'CHOOSE A SERVICE',
                              style: TextStyle(
                                color: _DesignTokens.darkText.withValues(alpha: 0.4),
                                fontSize: 11,
                                letterSpacing: 2.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _FocusModeCard(
                              appState: appState,
                              onTabSwitch: widget.onTabSwitch,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _ServiceGrid(onTabSwitch: widget.onTabSwitch),
                          ),
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 110),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ScaleTransition(
              scale: _barScale,
              child: _QuickStartBar(
                appState: appState,
                onTabSwitch: widget.onTabSwitch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Hero Section ────────────────────────────────────────────────────
class _AnimatedHeroSection extends StatelessWidget {
  final String greeting;
  final int streakDays;
  final FocusMode? activeMode;
  final bool isActive;
  final String userName;
  final VoidCallback onAvatarTap;
  final Animation<double> heroFade, greetFade, headlineFade, streakFade, dotPulse;
  final Animation<Offset> heroSlide, greetSlide, headlineSlide, streakSlide;

  const _AnimatedHeroSection({
    required this.greeting,
    required this.streakDays,
    required this.activeMode,
    required this.isActive,
    required this.userName,
    required this.onAvatarTap,
    required this.heroFade,
    required this.heroSlide,
    required this.greetFade,
    required this.greetSlide,
    required this.headlineFade,
    required this.headlineSlide,
    required this.streakFade,
    required this.streakSlide,
    required this.dotPulse,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: _DesignTokens.heroBg,
      padding: EdgeInsets.fromLTRB(22, top + 16, 22, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeTransition(
            opacity: heroFade,
            child: SlideTransition(
              position: heroSlide,
              child: Row(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: _DesignTokens.heroText,
                      ),
                      children: [
                        TextSpan(text: 'H U S '),
                        TextSpan(text: 'H', style: TextStyle(color: _DesignTokens.lime)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2D38),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF3A3D4A), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(userName),
                          style: const TextStyle(
                            color: _DesignTokens.heroSub,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          FadeTransition(
            opacity: greetFade,
            child: SlideTransition(
              position: greetSlide,
              child: Text(
                greeting,
                style: TextStyle(
                  color: _DesignTokens.heroSub.withValues(alpha: 0.7),
                  fontSize: 11,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: headlineFade,
            child: SlideTransition(
              position: headlineSlide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: _DesignTokens.heroText,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: 'What are you\n'),
                        TextSpan(
                          text: 'focusing on ',
                          style: TextStyle(color: _DesignTokens.lime, fontStyle: FontStyle.italic),
                        ),
                        TextSpan(text: 'today?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pick a mode. Lock in.',
                    style: TextStyle(color: _DesignTokens.heroSub.withValues(alpha: 0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: streakFade,
            child: SlideTransition(
              position: streakSlide,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/stats'),
                child: _StreakPill(
                  streakDays: streakDays,
                  activeMode: activeMode,
                  isActive: isActive,
                  dotPulse: dotPulse,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Streak Pill ──────────────────────────────────────────────────────────────
class _StreakPill extends StatelessWidget {
  final int streakDays;
  final FocusMode? activeMode;
  final bool isActive;
  final Animation<double> dotPulse;

  const _StreakPill({
    required this.streakDays,
    required this.activeMode,
    required this.isActive,
    required this.dotPulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: _DesignTokens.streakCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DesignTokens.streakBorder, width: 1),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: dotPulse,
            builder: (_, __) => Opacity(
              opacity: isActive ? dotPulse.value : 0.4,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: isActive ? _DesignTokens.lime : _DesignTokens.limeDim,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT STREAK',
                  style: TextStyle(
                    color: _DesignTokens.heroSub.withValues(alpha: 0.6),
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isActive ? '${activeMode?.name ?? 'Focus'} · active' : 'Deep work · inactive',
                  style: const TextStyle(color: _DesignTokens.heroText, fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: streakDays.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => Text(
              '${val.round()}d',
              style: const TextStyle(
                color: _DesignTokens.lime,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Focus Mode Card ──────────────────────────────────────────────────────────
class _FocusModeCard extends StatelessWidget {
  final AppState appState;
  final void Function(int)? onTabSwitch;

  const _FocusModeCard({required this.appState, this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    final modes = appState.focusModes;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DesignTokens.focusCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Focus mode', style: TextStyle(color: _DesignTokens.heroText, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                    SizedBox(height: 3),
                    Text('Block everything. Enter the zone.', style: TextStyle(color: _DesignTokens.heroSub, fontSize: 13)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => onTabSwitch?.call(1),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _DesignTokens.lime, width: 1.5)),
                  child: Center(
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _DesignTokens.lime, width: 1.5)),
                      child: Center(child: Container(width: 4, height: 4, decoration: const BoxDecoration(color: _DesignTokens.lime, shape: BoxShape.circle))),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: modes.take(3).map((m) => _TappablePill(
              label: m.name,
              onTap: () {
                appState.startFocus(m);
                onTabSwitch?.call(1);
              },
            )).toList(),
          ),
          const SizedBox(height: 18),
          _PressableText(
            text: 'Start session ›',
            onTap: () {
              if (modes.isNotEmpty && !appState.timerRunning) {
                appState.startFocus(modes.first);
              }
              onTabSwitch?.call(1);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Tappable Pill ────────────────────────────────────────────────────────────
class _TappablePill extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _TappablePill({required this.label, required this.onTap});
  @override
  State<_TappablePill> createState() => _TappablePillState();
}

class _TappablePillState extends State<_TappablePill> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _onTap() {
    HapticFeedback.lightImpact();
    setState(() => _selected = !_selected);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); _onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _selected ? _DesignTokens.lime : _DesignTokens.pillBg,
            borderRadius: BorderRadius.circular(8),
            border: _selected ? Border.all(color: _DesignTokens.lime, width: 1.5) : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _selected ? _DesignTokens.darkText : _DesignTokens.pillText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pressable Text ───────────────────────────────────────────────────────────
class _PressableText extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _PressableText({required this.text, required this.onTap});
  @override
  State<_PressableText> createState() => _PressableTextState();
}

class _PressableTextState extends State<_PressableText> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Text(
          widget.text,
          style: const TextStyle(color: _DesignTokens.lime, fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── Service Grid ─────────────────────────────────────────────────────────────
class _ServiceGrid extends StatelessWidget {
  final void Function(int)? onTabSwitch;
  const _ServiceGrid({this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _ServiceTileData(
        iconData: Icons.access_time_rounded,
        iconBg: _DesignTokens.iconBgGreen,
        iconColor: const Color(0xFF34B775),
        label: 'Prayer times',
        sub: 'All 5 prayers tracked.',
        linkText: 'View',
        linkColor: const Color(0xFF34B775),
        tabIndex: 2,
      ),
      _ServiceTileData(
        iconData: Icons.lock_outline_rounded,
        iconBg: _DesignTokens.iconBgPurple,
        iconColor: const Color(0xFF8B6FD4),
        label: 'App blocker',
        sub: 'Kill distractions.',
        linkText: 'Set up',
        linkColor: const Color(0xFF8B6FD4),
        tabIndex: 1,
      ),
      _ServiceTileData(
        iconData: Icons.emoji_events_rounded,
        iconBg: const Color(0xFFFFF8E1),
        iconColor: const Color(0xFFFFB300),
        label: 'Progress',
        sub: 'Your journey so far.',
        linkText: 'View',
        linkColor: const Color(0xFFFFB300),
        tabIndex: null,
        route: '/stats',
      ),
      _ServiceTileData(
        iconData: Icons.tune_rounded,
        iconBg: _DesignTokens.iconBgGray,
        iconColor: const Color(0xFF888B9A),
        label: 'Settings',
        sub: 'Prefs & notifs.',
        linkText: 'Open',
        linkColor: const Color(0xFF888B9A),
        tabIndex: 3,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: List.generate(tiles.length, (i) =>
        _AnimatedServiceTile(data: tiles[i], index: i, onTabSwitch: onTabSwitch),
      ),
    );
  }
}

class _ServiceTileData {
  final IconData iconData;
  final Color iconBg, iconColor, linkColor;
  final String label, sub, linkText;
  final int? tabIndex;
  final String? route;

  const _ServiceTileData({
    required this.iconData,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.linkText,
    required this.linkColor,
    this.tabIndex,
    this.route,
  });
}

class _AnimatedServiceTile extends StatefulWidget {
  final _ServiceTileData data;
  final int index;
  final void Function(int)? onTabSwitch;
  const _AnimatedServiceTile({required this.data, required this.index, this.onTabSwitch});
  @override
  State<_AnimatedServiceTile> createState() => _AnimatedServiceTileState();
}

class _AnimatedServiceTileState extends State<_AnimatedServiceTile> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) { _ctrl.forward(); HapticFeedback.selectionClick(); },
      onTapUp: (_) {
        _ctrl.reverse();
        if (d.tabIndex != null) {
          widget.onTabSwitch?.call(d.tabIndex!);
        } else if (d.route != null) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatsScreen()));
        }
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _DesignTokens.tileBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _DesignTokens.tileBorder, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: d.iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(d.iconData, color: d.iconColor, size: 22),
              ),
              const SizedBox(height: 10),
              Text(d.label, style: const TextStyle(color: _DesignTokens.darkText, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
              const SizedBox(height: 2),
              Text(d.sub, style: TextStyle(color: _DesignTokens.darkText.withValues(alpha: 0.45), fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('${d.linkText} ', style: TextStyle(color: d.linkColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('›', style: TextStyle(color: d.linkColor, fontSize: 15, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Quick Start Bar ──────────────────────────────────────────────────────────
class _QuickStartBar extends StatefulWidget {
  final AppState appState;
  final void Function(int)? onTabSwitch;
  const _QuickStartBar({required this.appState, this.onTabSwitch});
  @override
  State<_QuickStartBar> createState() => _QuickStartBarState();
}

class _QuickStartBarState extends State<_QuickStartBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final activeMode = appState.activeFocusMode;
    final isRunning = appState.timerRunning;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: _DesignTokens.sheetBg,
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottom + 12),
      child: ScaleTransition(
        scale: _pulse,
        child: GestureDetector(
          onTapDown: (_) { _pulseCtrl.stop(); HapticFeedback.mediumImpact(); },
          onTapUp: (_) {
            _pulseCtrl.repeat(reverse: true);
            if (!isRunning && appState.focusModes.isNotEmpty) {
              appState.startFocus(appState.focusModes.first);
            }
            widget.onTabSwitch?.call(1);
          },
          onTapCancel: () => _pulseCtrl.repeat(reverse: true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            decoration: BoxDecoration(
              color: _DesignTokens.lime,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Quick start focus', style: TextStyle(color: _DesignTokens.darkText, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                      const SizedBox(height: 2),
                      Text(
                        isRunning
                            ? 'Session running…'
                            : activeMode != null
                                ? 'Resume ${activeMode.name}'
                                : 'Tap to begin',
                        style: TextStyle(color: _DesignTokens.darkText.withValues(alpha: 0.55), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44, height: 44,
                  decoration: const BoxDecoration(color: _DesignTokens.darkText, shape: BoxShape.circle),
                  child: Icon(isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, color: _DesignTokens.lime, size: 24),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}