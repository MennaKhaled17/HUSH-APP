import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/focus_session.dart';
import '../core/app_colors.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final loc = state.loc;

        if (state.timerRunning) {
          return _TimerView(state: state);
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.focusModeLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              letterSpacing: 3,
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.chooseMode,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AddModeButton(
                      label: loc.newMode,
                      onTap: () => _showAddModeSheet(context, state),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.focusModes.length,
                  itemBuilder: (ctx, i) => _ModeRow(
                    mode: state.focusModes[i],
                    isSelected: _selectedIndex == i,
                    onTap: () => setState(() => _selectedIndex = i),
                    onDelete: state.focusModes[i].isCustom
                        ? () => state.removeFocusMode(i)
                        : null,
                  ),
                ),
              ),

              if (state.focusModes.isNotEmpty)
                _ModeDetailPanel(
                  mode: state.focusModes[_selectedIndex < state.focusModes.length
                      ? _selectedIndex
                      : 0],
                  modeIndex: _selectedIndex,
                  state: state,
                  onStart: () {
                    final idx = _selectedIndex < state.focusModes.length
                        ? _selectedIndex
                        : 0;
                    state.startFocus(state.focusModes[idx]);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddModeSheet(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddModeSheet(
        state: state,
        onAdd: (mode) {
          state.addFocusMode(mode);
          setState(() => _selectedIndex = state.focusModes.length - 1);
        },
        existingCount: state.focusModes.length,
      ),
    );
  }
}

// ─── Mode Row ─────────────────────────────────────────────────────────────────

class _ModeRow extends StatelessWidget {
  final FocusMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _ModeRow({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.border, width: 0.5)
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 3,
              height: isSelected ? 32 : 22,
              decoration: BoxDecoration(
                color: isSelected ? mode.color : mode.color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${mode.defaultMinutes}m',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${mode.blockedApps.length} blocked',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
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

// ─── Detail Panel ─────────────────────────────────────────────────────────────

class _ModeDetailPanel extends StatelessWidget {
  final FocusMode mode;
  final int modeIndex;
  final AppState state;
  final VoidCallback onStart;

  const _ModeDetailPanel({
    required this.mode,
    required this.modeIndex,
    required this.state,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final loc = state.loc;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: mode.bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mode.color.withOpacity(0.2), width: 0.5),
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
                      mode.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: mode.color),
                    ),
                    const SizedBox(height: 2),
                    Text(mode.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${mode.defaultMinutes}m',
                style: TextStyle(fontSize: 14, color: mode.color.withOpacity(0.6), fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: mode.color.withOpacity(0.1), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.blockedApps,
                      style: const TextStyle(fontSize: 9, letterSpacing: 2, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.blockedApps.isEmpty
                          ? loc.noAppsBlocked
                          : mode.blockedApps.take(2).join(', ') +
                              (mode.blockedApps.length > 2 ? ' +${mode.blockedApps.length - 2}' : ''),
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showBlockedAppsSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: mode.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: mode.color.withOpacity(0.25), width: 0.5),
                  ),
                  child: Text(loc.edit, style: TextStyle(fontSize: 12, color: mode.color)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: onStart,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: mode.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.startMode(mode.name, mode.defaultMinutes),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.base, letterSpacing: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBlockedAppsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BlockedAppsSheet(mode: mode, modeIndex: modeIndex, state: state),
    );
  }
}

// ─── Timer View ───────────────────────────────────────────────────────────────

class _TimerView extends StatelessWidget {
  final AppState state;
  const _TimerView({required this.state});

  @override
  Widget build(BuildContext context) {
    final mode = state.activeSession!.mode;
    final loc = state.loc;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  loc.modeSession(mode.name.toUpperCase()),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 3,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const Spacer(),

            SizedBox(
              width: 210,
              height: 210,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(210, 210),
                    painter: _RingPainter(progress: state.timerProgress, color: mode.color),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.timerDisplay,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        state.timerPaused ? loc.paused : loc.focusing,
                        style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 2.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Text(
              mode.name,
              style: TextStyle(fontSize: 13, letterSpacing: 3, color: mode.color),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: _TimerButton(
                    label: state.timerPaused ? loc.resumeBtn : loc.pauseBtn,
                    color: mode.color,
                    onTap: state.timerPaused ? state.resumeFocus : state.pauseFocus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimerButton(
                    label: loc.endBtn,
                    color: AppColors.red,
                    onTap: state.stopFocus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              loc.prayerWillPause,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.border
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

class _TimerButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _TimerButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 0.5),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color),
        ),
      ),
    );
  }
}

// ─── Add Mode Button ──────────────────────────────────────────────────────────

class _AddModeButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddModeButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ─── Add Mode Sheet ───────────────────────────────────────────────────────────

class _AddModeSheet extends StatefulWidget {
  final AppState state;
  final void Function(FocusMode) onAdd;
  final int existingCount;

  const _AddModeSheet({
    required this.state,
    required this.onAdd,
    required this.existingCount,
  });

  @override
  State<_AddModeSheet> createState() => _AddModeSheetState();
}

class _AddModeSheetState extends State<_AddModeSheet> {
  final _nameController = TextEditingController();
  int _selectedDuration = 25;
  final List<String> _selectedApps = [];
  final List<int> _durations = [15, 25, 50, 60, 90, 120];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.state.loc;
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 3,
              decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(loc.addModeTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            maxLength: 20,
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: loc.modeName,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              counterText: '',
              filled: true,
              fillColor: AppColors.surface2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.gold, width: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _durations.map((d) {
              final sel = _selectedDuration == d;
              return GestureDetector(
                onTap: () => setState(() => _selectedDuration = d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.goldBg : AppColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppColors.gold : AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    '$d min',
                    style: TextStyle(fontSize: 12, color: sel ? AppColors.gold : AppColors.textSecondary),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          Text(loc.blockAppsTitle, style: const TextStyle(fontSize: 9, letterSpacing: 2.5, color: AppColors.textMuted)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FocusMode.allApps.map((app) {
              final sel = _selectedApps.contains(app);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (sel) _selectedApps.remove(app);
                    else _selectedApps.add(app);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.greenBg : AppColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? AppColors.green.withOpacity(0.4) : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    app,
                    style: TextStyle(
                      fontSize: 12,
                      color: sel ? AppColors.green : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          GestureDetector(
            onTap: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              final colors = FocusMode.customColors;
              final color = colors[widget.existingCount % colors.length];
              widget.onAdd(FocusMode(
                name: name,
                description: 'Custom mode',
                defaultMinutes: _selectedDuration,
                color: color,
                bgColor: color.withOpacity(0.08),
                blockedApps: List.from(_selectedApps),
                isCustom: true,
              ));
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
              child: Text(
                loc.addModeBtn,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.base),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Blocked Apps Sheet ───────────────────────────────────────────────────────

class _BlockedAppsSheet extends StatefulWidget {
  final FocusMode mode;
  final int modeIndex;
  final AppState state;

  const _BlockedAppsSheet({
    required this.mode,
    required this.modeIndex,
    required this.state,
  });

  @override
  State<_BlockedAppsSheet> createState() => _BlockedAppsSheetState();
}

class _BlockedAppsSheetState extends State<_BlockedAppsSheet> {
  late List<String> _blocked;

  @override
  void initState() {
    super.initState();
    _blocked = List.from(widget.mode.blockedApps);
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.state.loc;
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 3,
              decoration: BoxDecoration(color: AppColors.border2, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${loc.blockedApps} · ${widget.mode.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(loc.tapToToggle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FocusMode.allApps.map((app) {
              final sel = _blocked.contains(app);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (sel) _blocked.remove(app);
                    else _blocked.add(app);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? widget.mode.color.withOpacity(0.1) : AppColors.surface2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? widget.mode.color.withOpacity(0.4) : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    app,
                    style: TextStyle(
                      fontSize: 12,
                      color: sel ? widget.mode.color : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              widget.state.updateModeBlockedApps(widget.modeIndex, _blocked);
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: widget.mode.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loc.save,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.base),
              ),
            ),
          ),
        ],
      ),
    );
  }
}