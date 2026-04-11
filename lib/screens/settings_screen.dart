import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../core/app_colors.dart';
import '../core/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
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
        backgroundColor: AppColors.tileBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.tileBorder, width: 1),
        ),
        title: Text(
          loc.resetConfirmTitle,
          style: TextStyle(
              color: AppColors.sheetText,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        content: Text(
          loc.resetConfirmBody,
          style: TextStyle(
              color: AppColors.sheetText.withValues(alpha: 0.55), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel,
                style:
                    TextStyle(color: AppColors.sheetText.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () {
              state.resetAllData();
              Navigator.pop(ctx);
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final loc = state.loc;
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
                          loc.preferences,
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
                                  text: loc.settingsTitle.replaceAll('.', '')),
                              const TextSpan(
                                text: '.',
                                style: TextStyle(color: AppColors.lime),
                              ),
                            ],
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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

                            const SizedBox(height: 20),
                            _SectionTitle(title: loc.prayerSection),
                            _SettingsCard(
                              children: [
                                _SelectRow(
                                  label: loc.calcMethod,
                                  subtitle: loc.calcMethodSub,
                                  value: state.calculationMethod,
                                  options: const [
                                    'Egyptian', 'MWL', 'ISNA', 'Umm al-Qura'
                                  ],
                                  onChanged: (v) =>
                                      state.updateSetting('calculationMethod', v),
                                ),
                                _SheetDivider(),
                                _ToggleRow(
                                  label: loc.playAzan,
                                  subtitle: loc.playAzanSub,
                                  value: state.playAzan,
                                  onChanged: (v) =>
                                      state.updateSetting('playAzan', v),
                                ),
                                _SheetDivider(),
                                _StepperRow(
                                  label: loc.gracePeriod,
                                  subtitle: loc.gracePeriodSub,
                                  value: state.gracePeriodMinutes,
                                  min: 0,
                                  max: 30,
                                  onChanged: (v) =>
                                      state.updateSetting('gracePeriod', v),
                                ),
                                _SheetDivider(),
                                _ToggleRow(
                                  label: loc.emergencyBypass,
                                  subtitle: loc.emergencyBypassSub,
                                  value: state.emergencyBypass,
                                  onChanged: (v) =>
                                      state.updateSetting('emergencyBypass', v),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            _SectionTitle(title: loc.focusSection),
                            _SettingsCard(
                              children: [
                                _ToggleRow(
                                  label: loc.pomodoroMode,
                                  subtitle: loc.pomodoroModeSub,
                                  value: state.pomodoroMode,
                                  onChanged: (v) =>
                                      state.updateSetting('pomodoroMode', v),
                                ),
                                _SheetDivider(),
                                _StepperRow(
                                  label: loc.breakDuration,
                                  subtitle: loc.breakDurationSub,
                                  value: state.breakDurationMinutes,
                                  min: 1,
                                  max: 30,
                                  onChanged: (v) =>
                                      state.updateSetting('breakDuration', v),
                                ),
                                _SheetDivider(),
                                _ToggleRow(
                                  label: loc.blockNotifications,
                                  subtitle: loc.blockNotifSub,
                                  value: state.blockNotifications,
                                  onChanged: (v) => state.updateSetting(
                                      'blockNotifications', v),
                                ),
                                _SheetDivider(),
                                _ToggleRow(
                                  label: loc.allowCalls,
                                  subtitle: loc.allowCallsSub,
                                  value: state.allowCalls,
                                  onChanged: (v) =>
                                      state.updateSetting('allowCalls', v),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            _SectionTitle(title: loc.statsSection),
                            _SettingsCard(
                              children: [
                                _ToggleRow(
                                  label: loc.weeklyReport,
                                  subtitle: loc.weeklyReportSub,
                                  value: state.weeklyReport,
                                  onChanged: (v) =>
                                      state.updateSetting('weeklyReport', v),
                                ),
                                _SheetDivider(),
                                _InfoRow(
                                  label: loc.totalFocusTime,
                                  value: _formatMinutes(state.totalFocusMinutes),
                                ),
                                _SheetDivider(),
                                _DangerRow(
                                  label: loc.resetAllData,
                                  subtitle: loc.resetAllDataSub,
                                  resetLabel: loc.reset,
                                  onTap: () => _confirmReset(context, state, loc),
                                ),
                              ],
                            ),

                            const SizedBox(height: 40),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    'HUSH',
                                    style: TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 6,
                                      color: AppColors.sheetText
                                          .withValues(alpha: 0.15),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    loc.versionLine,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.sheetText
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    loc.tagline,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.sheetText
                                          .withValues(alpha: 0.35),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
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

// ─── Components ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9,
          letterSpacing: 2.5,
          color: AppColors.sheetText.withValues(alpha: 0.4),
          fontWeight: FontWeight.w600,
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
        color: AppColors.tileBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tileBorder, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: children),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: AppColors.tileBorder, height: 1);
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
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sheetText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sheetText.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.iconBgGray,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.tileBorder),
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

  const _LangChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.lime : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.sheetText
                : AppColors.sheetText.withValues(alpha: 0.45),
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
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sheetText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sheetText.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value ? AppColors.lime : AppColors.tileBorder,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: value
                        ? AppColors.sheetText
                        : AppColors.sheetText.withValues(alpha: 0.4),
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
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sheetText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sheetText.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              _StepBtn(
                  icon: Icons.remove,
                  onTap: value > min ? () => onChanged(value - 1) : null),
              SizedBox(
                width: 36,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sheetText,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              _StepBtn(
                  icon: Icons.add,
                  onTap: value < max ? () => onChanged(value + 1) : null),
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
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.iconBgGray,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.tileBorder, width: 1),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap != null
              ? AppColors.sheetText.withValues(alpha: 0.6)
              : AppColors.sheetText.withValues(alpha: 0.2),
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
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sheetText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sheetText.withValues(alpha: 0.4))),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: Colors.transparent,
            child: DropdownButton<String>(
              value: value,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              dropdownColor: AppColors.tileBg,
              underline: const SizedBox.shrink(),
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: AppColors.sheetText.withValues(alpha: 0.4)),
              style: TextStyle(
                  fontSize: 12,
                  color: AppColors.sheetText.withValues(alpha: 0.6),
                  fontFamily: 'DMSans'),
              items: options
                  .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                  .toList(),
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
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sheetText)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  color: AppColors.sheetText.withValues(alpha: 0.5),
                  fontFeatures: const [FontFeature.tabularFigures()])),
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
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.sheetText)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.red)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Text(
              'Reset',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}