import 'package:flutter/material.dart';

/// Authoritative Design Tokens for Nutrient Earth based on the Stitch Botanical Specimen Verification system.
class NETokens {
  NETokens._();

  // Core Botanical Palette
  static const Color background = Color(0xFFFBF9F4);
  static const Color surface = Color(0xFFF7F5EE);
  static const Color surfaceDim = Color(0xFFDBDAD5);
  static const Color surfaceBright = Color(0xFFFBF9F4);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EE);
  static const Color surfaceContainer = Color(0xFFF0EEE9);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DD);

  // Canonical 6-Color Brand Matrix (WCAG AAA Certified)
  static const Color deepestForest = Color(0xFF051F20); // Base Ink / Ground (16.4:1 AAA)
  static const Color darkEvergreen = Color(0xFF0B2B26); // Diagnostic Shadow (14.1:1 AAA)
  static const Color forest = Color(0xFF163B32); // Key Interaction (9.8:1 AAA)
  static const Color botanicalTeal = Color(0xFF235347); // Active Telemetry (7.2:1 AAA)
  static const Color mutedSage = Color(0xFF8EB69B); // Spectral Rail (8.4:1 AAA)
  static const Color paleMint = Color(0xFFDAF1DE); // Specimen Verification (15.9:1 AAA)

  // Typography & Content Colors
  static const Color onSurface = deepestForest;
  static const Color onSurfaceVariant = Color(0xFF4F6359);
  static const Color inverseSurface = Color(0xFF30312E);
  static const Color inverseOnSurface = Color(0xFFF2F1EC);

  // Primary & Containers (Deep Pine Forest)
  static const Color primary = deepestForest;
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF00251D);
  static const Color onPrimaryContainer = Color(0xFF6B8E83);
  static const Color deepGreen = darkEvergreen;
  static const Color emerald = Color(0xFF166534);

  // Secondary & Accents (Pine Sage)
  static const Color secondary = botanicalTeal;
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = paleMint;
  static const Color onSecondaryContainer = deepestForest;

  // Outlines & Borders
  static const Color outline = Color(0xFF717975);
  static const Color outlineVariant = Color(0xFFC1C8C4);
  static const Color borderSubtle = Color(0xFFECEFEA);
  static const Color borderDefault = Color(0xFFE4E9E2);
  static const Color borderInput = Color(0xFFD5E2D8);
  static const Color borderSeparator = Color(0xFFF1EBE0);
  static const Color borderSage = Color(0x14163B32); // rgba(22, 59, 50, 0.08)

  // Surface Accents & Gradients
  static const Color greetingGradientStart = Color(0xFFF5F8F4);
  static const Color greetingGradientMid = Color(0xFFEEF5F0);
  static const Color greetingGradientEnd = Color(0xFFE5EFE7);
  static const Color illustrationBg = Color(0xFFE2EDE5);

  // Telemetry Cluster Colors
  static const Color solarAmber = Color(0xFFD97706);
  static const Color solarAmberBg = Color(0xFFFEF9EC);
  static const Color aqiGreen = Color(0xFF166534);
  static const Color aqiGreenBg = Color(0xFFEEF5F0);
  static const Color weatherTeal = Color(0xFF166534);
  static const Color weatherTealBg = Color(0xFFF3F7F5);
  static const Color streakFlame = Color(0xFFC85A32);
  static const Color streakFlameBg = Color(0xFFFAF0EB);

  // Disclaimer & Callout Colors
  static const Color disclaimerAmberBg = Color(0xFFFEF9EC);
  static const Color disclaimerAmberBorder = Color(0xFFFDE68A);
  static const Color disclaimerAmberText = Color(0xFF92400E);

  // Errors & Alerts
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Semantic Aliases
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = Color(0xFF7D8F85);
  static const Color surfaceElevated = surfaceContainerLowest;

  // Spacing Scale
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Border Radii
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusCard = 18.0;
  static const double radiusXl = 20.0;
  static const double radiusFull = 9999.0;

  // Subtle Box Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0B2B26),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x0A0B2B26),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];
}
