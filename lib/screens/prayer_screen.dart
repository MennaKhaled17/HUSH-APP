import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/prayer_time.dart';
import '../core/app_colors.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heroCtrl;
  late final AnimationController _sheetCtrl;

  late final Animation<double> _heroFade;
  late final Animation<Offset> _heroSlide;
  late final Animation<double> _sheetFade;
  late final Animation<Offset> _sheetSlide;

  @override
  void initState() {
    super.initState();

    _heroCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween(begin: const Offset(0, -0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    _sheetCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _sheetFade = CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOut);
    _sheetSlide = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sheetCtrl, curve: Curves.easeOutCubic));

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _sheetCtrl.forward();
    });
  }

  @override
  void dispose() {
    _heroCtrl.dispose();
    _sheetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final loc = state.loc;
        final kept = state.prayersKeptToday;
        final nextIdx = state.nextPrayerIndex;

        return Scaffold(
          backgroundColor: AppColors.base,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Animated hero header ──────────────────────────
              FadeTransition(
                opacity: _heroFade,
                child: SlideTransition(
                  position: _heroSlide,
                  child: Container(
                    color: AppColors.base,
                    padding: EdgeInsets.fromLTRB(
                        22, MediaQuery.of(context).padding.top + 20, 22, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.prayerTracker,
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 3,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            children: [
                              TextSpan(
                                  text: loc.todaysPrayers.replaceAll('.', '')),
                              const TextSpan(
                                text: '.',
                                style: TextStyle(color: AppColors.lime),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.formatDate(DateTime.now()),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Animated light sheet ──────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _sheetFade,
                  child: SlideTransition(
                    position: _sheetSlide,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: AppColors.sheet,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                      child: state.prayersLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator(
                                  color: AppColors.lime,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : state.prayersError != null
                              ? _ErrorCard(
                                  message: state.prayersError!,
                                  retryLabel: loc.retry,
                                  onRetry: () => state.loadPrayerTimes(),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ...List.generate(state.prayers.length, (i) {
                                        final prayer = state.prayers[i];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: _PrayerRow(
                                            prayer: prayer,
                                            isNext: i == nextIdx,
                                            nextLabel: loc.nextLabel,
                                            onTap: () => state.togglePrayer(i),
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _StatCard(
                                              value: loc.todayCount(kept),
                                              label: loc.todayLabel,
                                              highlight: kept == 5,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _StatCard(
                                              value: '${state.prayerStreak}',
                                              label: loc.streakLabel,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      _DayProgress(
                                        kept: kept,
                                        label: loc.todaysProgress,
                                        keptLabel: loc.prayersKept(kept),
                                      ),
                                      const SizedBox(height: 16),
                                      GestureDetector(
                                        onTap: () => state.loadPrayerTimes(),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            color: AppColors.tileBg,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                                color: AppColors.tileBorder, width: 1),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.refresh_rounded,
                                                  size: 14,
                                                  color: AppColors.sheetText
                                                      .withValues(alpha: 0.4)),
                                              const SizedBox(width: 6),
                                              Text(
                                                loc.refreshTimes,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: AppColors.sheetText
                                                      .withValues(alpha: 0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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

// ─── Prayer Row ───────────────────────────────────────────────────────────────
class _PrayerRow extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;
  final String nextLabel;
  final VoidCallback onTap;

  const _PrayerRow({
    required this.prayer,
    required this.isNext,
    required this.nextLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: prayer.prayed
              ? AppColors.green.withValues(alpha: 0.08)
              : isNext
                  ? AppColors.lime.withValues(alpha: 0.08)
                  : AppColors.tileBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: prayer.prayed
                ? AppColors.green.withValues(alpha: 0.25)
                : isNext
                    ? AppColors.lime.withValues(alpha: 0.3)
                    : AppColors.tileBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: prayer.prayed ? AppColors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: prayer.prayed
                      ? AppColors.green
                      : isNext
                          ? AppColors.lime
                          : AppColors.tileBorder,
                  width: 1.5,
                ),
              ),
              child: prayer.prayed
                  ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: prayer.prayed
                          ? AppColors.sheetText.withValues(alpha: 0.35)
                          : AppColors.sheetText,
                      decoration: prayer.prayed ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.sheetText.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prayer.arabicName,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sheetText.withValues(alpha: 0.35)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayer.formattedTime,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: prayer.prayed
                        ? AppColors.sheetText.withValues(alpha: 0.3)
                        : AppColors.sheetText.withValues(alpha: 0.6),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (isNext)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        nextLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: AppColors.limeDim,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _StatCard({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tileBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tileBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: highlight
                  ? const Color.fromARGB(255, 204, 255, 165)
                  : AppColors.sheetText,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.sheetText.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Day Progress ─────────────────────────────────────────────────────────────
class _DayProgress extends StatelessWidget {
  final int kept;
  final String label;
  final String keptLabel;

  const _DayProgress({
    required this.kept,
    required this.label,
    required this.keptLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.tileBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tileBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: AppColors.sheetText.withValues(alpha: 0.4),
                ),
              ),
              Text(
                keptLabel,
                style: TextStyle(
                    fontSize: 11,
                    color: AppColors.sheetText.withValues(alpha: 0.5)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: kept / 5,
              backgroundColor: AppColors.tileBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                kept == 5
                    ? const Color.fromARGB(255, 204, 249, 100)
                    : AppColors.lime,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error Card ───────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.tileBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                color: AppColors.sheetText.withValues(alpha: 0.3), size: 28),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.sheetText.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onRetry,
              child: const Text(
                'Retry',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.lime,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}