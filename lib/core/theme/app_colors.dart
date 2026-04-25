import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color nutrientGreen = Color(0xFFC6FF7E);
  static const Color background = Color(0xFF06100B);
  static const Color surface = Color(0xFF0D2118);
  static const Color accent = Color(0xFFC6FF7E);
  static const Color primary = Color(0xFF00FF88);
  
  // Neutral Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color danger = Color(0xFFEF5350);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC6FF7E),
      Color(0xFF8CEE4B),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D2118),
      Color(0xFF06100B),
    ],
  );

  // Helpers
  static Color glass = Colors.white.withValues(alpha: 0.06);
}
