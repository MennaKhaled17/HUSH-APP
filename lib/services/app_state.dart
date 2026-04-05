import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_time.dart';
import '../models/focus_session.dart';
import '../core/app_localizations.dart';
import 'prayer_service.dart';

class AppState extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();

  // ── Language ──────────────────────────────────────────────────
  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;
  AppLocalizations get loc => AppLocalizations(_language);

  void setLanguage(AppLanguage lang) {
    _language = lang;
    _saveSettings();
    notifyListeners();
  }

  // ── Prayer state ──────────────────────────────────────────────
  List<PrayerTime> prayers = [];
  bool prayersLoading = false;
  String? prayersError;
  int prayerStreak = 0;

  // ── Focus state ───────────────────────────────────────────────
  List<FocusMode> focusModes = List.from(FocusMode.defaults);
  FocusSession? activeSession;
  bool sessionPausedForPrayer = false;

  int _timerSeconds = 0;
  int _timerTotal = 0;
  Timer? _timer;
  bool _timerPaused = false;

  // ── Settings ──────────────────────────────────────────────────
  int gracePeriodMinutes = 5;
  int breakDurationMinutes = 5;
  bool playAzan = true;
  bool emergencyBypass = true;
  bool pomodoroMode = false;
  bool blockNotifications = true;
  bool allowCalls = true;
  bool weeklyReport = true;
  String calculationMethod = 'Egyptian';

  // ── Stats ─────────────────────────────────────────────────────
  int totalFocusMinutes = 0;
  int weeklyPrayersKept = 0;

  // ── Getters ───────────────────────────────────────────────────
  int get timerSeconds => _timerSeconds;
  int get timerTotal => _timerTotal;
  bool get timerPaused => _timerPaused;
  bool get timerRunning => activeSession != null && _timer != null;

  double get timerProgress =>
      _timerTotal > 0 ? _timerSeconds / _timerTotal : 0.0;

  String get timerDisplay {
    final m = (_timerSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_timerSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  PrayerTime? get nextPrayer => _prayerService.getNextPrayer(prayers);
  int get nextPrayerIndex => _prayerService.getNextPrayerIndex(prayers);
  int get prayersKeptToday => prayers.where((p) => p.prayed).length;

  // ── Init ──────────────────────────────────────────────────────
  Future<void> init() async {
    await _loadSettings();
    await loadPrayerTimes();
  }

  // ── Prayer ────────────────────────────────────────────────────
  Future<void> loadPrayerTimes({double lat = 30.0444, double lng = 31.2357}) async {
    prayersLoading = true;
    prayersError = null;
    notifyListeners();

    try {
      final methodId = PrayerService.methods[calculationMethod] ?? 5;
      prayers = await _prayerService.fetchPrayerTimes(
        latitude: lat,
        longitude: lng,
        method: methodId,
      );
      await _loadPrayerStatus();
    } catch (e) {
      prayersError = loc.couldNotLoad;
    }

    prayersLoading = false;
    notifyListeners();
  }

  void markPrayer(int index, bool prayed) {
    if (index < 0 || index >= prayers.length) return;
    prayers[index].prayed = prayed;
    _savePrayerStatus();
    notifyListeners();
  }

  void togglePrayer(int index) {
    if (index < 0 || index >= prayers.length) return;
    prayers[index].prayed = !prayers[index].prayed;
    _savePrayerStatus();
    notifyListeners();
  }

  // ── Focus ─────────────────────────────────────────────────────
  void startFocus(FocusMode mode) {
    _timer?.cancel();
    activeSession = FocusSession(mode: mode, startTime: DateTime.now());
    _timerTotal = mode.defaultMinutes * 60;
    _timerSeconds = _timerTotal;
    _timerPaused = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_timerPaused && _timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
        if (_timerSeconds == 0) _onSessionComplete();
      }
    });
    notifyListeners();
  }

  void pauseFocus() { _timerPaused = true; notifyListeners(); }
  void resumeFocus() { _timerPaused = false; notifyListeners(); }

  void stopFocus() {
    _timer?.cancel();
    _timer = null;
    activeSession?.endTime = DateTime.now();
    activeSession = null;
    _timerSeconds = 0;
    _timerTotal = 0;
    _timerPaused = false;
    notifyListeners();
  }

  void _onSessionComplete() {
    _timer?.cancel();
    _timer = null;
    if (activeSession != null) {
      totalFocusMinutes += activeSession!.mode.defaultMinutes;
      activeSession!.completed = true;
      activeSession!.endTime = DateTime.now();
    }
    activeSession = null;
    notifyListeners();
  }

  // ── Custom modes ──────────────────────────────────────────────
  void addFocusMode(FocusMode mode) { focusModes.add(mode); notifyListeners(); }

  void updateModeBlockedApps(int index, List<String> apps) {
    if (index < 0 || index >= focusModes.length) return;
    focusModes[index].blockedApps = apps;
    notifyListeners();
  }

  void removeFocusMode(int index) {
    if (index < 0 || index >= focusModes.length) return;
    if (!focusModes[index].isCustom) return;
    focusModes.removeAt(index);
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────
  void updateSetting(String key, dynamic value) {
    switch (key) {
      case 'gracePeriod': gracePeriodMinutes = value; break;
      case 'breakDuration': breakDurationMinutes = value; break;
      case 'playAzan': playAzan = value; break;
      case 'emergencyBypass': emergencyBypass = value; break;
      case 'pomodoroMode': pomodoroMode = value; break;
      case 'blockNotifications': blockNotifications = value; break;
      case 'allowCalls': allowCalls = value; break;
      case 'weeklyReport': weeklyReport = value; break;
      case 'calculationMethod':
        calculationMethod = value;
        loadPrayerTimes();
        break;
    }
    _saveSettings();
    notifyListeners();
  }

  void resetAllData() {
    prayerStreak = 0;
    totalFocusMinutes = 0;
    weeklyPrayersKept = 0;
    for (final p in prayers) { p.prayed = false; }
    _savePrayerStatus();
    _saveSettings();
    notifyListeners();
  }

  // ── Persistence ───────────────────────────────────────────────
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gracePeriod', gracePeriodMinutes);
    await prefs.setInt('breakDuration', breakDurationMinutes);
    await prefs.setBool('playAzan', playAzan);
    await prefs.setBool('emergencyBypass', emergencyBypass);
    await prefs.setBool('pomodoroMode', pomodoroMode);
    await prefs.setBool('blockNotifications', blockNotifications);
    await prefs.setBool('allowCalls', allowCalls);
    await prefs.setBool('weeklyReport', weeklyReport);
    await prefs.setString('calculationMethod', calculationMethod);
    await prefs.setInt('prayerStreak', prayerStreak);
    await prefs.setInt('totalFocusMinutes', totalFocusMinutes);
    await prefs.setString('language', _language == AppLanguage.arabic ? 'ar' : 'en');
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    gracePeriodMinutes = prefs.getInt('gracePeriod') ?? 5;
    breakDurationMinutes = prefs.getInt('breakDuration') ?? 5;
    playAzan = prefs.getBool('playAzan') ?? true;
    emergencyBypass = prefs.getBool('emergencyBypass') ?? true;
    pomodoroMode = prefs.getBool('pomodoroMode') ?? false;
    blockNotifications = prefs.getBool('blockNotifications') ?? true;
    allowCalls = prefs.getBool('allowCalls') ?? true;
    weeklyReport = prefs.getBool('weeklyReport') ?? true;
    calculationMethod = prefs.getString('calculationMethod') ?? 'Egyptian';
    prayerStreak = prefs.getInt('prayerStreak') ?? 0;
    totalFocusMinutes = prefs.getInt('totalFocusMinutes') ?? 0;
    final lang = prefs.getString('language') ?? 'en';
    _language = lang == 'ar' ? AppLanguage.arabic : AppLanguage.english;
  }

  Future<void> _savePrayerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'prayers_${today.year}_${today.month}_${today.day}';
    final status = prayers.map((p) => p.prayed ? '1' : '0').join(',');
    await prefs.setString(key, status);
  }

  Future<void> _loadPrayerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final key = 'prayers_${today.year}_${today.month}_${today.day}';
    final status = prefs.getString(key);
    if (status != null) {
      final parts = status.split(',');
      for (int i = 0; i < prayers.length && i < parts.length; i++) {
        prayers[i].prayed = parts[i] == '1';
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}