// lib/core/theme/colors.dart
// DO NOT use hex literals or Colors.* directly in widgets.
// Import this file and use AppColors.<token> everywhere.


import 'package:flutter/material.dart';

/// Design system color tokens (Balanced palette).
/// Version: 1.0
/// Date: 2025-09-13
class AppColors {
// Primary and accents
static const Color primary = Color(0xFF2563EB); // CTA, primary actions
static const Color primaryVariant = Color(0xFF1E4FCC); // darker primary
static const Color secondary = Color(0xFF06B6D4); // secondary actions, badges
static const Color accent = Color(0xFFFFB020); // use sparingly (discounts/alerts)

// Backward-compatible aliases (keep these if other files reference old names)
static const Color backgroundLight = background; // == #F7F9FC
static const Color textOnPrimary   = onPrimary;  // if onPrimary already defined




// Surface and backgrounds
static const Color background = Color(0xFFF7F9FC); // app background
static const Color surface = Color(0xFFFFFFFF); // cards, sheets, panels


// Text colors
static const Color textPrimary = Color(0xFF0F172A); // body / headings
static const Color textSecondary = Color(0xFF6B7280); // secondary labels
static const Color textHint = Color(0xFF9CA3AF); // hints / placeholder


// Semantic colors
static const Color success = Color(0xFF4CAF50);
static const Color warning = Color(0xFFFF9800);
static const Color error = Color(0xFFF44336);
static const Color info = Color(0xFF2196F3);


// States and helpers
static const Color disabled = Color(0xFFBFC9D9); // disabled controls
static const Color overlay = Color(0x0A000000); // 8% black overlay helper
static const Color whiteOverlay = Color(0x0AFFFFFF); // 8% white overlay helper


// On-* tokens and interaction helpers added in Step 2
// 'on' tokens (text/icons on colored backgrounds)
static const Color onPrimary = Color(0xFFFFFFFF); // text/icons on primary CTA
static const Color onSecondary = Color(0xFF0F172A); // text/icons on secondary teal
static const Color onBackground = Color(0xFF0F172A); // main text on backgrounds
static const Color onSurface = Color(0xFF0F172A); // main text on cards/surfaces


// Interaction helpers
static const Color hoverOverlay = Color(0x14000000); // ~8% black overlay for hover
static const Color pressedOverlay = Color(0x29000000); // ~16% black overlay for pressed
// Note: disabled token already present and used for disabled controls


// Dark-mode counterparts (basic)
static const Color darkBackground = Color(0xFF0B1220);
static const Color darkSurface = Color(0xFF0F172A);
static const Color darkTextPrimary= Color(0xFFE6EEF8);
static const Color darkOnPrimary = Color(0xFFFFFFFF);


// End of tokens
// Step 2 will add `on*` tokens and interaction tints.
}