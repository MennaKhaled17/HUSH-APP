import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final loc = state.loc;

        if (state.timerRunning) {
          return _TimerView(state: state);
        }

        return Scaffold(
          backgroundColor: AppColors.base,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Dark hero header ──────────────────────────────
              Container(
                color: AppColors.base,
                padding: EdgeInsets.fromLTRB(
                    22, MediaQuery.of(context).padding.top + 20, 22, 24),
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
                                height: 1.1,
                              ),
                              children: [
                                TextSpan(
                                    text: loc.chooseMode.replaceAll('.', '')),
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
                    // ── Edit / Done toggle ──
                    if (state.focusModes.any((m) => m.isCustom))
                      GestureDetector(
                        onTap: () => setState(() => _editMode = !_editMode),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _editMode
                                ? AppColors.red.withValues(alpha: 0.12)
                                : AppColors.iconBgGray,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _editMode
                                  ? AppColors.red.withValues(alpha: 0.35)
                                  : AppColors.tileBorder,
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _editMode ? Icons.check : Icons.edit_outlined,
                                size: 13,
                                color: _editMode
                                    ? AppColors.red
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _editMode ? loc.done : loc.edit,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _editMode
                                      ? AppColors.red
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    _AddModeButton(
                      label: loc.newMode,
                      onTap: () => _showAddModeSheet(context, state),
                    ),
                  ],
                ),
              ),

              // ── Light sheet with mode list ────────────────────
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.sheet,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Expanded(
                        child: _editMode
                            ? _ReorderableList(
                                state: state,
                                selectedIndex: _selectedIndex,
                                onReorder: (oldIndex, newIndex) {
                                  state.reorderFocusMode(oldIndex, newIndex);
                                  setState(() {
                                    if (_selectedIndex == oldIndex) {
                                      _selectedIndex = newIndex > oldIndex
                                          ? newIndex - 1
                                          : newIndex;
                                    }
                                  });
                                },
                                onDelete: (i) =>
                                    _confirmDelete(context, state, i),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: state.focusModes.length,
                                itemBuilder: (ctx, i) => _SwipeToDeleteRow(
                                  key: ValueKey(state.focusModes[i].name),
                                  mode: state.focusModes[i],
                                  isSelected: _selectedIndex == i,
                                  onTap: () =>
                                      setState(() => _selectedIndex = i),
                                  onDelete: state.focusModes[i].isCustom
                                      ? () => _confirmDelete(
                                          context, state, i)
                                      : null,
                                ),
                              ),
                      ),
                      if (state.focusModes.isNotEmpty && !_editMode)
                        _ModeDetailPanel(
                          mode: state.focusModes[
                              _selectedIndex < state.focusModes.length
                                  ? _selectedIndex
                                  : 0],
                          modeIndex: _selectedIndex < state.focusModes.length
                              ? _selectedIndex
                              : 0,
                          state: state,
                          onStart: () {
                            final idx =
                                _selectedIndex < state.focusModes.length
                                    ? _selectedIndex
                                    : 0;
                            state.startFocus(state.focusModes[idx]);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, AppState state, int index) async {
    if (state.focusModes.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.loc.cantDeleteLastMode),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    final modeName = state.focusModes[index].name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.sheet,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          state.loc.deleteModeTitle,
          style: TextStyle(
              color: AppColors.sheetText, fontWeight: FontWeight.w700),
        ),
        content: Text(
          state.loc.deleteModeMsg(modeName),
          style: TextStyle(
              color: AppColors.sheetText.withValues(alpha: 0.6),
              fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(state.loc.cancel,
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              state.loc.delete,
              style: const TextStyle(
                  color: AppColors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      state.removeFocusMode(index);
      setState(() {
        if (_selectedIndex >= state.focusModes.length) {
          _selectedIndex = state.focusModes.length - 1;
        }
        if (state.focusModes.isEmpty) _editMode = false;
      });
    }
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

// ─── Swipe-to-Delete Row ──────────────────────────────────────────────────────

class _SwipeToDeleteRow extends StatelessWidget {
  final FocusMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _SwipeToDeleteRow({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (onDelete == null) {
      return _ModeRowContent(
          mode: mode, isSelected: isSelected, onTap: onTap);
    }

    return Dismissible(
      key: ValueKey('dismissible_${mode.name}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete?.call();
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.red.withValues(alpha: 0.3), width: 1),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.delete_outline, color: AppColors.red, size: 20),
            SizedBox(height: 3),
            Text('Delete',
                style: TextStyle(
                    fontSize: 10,
                    color: AppColors.red,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
      child: _ModeRowContent(
          mode: mode, isSelected: isSelected, onTap: onTap),
    );
  }
}

// ─── Mode Row Content ─────────────────────────────────────────────────────────

class _ModeRowContent extends StatelessWidget {
  final FocusMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeRowContent({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tileBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: AppColors.tileBorder, width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 3,
              height: isSelected ? 32 : 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? mode.color
                    : mode.color.withValues(alpha: 0.3),
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
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.sheetText
                          : AppColors.sheetText.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.sheetText.withValues(alpha: 0.35)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${mode.defaultMinutes}m',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.sheetText.withValues(alpha: 0.4),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.iconBgGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${mode.blockedApps.length} blocked',
                        style: TextStyle(
                            fontSize: 10,
                            color: AppColors.sheetText
                                .withValues(alpha: 0.4)),
                      ),
                    ),
                    if (mode.isCustom) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.swipe_left,
                        size: 11,
                        color: AppColors.sheetText.withValues(alpha: 0.2),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reorderable List (Edit Mode) ─────────────────────────────────────────────

class _ReorderableList extends StatelessWidget {
  final AppState state;
  final int selectedIndex;
  final void Function(int, int) onReorder;
  final void Function(int) onDelete;

  const _ReorderableList({
    required this.state,
    required this.selectedIndex,
    required this.onReorder,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.focusModes.length,
      onReorder: onReorder,
      proxyDecorator: (child, index, animation) => Material(
        color: Colors.transparent,
        child: ScaleTransition(
          scale: animation.drive(Tween(begin: 1.0, end: 1.03)
              .chain(CurveTween(curve: Curves.easeOut))),
          child: child,
        ),
      ),
      itemBuilder: (ctx, i) {
        final mode = state.focusModes[i];
        return _EditModeRow(
          key: ValueKey('edit_${mode.name}'),
          mode: mode,
          isSelected: selectedIndex == i,
          onDelete: mode.isCustom ? () => onDelete(i) : null,
        );
      },
    );
  }
}

class _EditModeRow extends StatelessWidget {
  final FocusMode mode;
  final bool isSelected;
  final VoidCallback? onDelete;

  const _EditModeRow({
    super.key,
    required this.mode,
    required this.isSelected,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.tileBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tileBorder, width: 1),
      ),
      child: Row(
        children: [
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.red.withValues(alpha: 0.3), width: 1),
                ),
                child: const Icon(Icons.remove, size: 14, color: AppColors.red),
              ),
            )
          else
            Container(
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: AppColors.iconBgGray,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline,
                  size: 13,
                  color: AppColors.sheetText.withValues(alpha: 0.25)),
            ),
          Container(
            width: 3,
            height: 28,
            decoration: BoxDecoration(
              color: mode.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.name,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.sheetText),
                ),
                Text(
                  mode.description,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.sheetText.withValues(alpha: 0.35)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(
              Icons.drag_handle,
              size: 18,
              color: AppColors.sheetText.withValues(alpha: 0.25),
            ),
          ),
        ],
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
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: mode.color.withValues(alpha: 0.2), width: 1),
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
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: mode.color),
                    ),
                    const SizedBox(height: 2),
                    Text(mode.description,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${mode.defaultMinutes}m',
                style: TextStyle(
                    fontSize: 14,
                    color: mode.color.withValues(alpha: 0.6),
                    fontFeatures: const [FontFeature.tabularFigures()]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: mode.color.withValues(alpha: 0.1), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.blockedApps,
                      style: const TextStyle(
                          fontSize: 9,
                          letterSpacing: 2,
                          color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.blockedApps.isEmpty
                          ? loc.noAppsBlocked
                          : mode.blockedApps.take(2).join(', ') +
                              (mode.blockedApps.length > 2
                                  ? ' +${mode.blockedApps.length - 2}'
                                  : ''),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showBlockedAppsSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: mode.color.withValues(alpha: 0.25),
                        width: 0.5),
                  ),
                  child: Text(loc.edit,
                      style: TextStyle(fontSize: 12, color: mode.color)),
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
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  loc.startMode(mode.name, mode.defaultMinutes),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sheetText,
                      letterSpacing: 0.3),
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
      builder: (_) => _BlockedAppsSheet(
          mode: mode, modeIndex: modeIndex, state: state),
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

    return Scaffold(
      backgroundColor: AppColors.base,
      body: SafeArea(
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
                      painter: _RingPainter(
                          progress: state.timerProgress,
                          color: AppColors.lime),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.timerDisplay,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
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
                style: const TextStyle(
                    fontSize: 13, letterSpacing: 3, color: AppColors.lime),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _TimerButton(
                      label:
                          state.timerPaused ? loc.resumeBtn : loc.pauseBtn,
                      color: AppColors.lime,
                      textColor: AppColors.sheetText,
                      onTap: state.timerPaused
                          ? state.resumeFocus
                          : state.pauseFocus,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimerButton(
                      label: loc.endBtn,
                      color: AppColors.red,
                      textColor: Colors.white,
                      onTap: state.stopFocus,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                loc.prayerWillPause,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
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
  final Color textColor;
  final VoidCallback onTap;

  const _TimerButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: color),
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
          color: AppColors.limeBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.limeBorder, width: 0.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.add, size: 13, color: AppColors.lime),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppColors.lime)),
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
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // ✅ FIX: Wrap Column in SingleChildScrollView so content
      // can scroll when the keyboard is open and space is limited
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                    color: AppColors.tileBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(loc.addModeTitle,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.sheetText)),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              maxLength: 20,
              style: TextStyle(fontSize: 14, color: AppColors.sheetText),
              decoration: InputDecoration(
                hintText: loc.modeName,
                hintStyle: TextStyle(
                    color: AppColors.sheetText.withValues(alpha: 0.35)),
                counterText: '',
                filled: true,
                fillColor: AppColors.tileBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.tileBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.tileBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.lime, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.lime : AppColors.tileBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.lime : AppColors.tileBorder,
                          width: 1),
                    ),
                    child: Text(
                      '$d min',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: sel
                              ? AppColors.sheetText
                              : AppColors.sheetText.withValues(alpha: 0.5)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text(loc.blockAppsTitle,
                style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.sheetText.withValues(alpha: 0.4))),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FocusMode.allApps.map((app) {
                final sel = _selectedApps.contains(app);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (sel) {
                        _selectedApps.remove(app);
                      } else {
                        _selectedApps.add(app);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.limeBg : AppColors.tileBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            sel ? AppColors.lime : AppColors.tileBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      app,
                      style: TextStyle(
                        fontSize: 12,
                        color: sel
                            ? AppColors.lime
                            : AppColors.sheetText.withValues(alpha: 0.5),
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
                  bgColor: color.withValues(alpha: 0.08),
                  blockedApps: List.from(_selectedApps),
                  isCustom: true,
                ));
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(14)),
                child: Text(
                  loc.addModeBtn,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sheetText),
                ),
              ),
            ),
          ],
        ),
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
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 36,
      ),
      decoration: const BoxDecoration(
        color: AppColors.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      // ✅ FIX: Same fix applied here for consistency
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                    color: AppColors.tileBorder,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '${loc.blockedApps} · ${widget.mode.name}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.sheetText),
            ),
            const SizedBox(height: 4),
            Text(loc.tapToToggle,
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.sheetText.withValues(alpha: 0.4))),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FocusMode.allApps.map((app) {
                final sel = _blocked.contains(app);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (sel) {
                        _blocked.remove(app);
                      } else {
                        _blocked.add(app);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? widget.mode.color.withValues(alpha: 0.1)
                          : AppColors.tileBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel
                            ? widget.mode.color.withValues(alpha: 0.5)
                            : AppColors.tileBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      app,
                      style: TextStyle(
                        fontSize: 12,
                        color: sel
                            ? widget.mode.color
                            : AppColors.sheetText.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                widget.state
                    .updateModeBlockedApps(widget.modeIndex, _blocked);
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  loc.save,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.sheetText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}