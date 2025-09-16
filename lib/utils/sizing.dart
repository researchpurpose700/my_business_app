import 'package:flutter/material.dart';

// Consistent spacing values based on percentage of screen dimensions
class AppSpacing {
  static late MediaQueryData _mediaQuery;

  // Initialize with MediaQuery data
  static void initialize(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
  }

  // Base dimensions (percentage of screen width/height)
  static double get screenWidth => _mediaQuery.size.width;
  static double get screenHeight => _mediaQuery.size.height;

  // Percentage-based spacing values
  static double get xs => screenWidth * 0.01;      // ~4px on 375px width
  static double get sm => screenWidth * 0.02;      // ~8px on 375px width
  static double get md => screenWidth * 0.04;      // ~16px on 375px width
  static double get lg => screenWidth * 0.05;      // ~20px on 375px width
  static double get xl => screenWidth * 0.08;      // ~32px on 375px width
  static double get xxl => screenWidth * 0.12;     // ~48px on 375px width

  // Vertical spacing based on screen height
  static double get verticalXs => screenHeight * 0.005;   // ~4px on 812px height
  static double get verticalSm => screenHeight * 0.01;    // ~8px on 812px height
  static double get verticalMd => screenHeight * 0.02;    // ~16px on 812px height
  static double get verticalLg => screenHeight * 0.025;   // ~20px on 812px height
  static double get verticalXl => screenHeight * 0.04;    // ~32px on 812px height
  static double get verticalXxl => screenHeight * 0.06;   // ~48px on 812px height

  // Border radius values (percentage-based)
  static double get radiusXs => screenWidth * 0.01;       // ~4px
  static double get radiusSm => screenWidth * 0.02;       // ~8px
  static double get radiusMd => screenWidth * 0.03;       // ~12px
  static double get radiusLg => screenWidth * 0.04;       // ~16px
  static double get radiusXl => screenWidth * 0.05;       // ~20px
  static double get radiusRound => screenWidth * 0.125;   // ~50px (circular)

  // Container dimensions (percentage-based)
  static double get containerSmall => screenWidth * 0.15;    // ~60px
  static double get containerMedium => screenWidth * 0.25;   // ~100px
  static double get containerLarge => screenWidth * 0.35;    // ~140px

  // Icon sizes (percentage-based)
  static double get iconXs => screenWidth * 0.04;         // ~16px
  static double get iconSm => screenWidth * 0.05;         // ~20px
  static double get iconMd => screenWidth * 0.06;         // ~24px
  static double get iconLg => screenWidth * 0.08;         // ~32px
  static double get iconXl => screenWidth * 0.12;         // ~48px

  // Button dimensions
  static double get buttonHeight => screenHeight * 0.06;    // ~48px
  static double get buttonSmallHeight => screenHeight * 0.05; // ~40px
  static double get buttonLargeHeight => screenHeight * 0.07; // ~56px

  // Card dimensions
  static double get cardHeight => screenHeight * 0.15;      // ~120px
  static double get cardLargeHeight => screenHeight * 0.25; // ~200px
  static double get cardSmallHeight => screenHeight * 0.1;  // ~80px

  // Input field dimensions
  static double get inputHeight => screenHeight * 0.06;     // ~48px
  static double get inputLargeHeight => screenHeight * 0.08; // ~64px

  // Safe area padding
  static EdgeInsets get safePadding => EdgeInsets.only(
    top: _mediaQuery.padding.top,
    bottom: _mediaQuery.padding.bottom,
    left: _mediaQuery.padding.left,
    right: _mediaQuery.padding.right,
  );

  // Common padding presets
  static EdgeInsets get paddingXs => EdgeInsets.all(xs);
  static EdgeInsets get paddingSm => EdgeInsets.all(sm);
  static EdgeInsets get paddingMd => EdgeInsets.all(md);
  static EdgeInsets get paddingLg => EdgeInsets.all(lg);
  static EdgeInsets get paddingXl => EdgeInsets.all(xl);

  // Horizontal padding presets
  static EdgeInsets get paddingHorizontalXs => EdgeInsets.symmetric(horizontal: xs);
  static EdgeInsets get paddingHorizontalSm => EdgeInsets.symmetric(horizontal: sm);
  static EdgeInsets get paddingHorizontalMd => EdgeInsets.symmetric(horizontal: md);
  static EdgeInsets get paddingHorizontalLg => EdgeInsets.symmetric(horizontal: lg);
  static EdgeInsets get paddingHorizontalXl => EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding presets
  static EdgeInsets get paddingVerticalXs => EdgeInsets.symmetric(vertical: verticalXs);
  static EdgeInsets get paddingVerticalSm => EdgeInsets.symmetric(vertical: verticalSm);
  static EdgeInsets get paddingVerticalMd => EdgeInsets.symmetric(vertical: verticalMd);
  static EdgeInsets get paddingVerticalLg => EdgeInsets.symmetric(vertical: verticalLg);
  static EdgeInsets get paddingVerticalXl => EdgeInsets.symmetric(vertical: verticalXl);

  // Screen-specific padding (respects safe areas)
  static EdgeInsets get screenPadding => EdgeInsets.only(
    top: _mediaQuery.padding.top + md,
    bottom: _mediaQuery.padding.bottom + md,
    left: md,
    right: md,
  );

  static EdgeInsets get screenPaddingHorizontal => EdgeInsets.symmetric(horizontal: md);

  // Widget spacing helpers
  static SizedBox get verticalSpaceXs => SizedBox(height: verticalXs);
  static SizedBox get verticalSpaceSm => SizedBox(height: verticalSm);
  static SizedBox get verticalSpaceMd => SizedBox(height: verticalMd);
  static SizedBox get verticalSpaceLg => SizedBox(height: verticalLg);
  static SizedBox get verticalSpaceXl => SizedBox(height: verticalXl);

  static SizedBox get horizontalSpaceXs => SizedBox(width: xs);
  static SizedBox get horizontalSpaceSm => SizedBox(width: sm);
  static SizedBox get horizontalSpaceMd => SizedBox(width: md);
  static SizedBox get horizontalSpaceLg => SizedBox(width: lg);
  static SizedBox get horizontalSpaceXl => SizedBox(width: xl);

  // Custom spacing functions
  static double width(double percentage) => screenWidth * (percentage / 100);
  static double height(double percentage) => screenHeight * (percentage / 100);

  static EdgeInsets customPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return EdgeInsets.only(
      top: top ?? vertical ?? all ?? 0,
      bottom: bottom ?? vertical ?? all ?? 0,
      left: left ?? horizontal ?? all ?? 0,
      right: right ?? horizontal ?? all ?? 0,
    );
  }
}

class AppSizing {
  static late MediaQueryData _mediaQueryData;
  static late double _screenWidth;
  static late double _screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData.size.width;
    _screenHeight = _mediaQueryData.size.height;
  }

  // Screen dimensions
  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  // Responsive width (percentage of screen width)
  static double width(double percentage) => _screenWidth * (percentage / 100);

  // Responsive height (percentage of screen height)
  static double height(double percentage) => _screenHeight * (percentage / 100);

  // Responsive font sizes
  static double fontSize(double baseSize) {
    // Base design width: 375 (iPhone 6/7/8)
    return baseSize * (_screenWidth / 375);
  }

  // Fixed spacing values (using consistent percentage approach)
  static double get xs => width(1);      // ~4px
  static double get sm => width(2);      // ~8px
  static double get md => width(4);      // ~16px
  static double get lg => width(5);      // ~20px
  static double get xl => width(6);      // ~24px
  static double get xxl => width(8);     // ~32px

  // Responsive spacing
  static double spacing(double percentage) => width(percentage);

  // Standard border radius values
  static double get radiusXs => width(1);     // ~4px
  static double get radiusSm => width(2);     // ~8px
  static double get radiusMd => width(3.5);   // ~14px
  static double get radiusLg => width(5);     // ~20px
  static double get radiusXl => width(8);     // ~32px

  // Button dimensions
  static double get buttonHeight => height(6);           // ~48-56px
  static double get buttonRadius => radiusMd;            // ~14px

  // Icon sizes (multiple sizing options)
  static double get iconXs => width(3);                  // ~12px
  static double get iconSm => width(4);                  // ~16px
  static double get iconMd => width(6);                  // ~24px
  static double get iconLg => width(7.5);                // ~28px
  static double get iconXl => width(12);                 // ~48px

  // Legacy icon size mappings for compatibility
  static double get smallIconSize => iconSm;             // ~16px
  static double get iconSize => iconLg;                  // ~28px

  // Responsive dimensions for specific UI elements
  static double get profileImageRadius => width(9.6);    // ~36px
  static double get coverImageHeight => height(20);      // ~180px
  static double get logoSize => width(17);               // ~64px
  static double get featureBoxHeight => width(25);       // Dynamic aspect ratio

  // Padding values
  static double get formPadding => width(5);             // ~20px
  static double get cardPadding => width(3.7);           // ~14px
  static double get containerPadding => width(6);        // ~24px

  // Breakpoints for responsive design
  static bool get isSmallScreen => _screenWidth < 600;
  static bool get isMediumScreen => _screenWidth >= 600 && _screenWidth < 1200;
  static bool get isLargeScreen => _screenWidth >= 1200;

  // Grid columns based on screen size
  static int get gridColumns => isSmallScreen ? 2 : (isMediumScreen ? 3 : 4);

  // Padding adjustments for different screen sizes
  static double get horizontalPadding => isSmallScreen ? md : lg;
  static double get verticalPadding => isSmallScreen ? md : lg;

  // Device type detection
  static bool get isTablet => _screenWidth >= 768;
  static bool get isDesktop => _screenWidth >= 1024;
  static bool get isMobile => _screenWidth < 768;

  // Safe area adjustments
  static EdgeInsets get safePadding => _mediaQueryData.padding;
  static double get statusBarHeight => _mediaQueryData.padding.top;
  static double get bottomSafeArea => _mediaQueryData.padding.bottom;

  // Text scaling factor based on screen size
  static double get textScaleFactor {
    if (isSmallScreen) return 0.9;
    if (isMediumScreen) return 1.0;
    return 1.1;
  }

  // Component-specific sizing helpers
  static double listTileHeight(BuildContext context) {
    return isSmallScreen ? height(7) : height(8); // ~56-64px
  }

  static double appBarHeight(BuildContext context) {
    return kToolbarHeight * textScaleFactor;
  }

  // Spacing helpers for common layouts
  static SizedBox get verticalSpaceXs => SizedBox(height: xs);
  static SizedBox get verticalSpaceSm => SizedBox(height: sm);
  static SizedBox get verticalSpaceMd => SizedBox(height: md);
  static SizedBox get verticalSpaceLg => SizedBox(height: lg);
  static SizedBox get verticalSpaceXl => SizedBox(height: xl);

  static SizedBox get horizontalSpaceXs => SizedBox(width: xs);
  static SizedBox get horizontalSpaceSm => SizedBox(width: sm);
  static SizedBox get horizontalSpaceMd => SizedBox(width: md);
  static SizedBox get horizontalSpaceLg => SizedBox(width: lg);
  static SizedBox get horizontalSpaceXl => SizedBox(width: xl);
}