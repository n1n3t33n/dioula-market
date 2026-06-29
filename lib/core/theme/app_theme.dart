import 'package:flutter/material.dart';

/// Thème de l'application — couleurs inspirées du drapeau ivoirien
/// (orange / blanc / vert). Material 3.
class AppTheme {
  AppTheme._();

  static const Color orange = Color(0xFFF77F00);
  static const Color green = Color(0xFF1B9E4B);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: orange,
      primary: orange,
      secondary: green,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: orange,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
