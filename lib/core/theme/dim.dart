/// Design system dimensions and spacing constants
/// Use Dim.* everywhere for spacing. Do not use raw numeric EdgeInsets in new code.
class Dim {
  // Base spacing unit (4px) - 8-point system foundation
  static const double _base = 1.0;

  // Primary Spacing Scale (8-point system)
  static const double xs = 4.0; // micro gaps
  static const double s = 8.0; // small gaps / inline spacing
  static const double m = 16.0; // default container padding / button spacing
  static const double l = 24.0; // section spacing
  static const double xl = 32.0; // large separation / hero spacing

  // Extended Spacing Scale (4px increments)
  static const double xxxs = _base * 1; // 4px
  static const double xxs = _base * 2; // 8px
  static const double xxl = _base * 10; // 40px
  static const double xxxl = _base * 12; // 48px

  // Semantic Aliases
  static const double gutter = m; // screen side padding (16px)
  static const double cardPadding = m; // default card inner padding (16px)
  static const double sectionGap = l; // default gap between major sections (24px)

  // Gutter System (page margins)
  static const double gutterXs = _base * 2; // 8px
  static const double gutterS = _base * 4; // 16px
  static const double gutterM = _base * 6; // 24px
  static const double gutterL = _base * 8; // 32px

  // Component Specific Dimensions
  // Buttons
  static const double buttonHeight = _base * 12; // 48px
  static const double buttonHeightSmall = _base * 10; // 40px
  static const double buttonHeightLarge = _base * 14; // 56px

  // Text Fields
  static const double textFieldHeight = _base * 12; // 48px
  static const double textFieldHeightSmall = _base * 10; // 40px
  static const double textFieldHeightLarge = _base * 14; // 56px

  // Icons
  static const double iconSize = _base * 4; // 24px
  static const double iconSizeSmall = _base * 5; // 20px
  static const double iconSizeLarge = _base * 8; // 32px

  // Cards and Lists
  static const double cardMinHeight = _base * 20; // 80px
  static const double listTileHeight = _base * 14; // 56px
  static const double listTileHeightDense = _base * 12; // 48px

  // Border Radius
  static const double radiusXs = _base * 1; // 4px
  static const double radiusS = _base * 2; // 8px
  static const double radiusM = _base * 3; // 12px
  static const double radiusL = _base * 4; // 16px
  static const double radiusXl = _base * 6; // 24px

  // Elevation Levels
  static const double elevation0 = 0;
  static const double elevation1 = 1;
  static const double elevation2 = 2;
  static const double elevation4 = 4;
  static const double elevation6 = 6;
  static const double elevation8 = 8;
  static const double elevation12 = 12;
  static const double elevation16 = 16;
  static const double elevation24 = 24;

  // Animation Durations (in milliseconds)
  static const int animationFast = 150;
  static const int animationMedium = 300;
  static const int animationSlow = 500;

  // Breakpoints for Responsive Design
  static const double breakpointMobile = 480;
  static const double breakpointTablet = 768;
  static const double breakpointDesktop = 1024;
  static const double breakpointLargeDesktop = 1440;

  // Private constructor to prevent instantiation
  Dim._();
}