import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens/ne_tokens.dart';

/// Application theme configurations for Nutrient Earth following Stitch design tokens.
class NETheme {
  NETheme._();

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.manropeTextTheme();
    final monoBase = GoogleFonts.jetBrainsMono();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: NETokens.background,
      colorScheme: const ColorScheme.light(
        primary: NETokens.primary,
        onPrimary: NETokens.onPrimary,
        primaryContainer: NETokens.primaryContainer,
        onPrimaryContainer: NETokens.onPrimaryContainer,
        secondary: NETokens.secondary,
        onSecondary: NETokens.onSecondary,
        secondaryContainer: NETokens.secondaryContainer,
        onSecondaryContainer: NETokens.onSecondaryContainer,
        surface: NETokens.surface,
        onSurface: NETokens.onSurface,
        surfaceContainerLow: NETokens.surfaceContainerLow,
        surfaceContainer: NETokens.surfaceContainer,
        surfaceContainerHigh: NETokens.surfaceContainerHigh,
        outline: NETokens.outline,
        outlineVariant: NETokens.outlineVariant,
        error: NETokens.error,
        onError: NETokens.onError,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NETokens.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: const IconThemeData(color: NETokens.onSurface),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        displayMedium: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.25,
        ),
        headlineLarge: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineMedium: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        headlineSmall: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.35,
        ),
        titleLarge: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.manrope(
          color: NETokens.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: NETokens.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.manrope(
          color: NETokens.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: monoBase.copyWith(
          color: NETokens.onSurface,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelMedium: monoBase.copyWith(
          color: NETokens.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
        labelSmall: monoBase.copyWith(
          color: NETokens.outline,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NETokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
