import 'package:flutter/material.dart';

/// Nutrient Earth v2 — Biological Calm Palette
/// Inspired by: Apple Health, WHOOP, Oura Ring, Pixel UI
/// Philosophy: Calm, premium, breathable, organic, trustworthy
class NEColors {
  NEColors._();

  // ─── Core Backgrounds ───────────────────────────────────────────────────────
  static const Color background = Color(0xFF0F1114); // Deep graphite
  static const Color surface = Color(0xFF1A1D21); // Card surface
  static const Color surfaceLight = Color(0xFF242830); // Elevated surface
  static const Color surfaceBright = Color(0xFF2E323A); // Active/hover surface

  // ─── Brand Accent ───────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF7CB462); // Soft biological green
  static const Color accentLight = Color(0xFFA8D98A); // Light green highlights
  static const Color accentDim = Color(0xFF4A6B3A); // Muted green for bg tints
  static const Color accentSurface = Color(
    0x1A7CB462,
  ); // 10% green for card fills

  // ─── Semantic Colors ────────────────────────────────────────────────────────
  static const Color recovery = Color(0xFF6BA3E8); // Cool blue for recovery
  static const Color hydration = Color(0xFF5BC0DE); // Water blue
  static const Color energy = Color(0xFFE8A849); // Warm amber
  static const Color stress = Color(0xFFD4625E); // Calm red
  static const Color sleep = Color(0xFF9B7ED8); // Soft purple
  static const Color movement = Color(0xFF4ECDC4); // Teal

  // ─── Status ─────────────────────────────────────────────────────────────────
  static const Color statusGreen = Color(0xFF7CB462);
  static const Color statusAmber = Color(0xFFE8A849);
  static const Color statusRed = Color(0xFFD4625E);

  // ─── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF2F2F2); // Primary text
  static const Color textSecondary = Color(0xFF8B8F96); // Secondary text
  static const Color textTertiary = Color(0xFF555962); // Subtle labels
  static const Color textInverse = Color(0xFF0F1114); // Text on light bg

  // ─── UI Elements ────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFF2A2D33);
  static const Color border = Color(0xFF2E323A);
  static const Color shimmer = Color(0xFF343840);
  static const Color scrim = Color(0xCC0F1114); // 80% overlay

  // ─── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient morningGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C2030), Color(0xFF0F1114)],
  );

  static const LinearGradient eveningGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1520), Color(0xFF0F1114)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2228), Color(0xFF1A1D21)],
  );

  // ─── Helpers ────────────────────────────────────────────────────────────────
  static Color withAlpha(Color color, double alpha) =>
      color.withValues(alpha: alpha);
}

// Legacy compatibility aliases — used during migration
class AppColors {
  static const Color neonGreen = NEColors.accent;
  static const Color oliveGreen = NEColors.accent;
  static const Color nutrientGreen = NEColors.accent;
  static const Color background = NEColors.background;
  static const Color surface = NEColors.surface;
  static const Color cosmicBlack = NEColors.background;
  static const Color warmOrange = NEColors.energy;
  static const Color gold = NEColors.energy;
  static const Color textPrimary = NEColors.textPrimary;
  static const Color textSecondary = NEColors.textSecondary;
  static const Color glassBorder = NEColors.border;
  static const Color glassWhite = NEColors.surfaceLight;
  static const Color success = NEColors.statusGreen;
  static const Color warning = NEColors.statusAmber;
  static const Color danger = NEColors.statusRed;
  static const Color error = NEColors.statusRed;
  static const Color info = NEColors.recovery;
  static Color glass = NEColors.surface;
  static Color white05 = NEColors.surfaceLight;
}
