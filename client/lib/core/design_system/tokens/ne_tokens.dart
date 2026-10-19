import 'package:flutter/material.dart';

/// Design tokens for Nutrient Earth following UI/UX Pro Max guidelines.
class NETokens {
  NETokens._();

  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0A0D14);
  static const Color surface = Color(0xFF131823);
  static const Color surfaceElevated = Color(0xFF1C2333);
  static const Color surfaceHighlight = Color(0xFF263045);

  // Borders
  static const Color borderSubtle = Color(0x1AFFFFFF); // 10% white
  static const Color borderDefault = Color(0x2EFFFFFF); // 18% white
  static const Color borderFocus = Color(0xFF10B981);

  // Accents & Semantics
  static const Color primary = Color(0xFF10B981); // Emerald
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF059669);
  static const Color secondary = Color(0xFF6366F1); // Indigo
  static const Color secondaryLight = Color(0xFF818CF8);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Crimson
  static const Color info = Color(0xFF38BDF8); // Sky blue
  static const Color success = Color(0xFF10B981);

  // Data Source Category Colors
  static const Color measuredBadge = Color(0xFF10B981); // Green (Clinical/Lab)
  static const Color userReportedBadge = Color(
    0xFFF59E0B,
  ); // Amber (Self-logged)
  static const Color aiEstimatedBadge = Color(0xFF818CF8); // Indigo (Modeled)

  // Typography Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFF0A0D14);

  // Spacing
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;

  // Radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 14.0;
  static const double radiusLg = 20.0;
  static const double radiusFull = 9999.0;

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> glowShadow = [
    BoxShadow(
      color: Color(0x2610B981),
      offset: Offset(0, 0),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
