// lib/core/theme/colors.dart
// DO NOT use hex literals or Colors.* directly in widgets.
// Import this file and use AppColors.
import 'package:flutter/material.dart';

/// Comprehensive design system color tokens
/// Merged from Material Design palette and balanced design system
/// Version: 2.0
/// Date: 2025-09-15
class AppColors {
  // ===== PRIMARY DESIGN TOKENS =====
  // Primary and accents (main design system)
  static const Color primary = Color(0xFF2563EB); // CTA, primary actions
  static const Color primaryVariant = Color(0xFF1E4FCC); // darker primary
  static const Color secondary = Color(0xFF06B6D4); // secondary actions, badges
  static const Color accent = Color(0xFFFFB020); // use sparingly (discounts/alerts)

  // ===== MATERIAL DESIGN PRIMARY SCALE =====
  static const Color primary50 = Color(0xFFE3F2FD);
  static const Color primary100 = Color(0xFFBBDEFB);
  static const Color primary200 = Color(0xFF90CAF9);
  static const Color primary300 = Color(0xFF64B5F6);
  static const Color primary400 = Color(0xFF42A5F5);
  static const Color primary500 = Color(0xFF2196F3);
  static const Color primary600 = Color(0xFF1E88E5);
  static const Color primary700 = Color(0xFF1976D2);
  static const Color primary800 = Color(0xFF1565C0);
  static const Color primary900 = Color(0xFF0D47A1);

  // ===== MATERIAL DESIGN SECONDARY SCALE =====
  static const Color secondary50 = Color(0xFFF3E5F5);
  static const Color secondary100 = Color(0xFFE1BEE7);
  static const Color secondary200 = Color(0xFFCE93D8);
  static const Color secondary300 = Color(0xFFBA68C8);
  static const Color secondary400 = Color(0xFFAB47BC);
  static const Color secondary500 = Color(0xFF9C27B0);
  static const Color secondary600 = Color(0xFF8E24AA);
  static const Color secondary700 = Color(0xFF7B1FA2);
  static const Color secondary800 = Color(0xFF6A1B9A);
  static const Color secondary900 = Color(0xFF4A148C);

  // ===== NEUTRAL SCALE =====
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFEEEEEE);
  static const Color neutral300 = Color(0xFFE0E0E0);
  static const Color neutral400 = Color(0xFFBDBDBD);
  static const Color neutral500 = Color(0xFF9E9E9E);
  static const Color neutral600 = Color(0xFF757575);
  static const Color neutral700 = Color(0xFF616161);
  static const Color neutral800 = Color(0xFF424242);
  static const Color neutral900 = Color(0xFF212121);

  // ===== SURFACE AND BACKGROUNDS =====
  static const Color background = Color(0xFFF7F9FC); // app background
  static const Color surface = Color(0xFFFFFFFF); // cards, sheets, panels
  static const Color surfaceLight = Color(0xFFFAFAFA); // neutral50 alias
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF0F172A);

  // Additional background variants
  static const Color backgroundDark = Color(0xFF111111); // from darkColorScheme surface
  static const Color dimBackground = Color(0xFF111111); // dim background variant

  // ===== TEXT COLORS =====
  static const Color textPrimary = Color(0xFF0F172A); // body / headings
  static const Color textSecondary = Color(0xFF6B7280); // secondary labels
  static const Color textHint = Color(0xFF9CA3AF); // hints / placeholder
  static const Color textPrimaryLight = Color(0xFF212121); // neutral900
  static const Color textPrimaryDark = Color(0xFFF5F5F5); // neutral100
  static const Color textSecondaryLight = Color(0xFF616161); // neutral700
  static const Color textSecondaryDark = Color(0xFFE0E0E0); // neutral300
  static const Color textDisabledLight = Color(0xFF9E9E9E); // neutral500
  static const Color textDisabledDark = Color(0xFF9E9E9E); // neutral500
  static const Color darkTextPrimary = Color(0xFFE6EEF8);

  // ===== SEMANTIC COLORS =====
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ===== SUCCESS VARIANTS =====
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color successDark = Color(0xFF388E3C);

  // ===== WARNING VARIANTS =====
  static const Color warningLight = Color(0xFFFFE0B2);
  static const Color warningDark = Color(0xFFF57C00);

  // ===== ERROR VARIANTS =====
  static const Color errorLight = Color(0xFFFFCDD2);
  static const Color errorDark = Color(0xFFD32F2F);

  // ===== INFO VARIANTS =====
  static const Color infoLight = Color(0xFFBBDEFB);
  static const Color infoDark = Color(0xFF1976D2);

  // ===== ON-* TOKENS (text/icons on colored backgrounds) =====
  static const Color onPrimary = Color(0xFFFFFFFF); // text/icons on primary CTA
  static const Color onSecondary = Color(0xFF0F172A); // text/icons on secondary teal
  static const Color onBackground = Color(0xFF0F172A); // main text on backgrounds
  static const Color onSurface = Color(0xFF0F172A); // main text on cards/surfaces
  static const Color darkOnPrimary = Color(0xFFFFFFFF);

  // ===== STATES AND HELPERS =====
  static const Color disabled = Color(0xFFBFC9D9); // disabled controls
  static const Color overlay = Color(0x0A000000); // 8% black overlay helper
  static const Color whiteOverlay = Color(0x0AFFFFFF); // 8% white overlay helper

  // ===== INTERACTION HELPERS =====
  static const Color hoverOverlay = Color(0x14000000); // ~8% black overlay for hover
  static const Color pressedOverlay = Color(0x29000000); // ~16% black overlay for pressed

  // ===== BACKWARD-COMPATIBLE ALIASES =====
  // Keep these if other files reference old names
  static const Color backgroundLight = background; // == #F7F9FC
  static const Color textOnPrimary = onPrimary; // if onPrimary already defined

  // ===== LIGHT THEME COLOR SCHEME =====
  static const ColorScheme lightColorScheme = ColorScheme.light(
    primary: primary600,
    onPrimary: Colors.white,
    primaryContainer: primary100,
    onPrimaryContainer: primary800,
    secondary: secondary600,
    onSecondary: Colors.white,
    secondaryContainer: secondary100,
    onSecondaryContainer: secondary800,
    tertiary: Color(0xFF006A6B),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFF9DF2F3),
    onTertiaryContainer: Color(0xFF002021),
    error: error,
    onError: Colors.white,
    errorContainer: errorLight,
    onErrorContainer: errorDark,
    outline: neutral400,
    outlineVariant: neutral300,
    surface: Colors.white,
    onSurface: neutral900,
    surfaceVariant: neutral100,
    onSurfaceVariant: neutral700,
    inverseSurface: neutral800,
    onInverseSurface: neutral100,
    inversePrimary: primary200,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: primary600,
  );

  // ===== DARK THEME COLOR SCHEME =====
  static const ColorScheme darkColorScheme = ColorScheme.dark(
    primary: primary300,
    onPrimary: primary900,
    primaryContainer: primary700,
    onPrimaryContainer: primary100,
    secondary: secondary300,
    onSecondary: secondary900,
    secondaryContainer: secondary700,
    onSecondaryContainer: secondary100,
    tertiary: Color(0xFF81D6D7),
    onTertiary: Color(0xFF003738),
    tertiaryContainer: Color(0xFF004F51),
    onTertiaryContainer: Color(0xFF9DF2F3),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    outline: neutral500,
    outlineVariant: neutral600,
    surface: Color(0xFF111111),
    onSurface: neutral100,
    surfaceVariant: neutral800,
    onSurfaceVariant: neutral300,
    inverseSurface: neutral100,
    onInverseSurface: neutral800,
    inversePrimary: primary600,
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: primary300,
  );
}