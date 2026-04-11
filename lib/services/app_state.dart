import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/data/latest.dart' as tz;
import '../models/prayer_time.dart';
import '../models/focus_session.dart';
import '../core/app_localizations.dart';
import 'prayer_service.dart';
import 'blocker_service.dart';
import 'platform_service.dart';

class AppState extends ChangeNotifier {
  final PrayerService _prayerService = PrayerService();

  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;
  AppLocalizations get loc => AppLocalizations(_language);

  void setLanguage(AppLanguage lang) {
    _language = lang;
    _saveSettings();
    notifyListeners();
  }

  List<PrayerTime> prayers = [];
  bool prayersLoading = false;
  String? prayersError;
  int prayerStreak = 0;
  Timer? _prayerCheckTimer;

  List<FocusMode> focusModes = List.from(FocusMode.defaults);
  FocusSession? activeSession;
  bool sessionPausedForPrayer = false;

  int _timerSeconds = 0;
  int _timerTotal = 0;
  Timer? _timer;
  bool _timerPaused = false;

  int _pomodoroRound = 0;
  bool _onBreak = false;
  bool get onBreak => _onBreak;
  int get pomodoroRound => _pomodoroRound;

  int gracePeriodMinutes = 5;
  int breakDurationMinutes = 5;
  bool playAzan = true;
  bool emergencyBypass = true;
  bool pomodoroMode = false;
  bool blockNotifications = true;
  bool allowCalls = true;
  bool weeklyReport = true;
  String calculationMethod = 'Egyptian';

  int totalFocusMinutes = 0;
  int weeklyPrayersKept = 0;

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

  int get streakDays => prayerStreak;
  FocusMode? get activeFocusMode => activeSession?.mode;

  void startTimer() {
    if (focusModes.isNotEmpty && !timerRunning) {
      startFocus(focusModes.first);
    }
  }

  Future<void> init() async {
    if (!kIsWeb) {
      tz.initializeTimeZones();
      await PlatformService.initNotifications();
    }
    await _loadSettings();
    await _loadFocusModes();
    await loadPrayerTimes();
    if (!kIsWeb) {
      await _schedulePrayerNotifications();
    }
    _startPrayerCheckTimer();
  }

  Future<void> _schedulePrayerNotifications() async {
    if (kIsWeb) return;
    await PlatformService.cancelAllNotifications();
    for (final prayer in prayers) {
      if (prayer.time.isAfter(DateTime.now())) {
        await PlatformService.schedulePrayerNotification(
          id: prayer.name.hashCode,
          title: playAzan ? '🕌 ${prayer.name}' : 'Prayer Time',
          body: '${prayer.name} time has arrived',
          scheduledTime: prayer.time,
        );
        final graceTime =
            prayer.time.add(Duration(minutes: gracePeriodMinutes));
        if (graceTime.isAfter(DateTime.now())) {
          await PlatformService.schedulePrayerNotification(
            id: prayer.name.hashCode + 1000,
            title: 'Still time to pray 🙏',
            body: "Don't miss ${prayer.name} — grace period ending soon.",
            scheduledTime: graceTime,
          );
        }
      }
    }
  }

  void _startPrayerCheckTimer() {
    _prayerCheckTimer?.cancel();
    _prayerCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkPrayerTime();
    });
  }

  void _checkPrayerTime() {
    final now = DateTime.now();
    for (final prayer in prayers) {
      final diff = now.difference(prayer.time);
      if (diff.inSeconds >= 0 && diff.inSeconds < 30) {
        _onPrayerTimeReached(prayer);
      }
      if (diff.inMinutes == gracePeriodMinutes && diff.inSeconds < 30) {
        _onGracePeriodEnd(prayer);
      }
    }
  }

  void _onPrayerTimeReached(PrayerTime prayer) {
    if (playAzan && !kIsWeb) PlatformService.playAzan();
    if (timerRunning && !_timerPaused) {
      sessionPausedForPrayer = true;
      pauseFocus();
      _sendNotification(
          'Prayer Time', '${prayer.name} time — focus session paused.');
    }
  }

  void _onGracePeriodEnd(PrayerTime prayer) {
    _sendNotification(
        'Still time to pray', "Don't miss ${prayer.name} — grace period ending.");
  }

  Future<void> _sendNotification(String title, String body) async {
    if (kIsWeb) return;
    await PlatformService.sendNotification(title: title, body: body);
  }

  Future<void> loadPrayerTimes() async {
    prayersLoading = true;
    prayersError = null;
    notifyListeners();
    try {
      double lat = 30.0444;
      double lng = 31.2357;
      if (!kIsWeb) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.low),
          ).timeout(const Duration(seconds: 10));
          lat = position.latitude;
          lng = position.longitude;
        }
      }
      final methodId = PrayerService.methods[calculationMethod] ?? 5;
      prayers = await _prayerService.fetchPrayerTimes(
          latitude: lat, longitude: lng, method: methodId);
      await _loadPrayerStatus();
    } catch (e) {
      prayersError = loc.couldNotLoad;
    }
    prayersLoading = false;
    notifyListeners();
  }

  void togglePrayer(int index) {
    if (index < 0 || index >= prayers.length) return;
    final prayer = prayers[index];
    if (prayer.time.isAfter(DateTime.now())) return;
    prayer.prayed = !prayer.prayed;
    _updateStreak();
    _savePrayerStatus();
    notifyListeners();
  }

  void markPrayer(int index, bool prayed) {
    if (index < 0 || index >= prayers.length) return;
    final prayer = prayers[index];
    if (prayer.time.isAfter(DateTime.now())) return;
    prayer.prayed = prayed;
    _updateStreak();
    _savePrayerStatus();
    notifyListeners();
  }

  void _updateStreak() {
    final allPast = prayers.where((p) => p.time.isBefore(DateTime.now()));
    final allPrayed =
        allPast.isNotEmpty && allPast.every((p) => p.prayed);
    if (allPrayed && prayersKeptToday == 5) _checkAndIncrementStreak();
    _saveSettings();
  }

  String _todayKey() {
    final now = DateTime.now();
    return 'streak_${now.year}_${now.month}_${now.day}';
  }

  Future<void> _checkAndIncrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey();
    final alreadyCounted = prefs.getBool(key) ?? false;
    if (!alreadyCounted) {
      prayerStreak++;
      await prefs.setBool(key, true);
      await _saveSettings();
      notifyListeners();
    }
  }

  void startFocus(FocusMode mode) {
    _timer?.cancel();
    _pomodoroRound = 1;
    _onBreak = false;
    sessionPausedForPrayer = false;
    activeSession = FocusSession(mode: mode, startTime: DateTime.now());
    _timerTotal = mode.defaultMinutes * 60;
    _timerSeconds = _timerTotal;
    _timerPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_timerPaused && _timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
        if (_timerSeconds == 0) _onSegmentComplete();
      }
    });
    if (!kIsWeb) BlockerService.startBlocking(mode.blockedApps);
    notifyListeners();
  }

  void _onSegmentComplete() {
    _timer?.cancel();
    _timer = null;
    if (!pomodoroMode) {
      _onSessionComplete();
      return;
    }
    if (_onBreak) {
      _onBreak = false;
      _pomodoroRound++;
      _timerTotal = activeSession!.mode.defaultMinutes * 60;
      _timerSeconds = _timerTotal;
      _sendNotification('Break over!', 'Round $_pomodoroRound starting.');
    } else {
      _onBreak = true;
      _timerTotal = breakDurationMinutes * 60;
      _timerSeconds = _timerTotal;
      _sendNotification(
          'Round $_pomodoroRound done!', 'Take a ${breakDurationMinutes}min break.');
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_timerPaused && _timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
        if (_timerSeconds == 0) _onSegmentComplete();
      }
    });
    notifyListeners();
  }

  void _onSessionComplete() {
    if (activeSession != null) {
      totalFocusMinutes += activeSession!.mode.defaultMinutes;
      activeSession!.completed = true;
      activeSession!.endTime = DateTime.now();
    }
    activeSession = null;
    _pomodoroRound = 0;
    _onBreak = false;
    _saveSettings();
    notifyListeners();
  }

  void pauseFocus() {
    _timerPaused = true;
    notifyListeners();
  }

  void resumeFocus() {
    _timerPaused = false;
    sessionPausedForPrayer = false;
    notifyListeners();
  }

  void stopFocus() {
    _timer?.cancel();
    _timer = null;
    activeSession?.endTime = DateTime.now();
    activeSession = null;
    _timerSeconds = 0;
    _timerTotal = 0;
    _timerPaused = false;
    _pomodoroRound = 0;
    _onBreak = false;
    sessionPausedForPrayer = false;
    if (!kIsWeb) BlockerService.stopBlocking();
    notifyListeners();
  }

  void addFocusMode(FocusMode mode) {
    focusModes.add(mode);
    _saveFocusModes();
    notifyListeners();
  }

  void updateModeBlockedApps(int index, List<String> apps) {
    if (index < 0 || index >= focusModes.length) return;
    focusModes[index].blockedApps = apps;
    _saveFocusModes();
    notifyListeners();
  }

  void removeFocusMode(int index) {
    if (index < 0 || index >= focusModes.length) return;
    if (!focusModes[index].isCustom) return;
    focusModes.removeAt(index);
    _saveFocusModes();
    notifyListeners();
  }

  /// Reorders a focus mode from [oldIndex] to [newIndex].
  /// Compatible with [ReorderableListView.onReorder] which passes
  /// a newIndex already accounting for the removal, so we adjust accordingly.
  void reorderFocusMode(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = focusModes.removeAt(oldIndex);
    focusModes.insert(newIndex, item);
    _saveFocusModes();
    notifyListeners();
  }

  void updateSetting(String key, dynamic value) {
    switch (key) {
      case 'gracePeriod':
        gracePeriodMinutes = value as int;
        break;
      case 'breakDuration':
        breakDurationMinutes = value as int;
        break;
      case 'playAzan':
        playAzan = value as bool;
        break;
      case 'emergencyBypass':
        emergencyBypass = value as bool;
        break;
      case 'pomodoroMode':
        pomodoroMode = value as bool;
        break;
      case 'blockNotifications':
        blockNotifications = value as bool;
        break;
      case 'allowCalls':
        allowCalls = value as bool;
        break;
      case 'weeklyReport':
        weeklyReport = value as bool;
        break;
      case 'calculationMethod':
        calculationMethod = value as String;
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
    _pomodoroRound = 0;
    for (final p in prayers) {
      p.prayed = false;
    }
    _savePrayerStatus();
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveFocusModes() async {
    final prefs = await SharedPreferences.getInstance();
    final customModes = focusModes
        .where((m) => m.isCustom)
        .map((m) => jsonEncode({
              'name': m.name,
              'description': m.description,
              'defaultMinutes': m.defaultMinutes,
              'colorValue': m.color.toARGB32(),
              'bgColorValue': m.bgColor.toARGB32(),
              'blockedApps': m.blockedApps,
            }))
        .toList();
    await prefs.setStringList('customModes', customModes);
  }

  Future<void> _loadFocusModes() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('customModes') ?? [];
    final custom = saved.map((s) {
      final m = jsonDecode(s) as Map<String, dynamic>;
      return FocusMode(
        name: m['name'] as String,
        description: m['description'] as String,
        defaultMinutes: m['defaultMinutes'] as int,
        color: Color(m['colorValue'] as int),
        bgColor: Color(m['bgColorValue'] as int),
        blockedApps: List<String>.from(m['blockedApps'] as List),
        isCustom: true,
      );
    }).toList();
    focusModes = [...FocusMode.defaults, ...custom];
  }

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
    await prefs.setString(
        'language', _language == AppLanguage.arabic ? 'ar' : 'en');
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
    await prefs.setString(
        key, prayers.map((p) => p.prayed ? '1' : '0').join(','));
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
    _prayerCheckTimer?.cancel();
    super.dispose();
  }
}