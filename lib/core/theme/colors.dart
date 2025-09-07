import 'package:flutter/material.dart';

/// Centralized color system for the app.
/// Use AppColors.<colorName> anywhere in the app.

class AppColors {
  // Primary brand color
  static const primary = Color(0xFF6C63FF); // Deep violet

  // Secondary color for accents, buttons, highlights
  static const secondary = Color(0xFFFF6584); // Soft pink

  // Background colors
  static const backgroundLight = Color(0xFFF5F5F5); // Light grey
  static const backgroundDark = Color(0xFF1E1E1E); // Dark mode background

  // Text colors
  static const textPrimary = Color(0xFF222222); // Dark text
  static const textSecondary = Color(0xFF888888); // Grey text
  static const textOnPrimary = Color(0xFFFFFFFF); // White text on primary color

  // Button colors
  static const buttonPrimary = primary;
  static const buttonSecondary = secondary;

  // Error and warning colors
  static const error = Color(0xFFFF4C4C); // Red
  static const warning = Color(0xFFFFC107); // Amber

  // Border and divider colors
  static const border = Color(0xFFE0E0E0);
  static const divider = Color(0xFFBDBDBD);
}
