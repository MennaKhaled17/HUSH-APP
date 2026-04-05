import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/app_state.dart';
import 'core/app_colors.dart';
import 'core/app_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/focus_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.base,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final appState = AppState();
  await appState.init();

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
              primary: AppColors.gold,
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

  final List<Widget> _screens = const [
    HomeScreen(),
    FocusScreen(),
    PrayerScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _HushNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _HushNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _HushNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final loc = context.read<AppState>().loc;
    final items = [
      _NavItem(icon: Icons.home_outlined, label: loc.navHome, index: 0),
      _NavItem(icon: Icons.adjust_outlined, label: loc.navFocus, index: 1),
      _NavItem(icon: Icons.location_on_outlined, label: loc.navPrayer, index: 2),
      _NavItem(icon: Icons.tune_outlined, label: loc.navSettings, index: 3),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        color: AppColors.base,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: items.map((item) => Expanded(
              child: GestureDetector(
                onTap: () => onTap(item.index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: currentIndex == item.index
                          ? AppColors.gold
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
            )).toList(),
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