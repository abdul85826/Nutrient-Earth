import 'package:flutter/material.dart';

/// Nutrient Earth Brand Color System
/// All colors must be sourced from this file — no hardcoded hex in widgets.
abstract class AppColors {
  // ─── Primary Brand ───────────────────────────────────────────────────────────

  /// Forest Deep — primary background, hero fills, navbar active
  static const Color forestDeep = Color(0xFF1A3C2E);

  /// Living Green — secondary accent, icons, highlights
  static const Color livingGreen = Color(0xFF4A7C5F);

  /// Earth Gold — CTA buttons, tagline text, premium accents
  static const Color earthGold = Color(0xFFC8A96E);

  /// Natural Cream — main background, cards, light surfaces
  static const Color naturalCream = Color(0xFFF5F0EB);

  /// Soil Dark — primary text, headings on light backgrounds
  static const Color soilDark = Color(0xFF2D2D2A);

  // ─── Extended Palette ────────────────────────────────────────────────────────

  /// Forest Deep 80% opacity — overlays, modal scrim
  static const Color forestDeepLight = Color(0xCC1A3C2E);

  /// Living Green 20% — subtle tinted backgrounds, chips
  static const Color livingGreenSoft = Color(0x334A7C5F);

  /// Earth Gold 15% — warm card tints
  static const Color earthGoldSoft = Color(0x26C8A96E);

  /// Earth Gold Dark — pressed state for gold buttons
  static const Color earthGoldDark = Color(0xFFAF8B4A);

  /// Natural Cream Dark — card borders, dividers
  static const Color naturalCreamDark = Color(0xFFE8E0D6);

  /// Natural Cream Darker — input field fills
  static const Color naturalCreamDeeper = Color(0xFFEDE6DC);

  // ─── Neutral & UI ────────────────────────────────────────────────────────────

  /// Pure White — text on dark backgrounds, icon fills
  static const Color white = Color(0xFFFFFFFF);

  /// Off White — soft white surfaces
  static const Color offWhite = Color(0xFFFAF7F4);

  /// Slate Grey — inactive nav icons, hints, secondary body text
  static const Color slateGrey = Color(0xFF888888);

  /// Muted Grey — disabled states, placeholder text
  static const Color mutedGrey = Color(0xFFBBBBBB);

  /// Dark Charcoal — deep text, high contrast labels
  static const Color charcoal = Color(0xFF1C1C1A);

  // ─── Semantic / Feedback ─────────────────────────────────────────────────────

  /// Success — confirmation, positive health metrics
  static const Color success = Color(0xFF3A7D44);

  /// Warning — moderate alerts, nutritional cautions
  static const Color warning = Color(0xFFD4880A);

  /// Error — field errors, critical alerts
  static const Color error = Color(0xFFC0392B);

  /// Info — tips, supplementary information
  static const Color info = Color(0xFF2980B9);

  // ─── Surface Layers ──────────────────────────────────────────────────────────

  /// Card surface on cream background
  static const Color cardSurface = Color(0xFFFFFFFF);

  /// Card surface on forest background
  static const Color cardSurfaceDark = Color(0xFF243D30);

  /// Divider line on light backgrounds
  static const Color dividerLight = Color(0xFFE2D9CE);

  /// Divider line on dark backgrounds
  static const Color dividerDark = Color(0xFF2E4E3C);

  // ─── Gradient Helpers ────────────────────────────────────────────────────────

  static const LinearGradient forestGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A3C2E), Color(0xFF243D30)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC8A96E), Color(0xFFAF8B4A)],
  );

  static const LinearGradient creamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F0EB), Color(0xFFEDE6DC)],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A7C5F), Color(0xFF1A3C2E)],
  );
}
