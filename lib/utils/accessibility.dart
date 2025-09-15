// lib/core/utils/accessibility.dart
import 'package:flutter/material.dart';

class AccessibilityHelper {
  /// Checks if color contrast meets WCAG AA standards (4.5:1 ratio)
  static bool hasAccessibleContrast(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 4.5;
  }

  /// Checks if color contrast meets WCAG AAA standards (7:1 ratio)
  static bool hasHighContrast(Color foreground, Color background) {
    return contrastRatio(foreground, background) >= 7.0;
  }

  /// Calculates contrast ratio between two colors
  static double contrastRatio(Color color1, Color color2) {
    final luminance1 = _relativeLuminance(color1);
    final luminance2 = _relativeLuminance(color2);

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Calculates relative luminance of a color
  static double _relativeLuminance(Color color) {
    final r = _gammaCorrect(color.red / 255.0);
    final g = _gammaCorrect(color.green / 255.0);
    final b = _gammaCorrect(color.blue / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Applies gamma correction to color channel
  static double _gammaCorrect(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : ((channel + 0.055) / 1.055).clamp(0.0, 1.0);
  }

  /// Gets accessible text color (black or white) for given background
  static Color getAccessibleTextColor(Color backgroundColor) {
    return contrastRatio(Colors.white, backgroundColor) >
        contrastRatio(Colors.black, backgroundColor)
        ? Colors.white
        : Colors.black;
  }

  /// Validates if text meets minimum size requirements for accessibility
  static bool hasAccessibleTextSize(double fontSize, {bool isBold = false}) {
    if (isBold) {
      return fontSize >= 14.0; // Bold text can be slightly smaller
    }
    return fontSize >= 16.0; // Regular text minimum size
  }

  /// Validates if touch target meets minimum size (44x44 logical pixels)
  static bool hasAccessibleTouchTarget(Size size) {
    return size.width >= 44.0 && size.height >= 44.0;
  }

  /// Creates semantic label for screen readers
  static String createSemanticLabel({
    String? label,
    String? hint,
    String? value,
    bool? isSelected,
    bool? isDisabled,
  }) {
    final parts = <String>[];

    if (label != null) parts.add(label);
    if (value != null) parts.add(value);
    if (hint != null) parts.add(hint);

    if (isSelected == true) parts.add('selected');
    if (isDisabled == true) parts.add('disabled');

    return parts.join(', ');
  }

  /// Announces message to screen readers
  static void announceToScreenReader(
      BuildContext context,
      String message, {
        Assertiveness assertiveness = Assertiveness.polite,
      }) {
    // Create a temporary widget to announce the message
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: -100, // Hide it off-screen
        child: Material(
          color: Colors.transparent,
          child: Semantics(
            liveRegion: true,
            child: Text(
              message,
              style: const TextStyle(fontSize: 0), // Make it invisible
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // Remove the overlay entry after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      entry.remove();
    });
  }
}

enum Assertiveness { polite, assertive }

// Helper widget for accessibility
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? hint;
  final bool excludeSemantics;
  final VoidCallback? onTap;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.hint,
    this.excludeSemantics = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }
}