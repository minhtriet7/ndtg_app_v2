import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

ThemeData getDarkTheme() {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
    borderSide: BorderSide(color: AppColors.borderDark),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    primaryColor: AppColors.primaryLightTeal,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLightTeal,
      secondary: AppColors.secondaryLightBlue,
      surface: AppColors.cardDark,
      error: AppColors.danger,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.surfaceSubtleDark,
      outline: AppColors.borderDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bgDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        side: const BorderSide(color: AppColors.borderDark),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.borderDark,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.cardDark,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardDark,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: 16,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textMutedDark,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(
        color: AppColors.textSecondaryDark,
        fontWeight: FontWeight.w800,
      ),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(
          color: AppColors.primaryLightTeal,
          width: 1.6,
        ),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLightTeal,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, AppSizes.defaultButtonHeight),
        elevation: 0,
        shadowColor: Colors.transparent,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimaryDark,
        minimumSize: const Size(double.infinity, AppSizes.defaultButtonHeight),
        side: const BorderSide(color: AppColors.borderDark),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryLightTeal,
        textStyle: const TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.primaryLightTeal,
      unselectedItemColor: AppColors.textMutedDark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 11,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cardDark,
      contentTextStyle: const TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w700,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryLightTeal,
      linearTrackColor: AppColors.surfaceSubtleDark,
      circularTrackColor: AppColors.surfaceSubtleDark,
    ),
  );
}
