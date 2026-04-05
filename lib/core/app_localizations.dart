import 'package:flutter/material.dart';

enum AppLanguage { english, arabic }

class AppLocalizations {
  final AppLanguage language;
  const AppLocalizations(this.language);

  bool get isArabic => language == AppLanguage.arabic;
  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;

  // ── General ───────────────────────────────────────────────────
  String get appName => isArabic ? 'هاش' : 'HUSH';
  String get cancel => isArabic ? 'إلغاء' : 'Cancel';
  String get save => isArabic ? 'حفظ' : 'Save';
  String get reset => isArabic ? 'إعادة ضبط' : 'Reset';
  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';
  String get edit => isArabic ? 'تعديل' : 'Edit';
  String get add => isArabic ? 'إضافة' : 'Add';

  // ── Home ──────────────────────────────────────────────────────
  String get goodMorning   => isArabic ? 'صباح الخير' : 'Good morning';
  String get goodAfternoon => isArabic ? 'مساء الخير' : 'Good afternoon';
  String get goodEvening   => isArabic ? 'مساء النور' : 'Good evening';
  String get heroText      => isArabic ? 'تحكّم في' : 'Own your';
  String get heroAccent    => isArabic ? 'وقتك.' : 'time.';
  String get nextPrayer    => isArabic ? 'الصلاة القادمة' : 'NEXT PRAYER';
  String get untilAzan     => isArabic ? 'حتى الأذان' : 'until azan';
  String get quickFocus    => isArabic ? 'تركيز سريع' : 'QUICK FOCUS';
  String get startSession  => isArabic ? 'ابدأ الجلسة' : 'Start Session';
  String get endSession    => isArabic ? 'إنهاء' : 'End';
  String get noAppsBlocked => isArabic ? 'لا تطبيقات محجوبة' : 'No apps blocked';

  // ── Focus ─────────────────────────────────────────────────────
  String get focusModeLabel  => isArabic ? 'وضع التركيز' : 'FOCUS MODE';
  String get chooseMode      => isArabic ? 'اختر الوضع.' : 'Choose mode.';
  String get newMode         => isArabic ? 'وضع جديد' : 'New mode';
  String get blockedApps     => isArabic ? 'التطبيقات المحجوبة' : 'BLOCKED APPS';
  String get tapToToggle     => isArabic ? 'اضغط للتبديل' : 'Tap to toggle';
  String get focusing        => isArabic ? 'في التركيز' : 'FOCUSING';
  String get paused          => isArabic ? 'متوقف مؤقتاً' : 'PAUSED';
  String get prayerWillPause => isArabic ? 'وقت الصلاة سيوقف هذه الجلسة' : 'Prayer time will pause this session';
  String get sessionLabel    => isArabic ? 'جلسة' : 'SESSION';
  String get blockedLabel    => isArabic ? 'محجوب' : 'blocked';
  String get modeName        => isArabic ? 'اسم الوضع' : 'Mode name (e.g. Reading)';
  String get blockAppsTitle  => isArabic ? 'حجب التطبيقات' : 'BLOCK APPS';
  String get addModeTitle    => isArabic ? 'وضع تركيز جديد' : 'New focus mode';
  String get addModeBtn      => isArabic ? 'إضافة الوضع' : 'Add mode';
  String get pauseBtn        => isArabic ? 'إيقاف مؤقت' : 'Pause';
  String get resumeBtn       => isArabic ? 'استئناف' : 'Resume';
  String get endBtn          => isArabic ? 'إنهاء' : 'End';

  String startMode(String name, int minutes) =>
      isArabic ? 'ابدأ $name · $minutes دقيقة' : 'Start $name · $minutes min';

  String modeSession(String name) =>
      isArabic ? 'جلسة $name' : '$name SESSION';

  String minutesSuffix(int m) => isArabic ? '${m}د' : '${m}m';

  // ── Prayer ────────────────────────────────────────────────────
  String get prayerTracker   => isArabic ? 'متتبع الصلاة' : 'PRAYER TRACKER';
  String get todaysPrayers   => isArabic ? 'صلوات اليوم.' : "Today's prayers.";
  String get todayLabel      => isArabic ? 'اليوم' : 'TODAY';
  String get streakLabel     => isArabic ? 'سلسلة الأيام' : 'DAY STREAK';
  String get todaysProgress  => isArabic ? 'تقدم اليوم' : "TODAY'S PROGRESS";
  String get refreshTimes    => isArabic ? 'تحديث أوقات الصلاة' : 'Refresh prayer times';
  String get nextLabel       => isArabic ? 'التالية' : 'NEXT';
  String get couldNotLoad    => isArabic ? 'تعذّر تحميل أوقات الصلاة' : 'Could not load prayer times';
  String prayersKept(int k)  => isArabic ? '$k من 5 صلوات' : '$k of 5 prayers';
  String todayCount(int k)   => isArabic ? '$k / 5' : '$k / 5';

  // ── Settings ──────────────────────────────────────────────────
  String get preferences        => isArabic ? 'التفضيلات' : 'PREFERENCES';
  String get settingsTitle      => isArabic ? 'الإعدادات.' : 'Settings.';
  String get prayerSection      => isArabic ? 'الصلاة' : 'PRAYER';
  String get focusSection       => isArabic ? 'التركيز' : 'FOCUS';
  String get statsSection       => isArabic ? 'الإحصائيات والبيانات' : 'STATS & DATA';
  String get calcMethod         => isArabic ? 'طريقة الحساب' : 'Calculation method';
  String get calcMethodSub      => isArabic ? 'لدقة أوقات الصلاة' : 'Used for prayer time accuracy';
  String get playAzan           => isArabic ? 'تشغيل الأذان' : 'Play azan';
  String get playAzanSub        => isArabic ? 'صوت عند كل وقت صلاة' : 'Audio at each prayer time';
  String get gracePeriod        => isArabic ? 'فترة السماح' : 'Grace period';
  String get gracePeriodSub     => isArabic ? 'دقائق قبل حجب الهاتف' : 'Minutes before phone blocks';
  String get emergencyBypass    => isArabic ? 'تجاوز الطوارئ' : 'Emergency bypass';
  String get emergencyBypassSub => isArabic ? 'السماح بالتخطي (يُسجَّل دائماً)' : 'Allow skip (always logged)';
  String get pomodoroMode       => isArabic ? 'وضع بومودورو' : 'Pomodoro mode';
  String get pomodoroModeSub    => isArabic ? 'استراحة تلقائية كل 25 دقيقة' : 'Auto-break every 25 min';
  String get breakDuration      => isArabic ? 'مدة الاستراحة' : 'Break duration';
  String get breakDurationSub   => isArabic ? 'دقائق بين الجلسات' : 'Minutes between sessions';
  String get blockNotifications => isArabic ? 'حجب الإشعارات' : 'Block notifications';
  String get blockNotifSub      => isArabic ? 'إسكات الكل أثناء التركيز' : 'Silence all during focus';
  String get allowCalls         => isArabic ? 'السماح بالمكالمات' : 'Allow calls';
  String get allowCallsSub      => isArabic ? 'مكالمات الطوارئ تمر' : 'Emergency calls pass through';
  String get weeklyReport       => isArabic ? 'التقرير الأسبوعي' : 'Weekly report';
  String get weeklyReportSub    => isArabic ? 'إشعار ملخص الأحد' : 'Sunday summary notification';
  String get totalFocusTime     => isArabic ? 'إجمالي وقت التركيز' : 'Total focus time';
  String get resetAllData       => isArabic ? 'إعادة ضبط كل البيانات' : 'Reset all data';
  String get resetAllDataSub    => isArabic ? 'مسح كل الإحصائيات والسلاسل' : 'Clear all stats and streaks';
  String get resetConfirmTitle  => isArabic ? 'إعادة ضبط كل البيانات؟' : 'Reset all data?';
  String get resetConfirmBody   => isArabic
      ? 'سيؤدي هذا إلى مسح جميع الإحصائيات والسلاسل وسجل الصلاة. لا يمكن التراجع عن هذا.'
      : 'This will clear all stats, streaks, and prayer history. This cannot be undone.';
  String get languageLabel      => isArabic ? 'اللغة' : 'Language';
  String get languageSub        => isArabic ? 'عربي / English' : 'English / عربي';
  String get versionLine        => isArabic ? 'الإصدار 0.1.0 · القاهرة، مصر' : 'v0.1.0 · Cairo, Egypt';
  String get tagline            => isArabic ? 'أسكت الضجيج. أجب النداء.' : 'Block the noise. Answer the call.';

  // ── Nav ───────────────────────────────────────────────────────
  String get navHome     => isArabic ? 'الرئيسية' : 'HOME';
  String get navFocus    => isArabic ? 'التركيز' : 'FOCUS';
  String get navPrayer   => isArabic ? 'الصلاة' : 'PRAYER';
  String get navSettings => isArabic ? 'الإعدادات' : 'SETTINGS';

  // ── Days / Months ─────────────────────────────────────────────
  String dayName(int weekday) {
    const en = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const ar = ['الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
    return isArabic ? ar[weekday - 1] : en[weekday - 1];
  }

  String monthName(int month) {
    const en = ['January','February','March','April','May','June',
                'July','August','September','October','November','December'];
    const ar = ['يناير','فبراير','مارس','أبريل','مايو','يونيو',
                'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return isArabic ? ar[month - 1] : en[month - 1];
  }

  String formatDate(DateTime d) {
    if (isArabic) {
      return '${dayName(d.weekday)}، ${d.day} ${monthName(d.month)} ${d.year}';
    }
    return '${dayName(d.weekday)}, ${d.day} ${monthName(d.month)} ${d.year}';
  }
}