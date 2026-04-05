import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/focus_session.dart';
import '../core/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _countdownTimer;
  Duration _timeToNextPrayer = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateCountdown();
    });
  }

  void _updateCountdown() {
    final state = context.read<AppState>();
    final next = state.nextPrayer;
    if (next != null) {
      final diff = next.time.difference(DateTime.now());
      setState(() => _timeToNextPrayer = diff.isNegative ? Duration.zero : diff);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _greeting(AppState state) {
    final h = DateTime.now().hour;
    if (h < 12) return state.loc.goodMorning;
    if (h < 17) return state.loc.goodAfternoon;
    return state.loc.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final next = state.nextPrayer;
        final loc = state.loc;
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(state),
                        style: const TextStyle(
                          fontSize: 11,
                          letterSpacing: 2.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                            fontFamily: 'DMSans',
                          ),
                          children: [
                            TextSpan(text: '${loc.heroText} '),
                            TextSpan(
                              text: loc.heroAccent,
                              style: const TextStyle(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (state.timerRunning)
                        _ActiveSessionBanner(state: state),
                      if (next != null)
                        _NextPrayerCard(
                          prayer: next,
                          countdown: _formatCountdown(_timeToNextPrayer),
                          loc: loc,
                        ),
                      const SizedBox(height: 28),
                      Text(
                        loc.quickFocus,
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 2.5,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final modes = state.focusModes;
                      if (i >= modes.length || i >= 4) return null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _QuickFocusRow(
                          mode: modes[i],
                          loc: state.loc,
                          onTap: () => state.startFocus(modes[i]),
                        ),
                      );
                    },
                    childCount: state.focusModes.length > 4 ? 4 : state.focusModes.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  child: _StartButton(
                    label: state.loc.startSession,
                    onTap: () => state.startFocus(
                      state.focusModes.isNotEmpty
                          ? state.focusModes[0]
                          : FocusMode.defaults[0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Next Prayer Card ─────────────────────────────────────────────────────────

class _NextPrayerCard extends StatelessWidget {
  final dynamic prayer;
  final String countdown;
  final dynamic loc;

  const _NextPrayerCard({
    required this.prayer,
    required this.countdown,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.goldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.nextPrayer,
                  style: const TextStyle(
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  prayer.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  prayer.formattedTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                countdown,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                loc.untilAzan,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Active Session Banner ────────────────────────────────────────────────────

class _ActiveSessionBanner extends StatelessWidget {
  final AppState state;
  const _ActiveSessionBanner({required this.state});

  @override
  Widget build(BuildContext context) {
    final mode = state.activeSession?.mode;
    if (mode == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: mode.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mode.color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: mode.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${mode.name} · ${state.timerDisplay} ${state.loc.untilAzan}',
              style: TextStyle(
                fontSize: 13,
                color: mode.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: state.stopFocus,
            child: Text(
              state.loc.endSession,
              style: TextStyle(
                fontSize: 12,
                color: mode.color.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Focus Row ──────────────────────────────────────────────────────────

class _QuickFocusRow extends StatelessWidget {
  final FocusMode mode;
  final dynamic loc;
  final VoidCallback onTap;

  const _QuickFocusRow({
    required this.mode,
    required this.loc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: mode.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.blockedApps.isEmpty
                        ? loc.noAppsBlocked
                        : mode.blockedApps.take(2).join(', ') +
                            (mode.blockedApps.length > 2
                                ? ' +${mode.blockedApps.length - 2}'
                                : ''),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              loc.minutesSuffix(mode.defaultMinutes),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Start Button ─────────────────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StartButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: AppColors.gold,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.base),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.base,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}