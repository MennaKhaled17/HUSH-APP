import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/app_state.dart';
import 'core/app_colors.dart';
import 'core/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/settings_screen.dart';
import 'package:flutter/foundation.dart';
import 'screens/stats_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ .env not found, using fallback values: $e');
  }

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.sheet,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final appState = AppState();
  try {
    await appState.init();
  } catch (e, stack) {
    assert(() {
      debugPrint('⚠️ AppState.init() failed: $e');
      debugPrint('$stack');
      return true;
    }());
  }

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const HushApp(),
    ),
  );
}

class HushApp extends StatelessWidget {
  const HushApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return MaterialApp(
          title: 'HUSH',
          debugShowCheckedModeBanner: false,
          locale: state.language == AppLanguage.arabic
              ? const Locale('ar')
              : const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.base,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lime,
              surface: AppColors.surface,
            ),
            fontFamily: 'DMSans',
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          home: const RootScreen(),
        );
      },
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  void _switchTab(int index) => setState(() => _currentIndex = index);

  List<Widget> get _screens => [
        _SafeScreen(child: HomeScreen(onTabSwitch: _switchTab)),
        const _SafeScreen(child: FocusScreen()),
        const _SafeScreen(child: PrayerScreen()),
        const _SafeScreen(child: SettingsScreen()),
        const _SafeScreen(child: StatsScreen()),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _HushNavBar(
        currentIndex: _currentIndex,
        onTap: _switchTab,
      ),
    );
  }
}

class _SafeScreen extends StatelessWidget {
  final Widget child;
  const _SafeScreen({required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          return _errorPlaceholder(e.toString());
        }
      },
    );
  }
}

Widget _errorPlaceholder(String message) {
  return Scaffold(
    backgroundColor: const Color(0xFF0D0D0D),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.amber, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong loading this screen.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (kDebugMode)
              Text(
                message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
          ],
        ),
      ),
    ),
  );
}

class _HushNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _HushNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppState>().loc;

    final items = [
      _NavItem(icon: Icons.home_outlined,        label: loc.navHome,     index: 0),
      _NavItem(icon: Icons.adjust_outlined,      label: loc.navFocus,    index: 1),
      _NavItem(icon: Icons.location_on_outlined, label: loc.navPrayer,   index: 2),
      _NavItem(icon: Icons.tune_outlined,        label: loc.navSettings, index: 3),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.tileBorder, width: 1)),
        color: AppColors.sheet,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: items
                .map((item) => Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(item.index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: currentIndex == item.index
                                  ? AppColors.lime
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 8,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w500,
                                color: currentIndex == item.index
                                    ? AppColors.gold
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final int index;
  const _NavItem({required this.icon, required this.label, required this.index});
}