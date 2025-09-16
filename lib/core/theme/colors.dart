import 'package:flutter/material.dart';

/// Centralized color system for the app.
/// Use AppColors.<colorName> anywhere in the app.

class AppColors {
  // Primary brand colors
  static const primary50 = Color(0xFFF3F2FF);
  static const primary100 = Color(0xFFE9E7FF);
  static const primary200 = Color(0xFFD6D2FF);
  static const primary300 = Color(0xFFB8B0FF);
  static const primary400 = Color(0xFF9485FF);
  static const primary500 = Color(0xFF6C63FF);
  static const primary600 = Color(0xFF5A52E8);
  static const primary700 = Color(0xFF4C44D1);
  static const primary800 = Color(0xFF3F38B8);
  static const primary900 = Color(0xFF342E9F);

  // Secondary colors
  static const secondary50 = Color(0xFFFFF1F5);
  static const secondary100 = Color(0xFFFFE4EA);
  static const secondary200 = Color(0xFFFFCCD6);
  static const secondary300 = Color(0xFFFFA3B8);
  static const secondary400 = Color(0xFFFF6584);
  static const secondary500 = Color(0xFFFF4C6B);
  static const secondary600 = Color(0xFFE63E5C);
  static const secondary700 = Color(0xFFCC2F4D);
  static const secondary800 = Color(0xFFB3203E);
  static const secondary900 = Color(0xFF99112F);

  // Neutral colors
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF5F5F5);
  static const neutral200 = Color(0xFFE5E5E5);
  static const neutral300 = Color(0xFFD4D4D4);
  static const neutral400 = Color(0xFFA3A3A3);
  static const neutral500 = Color(0xFF737373);
  static const neutral600 = Color(0xFF525252);
  static const neutral700 = Color(0xFF404040);
  static const neutral800 = Color(0xFF262626);
  static const neutral900 = Color(0xFF171717);

  // Background colors
  static const backgroundLight = Color(0xFFFAFAFA);
  static const backgroundDark = Color(0xFF0A0A0A);

  // Surface colors
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1A1A1A);

  // Text colors - Light theme
  static const textPrimaryLight = Color(0xFF171717);
  static const textSecondaryLight = Color(0xFF525252);
  static const textDisabledLight = Color(0xFFA3A3A3);

  // Text colors - Dark theme
  static const textPrimaryDark = Color(0xFFFAFAFA);
  static const textSecondaryDark = Color(0xFFA3A3A3);
  static const textDisabledDark = Color(0xFF737373);

  // Semantic colors
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const successDark = Color(0xFF065F46);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFF92400E);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFF991B1B);

  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
  static const infoDark = Color(0xFF1E40AF);

  // Border colors
  static const borderLight = Color(0xFFE5E5E5);
  static const borderDark = Color(0xFF404040);

  // Divider colors
  static const dividerLight = Color(0xFFE5E5E5);
  static const dividerDark = Color(0xFF404040);

  // Shadow colors
  static const shadowLight = Color(0x1A000000);
  static const shadowDark = Color(0x40000000);

  // Legacy colors for backward compatibility
  static const primary = primary600;
  static const secondary = secondary400;
  static const textPrimary = textPrimaryLight;
  static const textSecondary = textSecondaryLight;
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const buttonPrimary = primary600;
  static const buttonSecondary = secondary400;
  static const border = borderLight;
  static const divider = dividerLight;

  // Color schemes for Material 3
  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary600,
    onPrimary: Color(0xFFFFFFFF),
    secondary: secondary400,
    onSecondary: Color(0xFFFFFFFF),
    tertiary: info,
    onTertiary: Color(0xFFFFFFFF),
    error: error,
    onError: Color(0xFFFFFFFF),
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    surfaceContainerHighest: neutral100,
    onSurfaceVariant: textSecondaryLight,
    outline: borderLight,
    outlineVariant: neutral200,
    shadow: shadowLight,
    scrim: Color(0xFF000000),
    inverseSurface: neutral800,
    onInverseSurface: textPrimaryDark,
    inversePrimary: primary300,
    surfaceTint: primary600,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary300,
    onPrimary: primary900,
    secondary: secondary300,
    onSecondary: secondary900,
    tertiary: info,
    onTertiary: Color(0xFFFFFFFF),
    error: error,
    onError: Color(0xFFFFFFFF),
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    surfaceContainerHighest: neutral800,
    onSurfaceVariant: textSecondaryDark,
    outline: borderDark,
    outlineVariant: neutral700,
    shadow: shadowDark,
    scrim: Color(0xFF000000),
    inverseSurface: neutral100,
    onInverseSurface: textPrimaryLight,
    inversePrimary: primary600,
    surfaceTint: primary300,
  );
}
