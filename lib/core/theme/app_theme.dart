import 'package:flutter/material.dart';

/// Warm analogous palette (peach · butter · rose gold) on black/white neutrals.
/// 60% cream/white, 30% peach + butter, 10% rose gold + black accents.
class AppColors {
  static const peach = Color(0xFFFFB5A0);
  static const butter = Color(0xFFFFE7A0);
  static const roseGold = Color(0xFFA85C69); // darkened for AA contrast with white
  static const cream = Color(0xFFFFFFFF);
  static const blush = Color(0xFFFFEEE4);
  static const ink = Color(0xFF000000);
  static const muted = Color(0xFF5E4F4C);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.roseGold).copyWith(
          primary: AppColors.roseGold,
          onPrimary: Colors.white,
          secondary: AppColors.peach,
          onSecondary: AppColors.ink,
          tertiary: AppColors.butter,
          onTertiary: AppColors.ink,
          surface: Colors.white,
          onSurface: AppColors.ink,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: AppColors.roseGold,
            side: const BorderSide(color: AppColors.roseGold, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppColors.peach,
        ),
      );
}
