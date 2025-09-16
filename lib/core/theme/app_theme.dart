import 'package:flutter/material.dart';
import 'colors.dart';
import 'dim.dart';
import 'typography.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.lightColorScheme,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 1,
      titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimaryLight,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
        size: 24,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.neutral300,
        disabledForegroundColor: AppColors.neutral500,
        elevation: Dim.elevation2,
        padding: EdgeInsets.symmetric(
          horizontal: Dim.l,
          vertical: Dim.m,
        ),
        minimumSize: Size(0, Dim.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary600,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.neutral300,
        disabledForegroundColor: AppColors.neutral500,
        padding: EdgeInsets.symmetric(
          horizontal: Dim.l,
          vertical: Dim.m,
        ),
        minimumSize: Size(0, Dim.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary600,
        disabledForegroundColor: AppColors.neutral500,
        side: const BorderSide(
          color: AppColors.primary600,
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dim.l,
          vertical: Dim.m,
        ),
        minimumSize: Size(0, Dim.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary600,
        disabledForegroundColor: AppColors.neutral500,
        padding: EdgeInsets.symmetric(
          horizontal: Dim.m,
          vertical: Dim.s,
        ),
        minimumSize: Size(0, Dim.buttonHeightSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.primary600,
        disabledForegroundColor: AppColors.neutral500,
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.all(Dim.s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
      ),
    ),

    // Card Theme - CORRECTED
    cardTheme: const CardThemeData(
      color: AppColors.surfaceLight,
      elevation: Dim.elevation2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dim.radiusM)),
      ),
      margin: EdgeInsets.all(Dim.s),
      clipBehavior: Clip.antiAlias,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral100,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dim.m,
        vertical: Dim.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: const BorderSide(
          color: AppColors.primary600,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: BorderSide.none,
      ),
      labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textDisabledLight,
      ),
      errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.error,
      ),
      helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondaryLight,
      ),
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dim.m,
        vertical: Dim.xs,
      ),
      minVerticalPadding: Dim.s,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
      ),
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primary100,
      iconColor: AppColors.textSecondaryLight,
      textColor: AppColors.textPrimaryLight,
      titleTextStyle: AppTypography.textTheme.bodyLarge,
      subtitleTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryLight,
      ),
    ),

    // Bottom Navigation Bar Theme - CORRECTED
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceLight,
      selectedItemColor: AppColors.primary600,
      unselectedItemColor: AppColors.textSecondaryLight,
      elevation: Dim.elevation8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      elevation: Dim.elevation2,
      height: 80,
      indicatorColor: AppColors.primary100,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.primary600,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondaryLight,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(
            color: AppColors.primary600,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.textSecondaryLight,
          size: 24,
        );
      }),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.neutral300,
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.neutral200,
      disabledColor: AppColors.neutral100,
      selectedColor: AppColors.primary100,
      secondarySelectedColor: AppColors.secondary100,
      padding: EdgeInsets.symmetric(horizontal: Dim.s),
      labelStyle: AppTypography.textTheme.labelMedium,
      secondaryLabelStyle: AppTypography.textTheme.labelMedium,
      brightness: Brightness.light,
      elevation: 0,
      pressElevation: Dim.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral800,
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: Colors.white,
      ),
      actionTextColor: AppColors.primary300,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
      ),
      elevation: Dim.elevation4,
    ),

    // Dialog Theme - CORRECTED
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.backgroundLight,
      elevation: Dim.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dim.radiusM)),
      ),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: AppColors.darkColorScheme,
    textTheme: AppTypography.textTheme,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 1,
      titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary300,
        foregroundColor: AppColors.primary900,
        disabledBackgroundColor: AppColors.neutral600,
        disabledForegroundColor: AppColors.neutral400,
        elevation: Dim.elevation2,
        padding: EdgeInsets.symmetric(
          horizontal: Dim.l,
          vertical: Dim.m,
        ),
        minimumSize: Size(0, Dim.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary300,
        foregroundColor: AppColors.primary900,
        disabledBackgroundColor: AppColors.neutral600,
        disabledForegroundColor: AppColors.neutral400,
        padding: EdgeInsets.symmetric(
          horizontal: Dim.l,
          vertical: Dim.m,
        ),
        minimumSize: Size(0, Dim.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary300,
        disabledForegroundColor: AppColors.neutral400,
        side: const BorderSide(
          color: AppColors.primary300,
          width: 1.5,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: Dim.l,
          vertical: Dim.m,
        ),
        minimumSize: Size(0, Dim.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary300,
        disabledForegroundColor: AppColors.neutral400,
        padding: EdgeInsets.symmetric(
          horizontal: Dim.m,
          vertical: Dim.s,
        ),
        minimumSize: Size(0, Dim.buttonHeightSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.primary300,
        disabledForegroundColor: AppColors.neutral400,
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.all(Dim.s),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dim.radiusS),
        ),
      ),
    ),

    // Card Theme - CORRECTED
    cardTheme: const CardThemeData(
      color: AppColors.surfaceDark,
      elevation: Dim.elevation4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dim.radiusM)),
      ),
      margin: EdgeInsets.all(Dim.s),
      clipBehavior: Clip.antiAlias,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral800,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dim.m,
        vertical: Dim.m,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: const BorderSide(
          color: AppColors.primary300,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
        borderSide: BorderSide.none,
      ),
      labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryDark,
      ),
      hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textDisabledDark,
      ),
      errorStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.error,
      ),
      helperStyle: AppTypography.textTheme.bodySmall?.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(
        horizontal: Dim.m,
        vertical: Dim.xs,
      ),
      minVerticalPadding: Dim.s,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
      ),
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.primary800,
      iconColor: AppColors.textSecondaryDark,
      textColor: AppColors.textPrimaryDark,
      titleTextStyle: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      subtitleTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryDark,
      ),
    ),

    // Bottom Navigation Bar Theme - CORRECTED
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary300,
      unselectedItemColor: AppColors.textSecondaryDark,
      elevation: Dim.elevation8,
      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      elevation: Dim.elevation2,
      height: 80,
      indicatorColor: AppColors.primary800,
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppTypography.textTheme.labelSmall?.copyWith(
            color: AppColors.primary300,
            fontWeight: FontWeight.w600,
          );
        }
        return AppTypography.textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondaryDark,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(
            color: AppColors.primary300,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.textSecondaryDark,
          size: 24,
        );
      }),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.neutral600,
      thickness: 1,
      space: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.neutral700,
      disabledColor: AppColors.neutral800,
      selectedColor: AppColors.primary800,
      secondarySelectedColor: AppColors.secondary800,
      padding: EdgeInsets.symmetric(horizontal: Dim.s),
      labelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      secondaryLabelStyle: AppTypography.textTheme.labelMedium?.copyWith(
        color: AppColors.textPrimaryDark,
      ),
      brightness: Brightness.dark,
      elevation: 0,
      pressElevation: Dim.elevation1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.neutral200,
      contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.neutral900,
      ),
      actionTextColor: AppColors.primary600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dim.radiusS),
      ),
      elevation: Dim.elevation4,
    ),

    // Dialog Theme - CORRECTED
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.backgroundDark,
      elevation: Dim.elevation8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Dim.radiusM)),
      ),
    ),
  );
}
