// lib/core/theme/typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Base sizes tuned for older users (40-60). Adjust if needed.
  static const double _base = 16; // bodyLarge base
  static const double _scaleHeadline = 1.8;
  static const double _scaleTitle = 1.25;
  static const double _scaleSmall = 0.875;

  // Recommended line heights (multiples of fontSize)
  static const double _lineHeightTight = 1.1;
  static const double _lineHeightNormal = 1.4;
  static const double _lineHeightLoose = 1.6;

  // Call this from app_theme.dart
  static TextTheme get textTheme {
    final base = GoogleFonts.montserratTextTheme();

    return base.copyWith(
      // Headlines / page titles
      headlineLarge: GoogleFonts.montserrat(
        fontSize: _base * _scaleHeadline, // ~28.8
        fontWeight: FontWeight.w700,
        height: _lineHeightNormal,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontSize: _base * 1.6, // ~25.6
        fontWeight: FontWeight.w700,
        height: _lineHeightNormal,
      ),

      // Section & card titles
      titleLarge: GoogleFonts.montserrat(
        fontSize: _base * _scaleTitle, // ~20
        fontWeight: FontWeight.w700,
        height: _lineHeightNormal,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: _lineHeightNormal,
      ),
      titleSmall: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: _lineHeightNormal,
      ),

      // Body text (primary)
      bodyLarge: GoogleFonts.montserrat(
        fontSize: _base, // 16
        fontWeight: FontWeight.w500,
        height: _lineHeightNormal,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: _lineHeightNormal,
      ),
      bodySmall: GoogleFonts.montserrat(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: _lineHeightLoose,
      ),

      // Labels / buttons
      labelLarge: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: _lineHeightNormal,
      ),
      labelSmall: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: _lineHeightNormal,
      ),

      // Extras
      displayLarge: GoogleFonts.montserrat(fontSize: 34, fontWeight: FontWeight.w800),
    );
  }

  // Optional helpers components can call directly
  static TextStyle bold([double? size]) =>
      GoogleFonts.montserrat(fontSize: size ?? _base, fontWeight: FontWeight.w700);

  static TextStyle muted([double? size]) =>
      GoogleFonts.montserrat(fontSize: size ?? _base, fontWeight: FontWeight.w400, color: Colors.grey[600]);
}