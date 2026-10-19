import 'package:flutter/material.dart';

import 'tokens/ne_tokens.dart';

/// Application theme configurations for Nutrient Earth.
class NETheme {
  NETheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NETokens.background,
      colorScheme: const ColorScheme.dark(
        primary: NETokens.primary,
        onPrimary: NETokens.textInverse,
        secondary: NETokens.secondary,
        onSecondary: Colors.white,
        surface: NETokens.surface,
        onSurface: NETokens.textPrimary,
        error: NETokens.error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: NETokens.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: NETokens.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: NETokens.textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: NETokens.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
        ),
        headlineMedium: TextStyle(
          color: NETokens.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: TextStyle(
          color: NETokens.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: NETokens.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: NETokens.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: NETokens.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NETokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
