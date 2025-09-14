// lib/core/theme/dim.dart
// Use Dim.* everywhere for spacing. Do not use raw numeric EdgeInsets in new code.


class Dim {
// 8-point system
static const double xs = 4.0; // micro gaps
static const double s = 8.0; // small gaps / inline spacing
static const double m = 16.0; // default container padding / button spacing
static const double l = 24.0; // section spacing
static const double xl = 32.0; // large separation / hero spacing


// Semantic aliases
static const double gutter = m; // screen side padding
static const double cardPadding = m; // default card inner padding
static const double sectionGap = l; // default gap between major sections
}