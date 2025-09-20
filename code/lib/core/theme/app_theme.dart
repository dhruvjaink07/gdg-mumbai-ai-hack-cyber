import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      primaryContainer: AppColors.primaryLight,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      background: AppColors.backgroundLight,
      onSurface: AppColors.onSurfaceLight,
      onBackground: AppColors.onSurfaceLight,
      onPrimary: AppColors.accent,
      surfaceVariant: AppColors.surfaceVariantLight,
      onSurfaceVariant: AppColors.onSurfaceVariantLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.accent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      surfaceTintColor: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.1),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 18,
        color: AppColors.onSurfaceLight,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        color: AppColors.onSurfaceLight,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.onSurfaceVariantLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryLight,
      primaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      onSurface: AppColors.onSurfaceDark,
      onBackground: AppColors.onSurfaceDark,
      onPrimary: AppColors.backgroundDark,
      surfaceVariant: AppColors.surfaceVariantDark,
      onSurfaceVariant: AppColors.onSurfaceVariantDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.onSurfaceDark,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      surfaceTintColor: AppColors.primaryLight.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 18,
        color: AppColors.onSurfaceDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, 
        color: AppColors.onSurfaceDark,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.onSurfaceVariantDark,
      ),
    ),
  );
}