import 'dart:ui' show FontVariation;

import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  OUTFITZ BRAND
///  Derived from the two brand kits supplied:
///   • `Screenshot 2026-10-16 070135.png` → wine #580202 · black · white ·
///     display serif (Prata / TAN Mignon).
///   • `Screenshot 2026-10-16 070118.png` → butter yellow · white · fine serif,
///     hairline rules, tiny ornamental crosses.
///
///  Usage rule: 60% warm paper + white, 30% wine/maroon ink work,
///  10% butter yellow highlight. Nothing else.
/// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  const AppColors._();

  /// Wine red — the house colour. Actions, active states, brand marks.
  static const wine = Color(0xFF580202);
  static const wineDeep = Color(0xFF3A0101);

  /// Maroon — the supporting red. Gradients, mood tags, emphasis.
  static const maroon = Color(0xFF800000);

  static const black = Color(0xFF000000);
  static const ink = Color(0xFF121110);

  /// Butter yellow — the warm accent.
  static const butter = Color(0xFFF6DE8D);
  static const butterSoft = Color(0xFFFCF4D8);

  static const white = Color(0xFFFFFFFF);

  /// Warm paper page background so white cards lift off the page.
  static const canvas = Color(0xFFF7F3EC);

  /// Photo backdrops, inert chips.
  static const sand = Color(0xFFEFE8DC);

  /// Hairline rules — the 1px lines that carry the whole layout.
  static const line = Color(0xFFE3DACA);

  /// Secondary text.
  static const muted = Color(0xFF7C736B);

  /// The five brand colours, in the order of the printed palette card.
  static const swatchStrip = <Color>[wine, maroon, black, white, butter];
}

/// Typography. Two families only: a fine serif for display, a light geometric
/// sans for everything else. Jost ships as a variable font, so every weight is
/// pinned through [FontVariation].
class AppText {
  const AppText._();

  static TextStyle sans(
    double size,
    FontWeight weight, {
    double spacing = 0,
    double height = 1.45,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: 'Jost',
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
        letterSpacing: spacing,
        height: height,
        color: color,
      );

  static TextStyle serif(
    double size, {
    double spacing = 0,
    double height = 1.15,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: 'Prata',
        fontSize: size,
        letterSpacing: spacing,
        height: height,
        color: color,
      );

  /// Wide-tracked uppercase micro label — the "FASHION COLLECTION" treatment.
  static TextStyle get micro =>
      sans(9.5, FontWeight.w500, spacing: 2.6, height: 1.2, color: AppColors.muted);

  static TextStyle get microWide =>
      sans(11, FontWeight.w500, spacing: 3.4, height: 1.2, color: AppColors.muted);

  /// Tappable labels (buttons, tabs).
  static TextStyle get action => sans(12, FontWeight.w500, spacing: 2.2, height: 1.2);

  static TextStyle get body =>
      sans(14.5, FontWeight.w400, height: 1.6, color: AppColors.ink.withValues(alpha: .84));

  static TextStyle get bodyMuted =>
      sans(13, FontWeight.w400, height: 1.55, color: AppColors.muted);

  static TextTheme get textTheme => TextTheme(
        displayLarge: serif(48, height: 1.02, color: AppColors.ink),
        displayMedium: serif(34, height: 1.08, color: AppColors.ink),
        headlineMedium: serif(26, height: 1.15, color: AppColors.ink),
        headlineSmall: serif(21, height: 1.2, color: AppColors.ink),
        titleLarge: serif(18, height: 1.25, color: AppColors.ink),
        titleMedium: sans(15, FontWeight.w500, color: AppColors.ink),
        titleSmall: sans(13.5, FontWeight.w500, color: AppColors.ink),
        bodyLarge: sans(15, FontWeight.w400, height: 1.6, color: AppColors.ink),
        bodyMedium: sans(14, FontWeight.w400, height: 1.55, color: AppColors.ink),
        bodySmall: sans(12.5, FontWeight.w400, height: 1.45, color: AppColors.muted),
        labelLarge: sans(13, FontWeight.w500, spacing: 1.6, color: AppColors.ink),
        labelMedium: sans(11, FontWeight.w500, spacing: 1.8, color: AppColors.ink),
        labelSmall: sans(9.5, FontWeight.w500, spacing: 2.4, color: AppColors.muted),
      );
}

class AppTheme {
  const AppTheme._();

  /// Corner language: panels are generously rounded, controls are pills.
  static const panel = 26.0;
  static const tile = 18.0;
  static const pill = 999.0;

  static const scheme = ColorScheme.light(
    primary: AppColors.wine,
    onPrimary: AppColors.white,
    primaryContainer: AppColors.butterSoft,
    onPrimaryContainer: AppColors.ink,
    secondary: AppColors.butter,
    onSecondary: AppColors.ink,
    tertiary: AppColors.maroon,
    onTertiary: AppColors.white,
    surface: AppColors.white,
    onSurface: AppColors.ink,
    surfaceContainerLowest: AppColors.white,
    surfaceContainerLow: AppColors.canvas,
    surfaceContainer: AppColors.sand,
    outline: AppColors.line,
    outlineVariant: AppColors.line,
    error: AppColors.maroon,
    onError: AppColors.white,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.canvas,
        fontFamily: 'Jost',
        textTheme: AppText.textTheme,
        primaryColor: AppColors.wine,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.canvas,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.ink,
          titleTextStyle: AppText.serif(19, color: AppColors.ink),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.line,
          thickness: 1,
          space: 1,
        ),
        iconTheme: const IconThemeData(color: AppColors.ink, size: 22),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.white,
          selectedColor: AppColors.wine,
          secondarySelectedColor: AppColors.wine,
          side: const BorderSide(color: AppColors.line),
          shape: const StadiumBorder(),
          showCheckmark: false,
          labelStyle: AppText.sans(12, FontWeight.w500, spacing: .6, color: AppColors.ink),
          secondaryLabelStyle:
              AppText.sans(12, FontWeight.w500, spacing: .6, color: AppColors.white),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: AppText.sans(13.5, FontWeight.w400, color: AppColors.muted),
          labelStyle: AppText.micro,
          floatingLabelStyle: AppText.micro.copyWith(color: AppColors.wine),
          border: _border(AppColors.line),
          enabledBorder: _border(AppColors.line),
          focusedBorder: _border(AppColors.wine, 1.4),
          errorBorder: _border(AppColors.maroon),
          focusedErrorBorder: _border(AppColors.maroon, 1.4),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.wine,
          inactiveTrackColor: AppColors.line,
          thumbColor: AppColors.wine,
          overlayColor: Color(0x1A580202),
          trackHeight: 3,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.wine,
          linearTrackColor: AppColors.line,
          linearMinHeight: 6,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.ink,
          contentTextStyle: AppText.sans(13, FontWeight.w400, color: AppColors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.wine,
            foregroundColor: AppColors.white,
            disabledBackgroundColor: AppColors.sand,
            disabledForegroundColor: AppColors.muted,
            minimumSize: const Size.fromHeight(54),
            elevation: 0,
            textStyle: AppText.sans(12.5, FontWeight.w500, spacing: 2.2),
            shape: const StadiumBorder(),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.wine,
            backgroundColor: Colors.transparent,
            minimumSize: const Size.fromHeight(54),
            side: const BorderSide(color: AppColors.wine),
            textStyle: AppText.sans(12.5, FontWeight.w500, spacing: 2.2),
            shape: const StadiumBorder(),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.wine,
            textStyle: AppText.sans(11.5, FontWeight.w500, spacing: 1.6),
          ),
        ),
      );

  static OutlineInputBorder _border(Color c, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: c, width: w),
      );
}
