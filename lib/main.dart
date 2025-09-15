import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/language/generated/app_localizations.dart';

// Import design system components
import 'core/theme/app_theme.dart';
import 'core/theme/colors.dart';
import 'core/theme/dim.dart';
import 'core/theme/typography.dart';
import 'package:my_business_app/core/components/components.dart';
import '/utils/accessibility.dart';
import '/utils/hooks.dart';

// Import app screens
import 'screens/language_selection_page.dart';
import 'screens/main_screen.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'screens/camera_page.dart';

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
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadPersistedState();
  }

  /// Load saved language + registration status + theme preference
  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('languageCode');
    final isRegistered = prefs.getBool('isRegistered') ?? false;
    final savedThemeMode = prefs.getString('themeMode') ?? 'system';

    setState(() {
      // Set theme mode
      _themeMode = switch (savedThemeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

      // Set app flow state
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

  /// Toggle between light/dark themes
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode = switch (_themeMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };

    final themeString = switch (newThemeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString('themeMode', themeString);
    setState(() => _themeMode = newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    // Splash while loading persisted state
    if (_flowState == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: AppScaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: Dim.l),
                Text(
                  'Loading...',
                  style: AppTypography.bold(16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Design System App',

      // Localization
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme configuration using design system
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // Routes
      routes: {
        '/camera': (context) => CameraPage(
          onStoryCreated: (story) {
            // Handle created story globally, or leave empty
            debugPrint('Story created: ${story.toString()}');
          },
        ),
        '/home_custom': (context) => const HomePage(),
        '/settings': (context) => SettingsPage(
          currentThemeMode: _themeMode,
          onThemeChanged: toggleTheme,
        ),
      },

      // Decide home screen based on current (persisted) flow state
      home: _buildHomeScreen(),
    );
  }

  Widget _buildHomeScreen() {
    switch (_flowState!) {
      case AppFlowState.languageSelection:
        return LanguageSelectionPage(
          onLanguageSelected: (code) => setLocale(Locale(code)),
        );

      case AppFlowState.registration:
        return BusinessLoginPage(
          onFinished: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isRegistered', true);

            debugPrint('MAIN: switching to MainScreen');

            if (!mounted) return;
            setState(() => _flowState = AppFlowState.main);

            // Fallback navigation to cover edge cases where rebuild is deferred
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
  }
}

/// Settings page for theme and other app preferences
class SettingsPage extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final VoidCallback onThemeChanged;

  const SettingsPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dim.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: Dim.m),

            AppCard(
              child: Column(
                children: [
                  AppListTileIcon(
                    icon: _getThemeIcon(),
                    title: Text('Theme'),
                    subtitle: Text(_getThemeDescription()),
                    trailing: AppButton(
                      text: 'Change',
                      variant: AppButtonVariant.text,
                      onPressed: onThemeChanged,
                    ),
                  ),
                  Divider(height: 1),
                  AppListTileIcon(
                    icon: Icons.language,
                    title: Text('Language'),
                    subtitle: Text('Change app language'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to language selection
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language settings coming soon'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: Dim.l),

            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: Dim.m),

            AppCard(
              child: Column(
                children: [
                  AppListTileIcon(
                    icon: Icons.info_outline,
                    title: Text('Version'),
                    subtitle: Text('1.0.0 (Built with Design System)'),
                  ),
                  Divider(height: 1),
                  AppListTileIcon(
                    icon: Icons.help_outline,
                    title: Text('Help & Support'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Help & Support coming soon'),
                          backgroundColor: AppColors.info,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getThemeIcon() {
    return switch (currentThemeMode) {
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.system => Icons.brightness_auto,
    };
  }

  String _getThemeDescription() {
    return switch (currentThemeMode) {
      ThemeMode.light => 'Light theme',
      ThemeMode.dark => 'Dark theme',
      ThemeMode.system => 'Follow system',
    };
  }
}