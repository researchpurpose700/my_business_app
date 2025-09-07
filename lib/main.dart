import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/language/generated/app_localizations.dart';
import 'screens/language_selection_page.dart';
import 'core/theme/colors.dart';
import 'screens/main_screen.dart';
import 'screens/business_registration_page.dart';

/// App onboarding flow states
enum AppFlowState { languageSelection, registration, main }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  AppFlowState? _flowState; // null = still loading persisted state

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  /// Load saved language + registration status
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('languageCode');
    final isRegistered = prefs.getBool('isRegistered') ?? false;

    setState(() {
      if (savedLang == null) {
        _flowState = AppFlowState.languageSelection;
      } else if (!isRegistered) {
        _locale = Locale(savedLang);
        _flowState = AppFlowState.registration;
      } else {
        _locale = Locale(savedLang);
        _flowState = AppFlowState.main;
      }
    });
  }

  /// Called when user selects a language
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);

    setState(() {
      _locale = locale;
      _flowState = AppFlowState.registration; // next step
    });
  }

  @override
  Widget build(BuildContext context) {
    // Splash while loading persisted state
    if (_flowState == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
        ),
      ),

      // Decide home screen based on current (persisted) flow state
      home: () {
        switch (_flowState!) {
          case AppFlowState.languageSelection:
            return LanguageSelectionPage(
              onLanguageSelected: (code) => setLocale(Locale(code)),
            );

          case AppFlowState.registration:
            return BusinessRegistrationPage(
              onFinished: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isRegistered', true);

                print('MAIN: switching to MainScreen'); // DEBUG log

                if (!mounted) return;
                setState(
                  () => _flowState = AppFlowState.main,
                ); // state-machine swap

                // Fallback nav to cover edge cases where rebuild is deferred
                Future.microtask(() {
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainScreen()),
                    (_) => false,
                  );
                });
              },
            );

          case AppFlowState.main:
            return const MainScreen();
        }
      }(),
    );
  }
}
