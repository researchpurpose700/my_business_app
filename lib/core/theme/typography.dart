import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for consistent text styling throughout the app
class AppTypography {
  // Font family
  static const String _fontFamily = 'Inter';

  // Text theme
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
    const TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    ),
  );

  // Custom text styles for specific use cases
  static TextStyle get buttonText => textTheme.labelLarge!.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get caption => textTheme.bodySmall!.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle get overline => textTheme.labelSmall!.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    height: 1.6,
  );

  // App-specific text styles
  static TextStyle get appTitle => textTheme.headlineMedium!.copyWith(
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle get cardTitle => textTheme.titleMedium!.copyWith(
    fontWeight: FontWeight.w600,
  );

  static TextStyle get cardSubtitle => textTheme.bodyMedium!.copyWith(
    color: Colors.grey[600],
  );

  static TextStyle get inputLabel => textTheme.bodyMedium!.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get inputHint => textTheme.bodyMedium!.copyWith(
    color: Colors.grey[500],
  );

  static TextStyle get errorText => textTheme.bodySmall!.copyWith(
    color: Colors.red[600],
    fontWeight: FontWeight.w500,
  );

  static TextStyle get successText => textTheme.bodySmall!.copyWith(
    color: Colors.green[600],
    fontWeight: FontWeight.w500,
  );

  static TextStyle get linkText => textTheme.bodyMedium!.copyWith(
    color: Colors.blue[600],
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.w500,
  );

  // Navigation text styles
  static TextStyle get bottomNavLabel => textTheme.labelSmall!.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get tabLabel => textTheme.labelMedium!.copyWith(
    fontWeight: FontWeight.w500,
  );

  // List item text styles
  static TextStyle get listTitle => textTheme.titleMedium!.copyWith(
    fontWeight: FontWeight.w500,
  );

  static TextStyle get listSubtitle => textTheme.bodyMedium!.copyWith(
    color: Colors.grey[600],
  );

  // Status text styles
  static TextStyle get statusActive => textTheme.bodySmall!.copyWith(
    color: Colors.green[600],
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statusInactive => textTheme.bodySmall!.copyWith(
    color: Colors.grey[500],
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statusWarning => textTheme.bodySmall!.copyWith(
    color: Colors.orange[600],
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statusError => textTheme.bodySmall!.copyWith(
    color: Colors.red[600],
    fontWeight: FontWeight.w500,
  );
}
