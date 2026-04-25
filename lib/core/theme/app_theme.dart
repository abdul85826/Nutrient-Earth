import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
export 'app_colors.dart';

class AppTheme {
  // Legacy/Unified Color Mappings
  static const Color nutrientGreen = AppColors.nutrientGreen;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color glassWhite = AppColors.glassWhite;
  static const Color glassBorder = AppColors.glassBorder;
  
  // Mapping old names to new system
  static const Color earth = AppColors.nutrientGreen;
  static const Color moss = Color(0xFF8CEE4B);
  static const Color forestMid = Color(0xFF0D2118);
  static const Color forestDeep = Color(0xFF06100B);
  static const Color cloud = Colors.white;

  static BoxDecoration glassStyle({
    double blur = 20,
    double opacity = 0.05,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: glassBorder),
    );
  }

  static ThemeData get dark {
    final textTheme = GoogleFonts.outfitTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.nutrientGreen,
        letterSpacing: 1.5,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        color: Colors.white.withValues(alpha: 0.9),
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: Colors.white.withValues(alpha: 0.7),
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: AppColors.nutrientGreen,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.nutrientGreen,
        secondary: Color(0xFF8CEE4B),
        surface: AppColors.surface,
        onSurface: Colors.white,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nutrientGreen,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }
}

