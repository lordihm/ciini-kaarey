import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette « manuscrit » : encre profonde, or, parchemin — identité distincte.
class AppColors {
  AppColors._();

  static const ink = Color(0xFF1A2332);
  static const inkSoft = Color(0xFF2C3A4F);
  static const gold = Color(0xFFB0892E);
  static const goldDeep = Color(0xFF8C6A1F);
  static const parchment = Color(0xFFEDE4CE);
  static const parchmentDeep = Color(0xFFD9CBA8);
  static const teal = Color(0xFF2F6F6A);
  static const errorRed = Color(0xFF8B3A3A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.ink,
      brightness: Brightness.light,
      primary: AppColors.ink,
      onPrimary: AppColors.parchment,
      secondary: AppColors.goldDeep,
      tertiary: AppColors.teal,
      surface: const Color(0xFFF5EEDC),
      error: AppColors.errorRed,
    );
    return _base(scheme, Brightness.light).copyWith(
      scaffoldBackgroundColor: AppColors.parchment,
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.dark,
      primary: AppColors.gold,
      onPrimary: AppColors.ink,
      secondary: AppColors.gold,
      tertiary: const Color(0xFF63B0A9),
      surface: const Color(0xFF1A2332),
      error: const Color(0xFFCF8A8A),
    );
    return _base(scheme, Brightness.dark).copyWith(
      scaffoldBackgroundColor: const Color(0xFF121820),
    );
  }

  static ThemeData _base(ColorScheme scheme, Brightness brightness) {
    final baseText = GoogleFonts.notoSansTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    final display = GoogleFonts.notoSerifTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      textTheme: baseText.copyWith(
        displaySmall: display.displaySmall?.copyWith(fontWeight: FontWeight.bold),
        headlineMedium:
            display.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
        titleLarge: display.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: display.titleLarge?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 1.5,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: scheme.secondary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.secondary,
          foregroundColor: scheme.onSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
    );
  }
}
