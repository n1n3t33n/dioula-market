import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Thèmes clair & sombre de Dioula Market, fidèles aux templates
/// Foodly (clair, vert/orange) et Rive (sombre, navy).
class AppTheme {
  AppTheme._();

  // Alias rétro-compatibles (utilisés dans d'anciens écrans).
  static const Color orange = AppColors.orange;
  static const Color green = AppColors.green;

  static const _radius = 12.0;

  // ---------------- THÈME CLAIR ----------------
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: AppColors.green,
      secondary: AppColors.orange,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.title,
      error: AppColors.danger,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.title, displayColor: AppColors.title),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.title,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.title),
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.inputLight,
        border: AppColors.borderLight,
        hint: AppColors.body,
      ),
      filledButtonTheme: _filledButton(),
      elevatedButtonTheme: _elevatedButton(),
      outlinedButtonTheme: _outlinedButton(AppColors.green),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.green),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: _chipTheme(bg: AppColors.green.withValues(alpha: 0.10)),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.body,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ---------------- THÈME SOMBRE ----------------
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.green,
      secondary: AppColors.orange,
      surface: AppColors.cardDark,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      error: AppColors.danger,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.inputDark,
        border: AppColors.borderDark,
        hint: AppColors.bodyDark,
      ),
      filledButtonTheme: _filledButton(),
      elevatedButtonTheme: _elevatedButton(),
      outlinedButtonTheme: _outlinedButton(Colors.white),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.green),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: _chipTheme(bg: AppColors.surfaceDark),
      dividerTheme: const DividerThemeData(color: AppColors.borderDark),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.bodyDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // ---------------- Sous-thèmes partagés ----------------
  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color hint,
  }) {
    OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: b(border),
      enabledBorder: b(border),
      focusedBorder: b(AppColors.green.withValues(alpha: 0.6), 1.5),
      errorBorder: b(AppColors.danger),
      focusedErrorBorder: b(AppColors.danger, 1.5),
    );
  }

  static FilledButtonThemeData _filledButton() => FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
        ),
      );

  static ElevatedButtonThemeData _elevatedButton() => ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
        ),
      );

  static OutlinedButtonThemeData _outlinedButton(Color fg) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          minimumSize: const Size.fromHeight(54),
          side: BorderSide(color: fg.withValues(alpha: 0.4)),
          textStyle: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_radius)),
        ),
      );

  static ChipThemeData _chipTheme({required Color bg}) => ChipThemeData(
        backgroundColor: bg,
        side: BorderSide.none,
        labelStyle: GoogleFonts.poppins(fontSize: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      );
}
