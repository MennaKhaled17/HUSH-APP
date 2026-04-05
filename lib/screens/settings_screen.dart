import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final loc = state.loc;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  loc.preferences,
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.settingsTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),

                // ── Language ────────────────────────────────────────────────
               _SectionTitle(title: loc.languageLabel.toUpperCase()),
                _SettingsCard(
                  children: [
                    _LanguageRow(
                      label: loc.languageLabel,
                      subtitle: loc.languageSub,
                      currentLang: state.language,
                      onChanged: (lang) => state.setLanguage(lang),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Prayer ──────────────────────────────────────────────────
                _SectionTitle(title: loc.prayerSection),
                _SettingsCard(
                  children: [
                    _SelectRow(
                      label: loc.calcMethod,
                      subtitle: loc.calcMethodSub,
                      value: state.calculationMethod,
                      options: const ['Egyptian', 'MWL', 'ISNA', 'Umm al-Qura'],
                      onChanged: (v) => state.updateSetting('calculationMethod', v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: loc.playAzan,
                      subtitle: loc.playAzanSub,
                      value: state.playAzan,
                      onChanged: (v) => state.updateSetting('playAzan', v),
                    ),
                    _Divider(),
                    _StepperRow(
                      label: loc.gracePeriod,
                      subtitle: loc.gracePeriodSub,
                      value: state.gracePeriodMinutes,
                      min: 0,
                      max: 30,
                      onChanged: (v) => state.updateSetting('gracePeriod', v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: loc.emergencyBypass,
                      subtitle: loc.emergencyBypassSub,
                      value: state.emergencyBypass,
                      onChanged: (v) => state.updateSetting('emergencyBypass', v),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Focus ───────────────────────────────────────────────────
                _SectionTitle(title: loc.focusSection),
                _SettingsCard(
                  children: [
                    _ToggleRow(
                      label: loc.pomodoroMode,
                      subtitle: loc.pomodoroModeSub,
                      value: state.pomodoroMode,
                      onChanged: (v) => state.updateSetting('pomodoroMode', v),
                    ),
                    _Divider(),
                    _StepperRow(
                      label: loc.breakDuration,
                      subtitle: loc.breakDurationSub,
                      value: state.breakDurationMinutes,
                      min: 1,
                      max: 30,
                      onChanged: (v) => state.updateSetting('breakDuration', v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: loc.blockNotifications,
                      subtitle: loc.blockNotifSub,
                      value: state.blockNotifications,
                      onChanged: (v) => state.updateSetting('blockNotifications', v),
                    ),
                    _Divider(),
                    _ToggleRow(
                      label: loc.allowCalls,
                      subtitle: loc.allowCallsSub,
                      value: state.allowCalls,
                      onChanged: (v) => state.updateSetting('allowCalls', v),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Stats ───────────────────────────────────────────────────
                _SectionTitle(title: loc.statsSection),
                _SettingsCard(
                  children: [
                    _ToggleRow(
                      label: loc.weeklyReport,
                      subtitle: loc.weeklyReportSub,
                      value: state.weeklyReport,
                      onChanged: (v) => state.updateSetting('weeklyReport', v),
                    ),
                    _Divider(),
                    _InfoRow(
                      label: loc.totalFocusTime,
                      value: _formatMinutes(state.totalFocusMinutes),
                    ),
                    _Divider(),
                    _DangerRow(
                      label: loc.resetAllData,
                      subtitle: loc.resetAllDataSub,
                      resetLabel: loc.reset,
                      onTap: () => _confirmReset(context, state, loc),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'HUSH',
                        style: const TextStyle(
                          fontSize: 16,
                          letterSpacing: 6,
                          color: AppColors.border2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        loc.versionLine,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.tagline,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatMinutes(int min) {
    if (min < 60) return '${min}m';
    final h = min ~/ 60;
    final m = min % 60;
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }

  void _confirmReset(BuildContext context, AppState state, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        title: Text(
          loc.resetConfirmTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          loc.resetConfirmBody,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              state.resetAllData();
              Navigator.pop(ctx);
            },
            child: Text(loc.reset, style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Components ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 9,
          letterSpacing: 2.5,
          color: AppColors.textMuted,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.border, height: 1);
  }
}

class _LanguageRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final AppLanguage currentLang;
  final ValueChanged<AppLanguage> onChanged;

  const _LanguageRow({
    required this.label,
    required this.subtitle,
    required this.currentLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border2, width: 0.5),
            ),
            child: Row(
              children: [
                _LangChip(
                  label: 'EN',
                  selected: currentLang == AppLanguage.english,
                  onTap: () => onChanged(AppLanguage.english),
                ),
                _LangChip(
                  label: 'عربي',
                  selected: currentLang == AppLanguage.arabic,
                  onTap: () => onChanged(AppLanguage.arabic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LangChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.base : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 27,
              decoration: BoxDecoration(
                color: value ? AppColors.gold : AppColors.border2,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 21,
                  height: 21,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: value ? AppColors.base : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _StepBtn(icon: Icons.remove, onTap: value > min ? () => onChanged(value - 1) : null),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _StepBtn(icon: Icons.add, onTap: value < max ? () => onChanged(value + 1) : null),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppColors.border2, width: 0.5),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null ? AppColors.textSecondary : AppColors.textMuted,
        ),
      ),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SelectRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
  color: Colors.transparent,
  child: DropdownButton<String>(
    value: value,
    onChanged: (v) { if (v != null) onChanged(v); },
    dropdownColor: AppColors.surface2,
    underline: const SizedBox.shrink(),
    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMuted),
    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'DMSans'),
    items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
  ),
),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          ),
          Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

class _DangerRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final String resetLabel;
  final VoidCallback onTap;

  const _DangerRow({
    required this.label,
    required this.subtitle,
    required this.resetLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.red)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              resetLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}