import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/prayer_time.dart';
import '../core/app_colors.dart';

class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final loc = state.loc;
        final kept = state.prayersKeptToday;
        final nextIdx = state.nextPrayerIndex;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  loc.prayerTracker,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.todaysPrayers,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.formatDate(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 24),

                if (state.prayersLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 1.5,
                      ),
                    ),
                  )
                else if (state.prayersError != null)
                  _ErrorCard(
                    message: state.prayersError!,
                    retryLabel: loc.retry,
                    onRetry: () => state.loadPrayerTimes(),
                  )
                else ...[
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
                  _DayProgress(kept: kept, label: loc.todaysProgress, keptLabel: loc.prayersKept(kept)),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => state.loadPrayerTimes(),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            loc.refreshTimes,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
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
              ? AppColors.greenBg
              : isNext
                  ? AppColors.goldBg
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: prayer.prayed
                ? const Color(0xFF1A3B22)
                : isNext
                    ? AppColors.goldBorder
                    : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Check circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: prayer.prayed ? AppColors.green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: prayer.prayed
                      ? AppColors.green
                      : isNext
                          ? AppColors.gold
                          : AppColors.border2,
                  width: 1.5,
                ),
              ),
              child: prayer.prayed
                  ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: prayer.prayed
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                      decoration: prayer.prayed
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    prayer.arabicName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Time + NEXT tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayer.formattedTime,
                  style: TextStyle(
                    fontSize: 13,
                    color: prayer.prayed
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (isNext)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        nextLabel,
                        style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.5,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w500,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.green : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 2,
              color: AppColors.textMuted,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                keptLabel,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: kept / 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                kept == 5 ? AppColors.green : AppColors.gold,
              ),
              minHeight: 5,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3B1A1A), width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted, size: 28),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              retryLabel,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}