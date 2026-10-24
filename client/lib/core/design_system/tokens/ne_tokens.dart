import 'package:flutter/material.dart';

/// Authoritative Design Tokens for Nutrient Earth based on the Stitch Botanical Specimen Verification system.
class NETokens {
  NETokens._();

  // Botanical Palette
  static const Color background = Color(0xFFFBF9F4);
  static const Color surface = Color(0xFFFBF9F4);
  static const Color surfaceDim = Color(0xFFDBDAD5);
  static const Color surfaceBright = Color(0xFFFBF9F4);
  
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F3EE);
  static const Color surfaceContainer = Color(0xFFF0EEE9);
  static const Color surfaceContainerHigh = Color(0xFFEAE8E3);
  static const Color surfaceContainerHighest = Color(0xFFE4E2DD);

  // Typography & Content Colors
  static const Color onSurface = Color(0xFF1B1C19);
  static const Color onSurfaceVariant = Color(0xFF414845);
  static const Color inverseSurface = Color(0xFF30312E);
  static const Color inverseOnSurface = Color(0xFFF2F1EC);

  // Primary & Containers
  static const Color primary = Color(0xFF000A06);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF00251D);
  static const Color onPrimaryContainer = Color(0xFF6B8E83);
  static const Color inversePrimary = Color(0xFFA9CEC2);

  // Secondary & Accents (Pine Sage)
  static const Color secondary = Color(0xFF38675A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFB8EADA);
  static const Color onSecondaryContainer = Color(0xFF3C6B5E);

  // Tertiary
  static const Color tertiary = Color(0xFF000B04);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF002614);
  static const Color onTertiaryContainer = Color(0xFF6A9077);

  // Outlines & Borders
  static const Color outline = Color(0xFF717975);
  static const Color outlineVariant = Color(0xFFC1C8C4);
  static const Color borderSubtle = Color(0xFFE4E2DD);
  static const Color borderDefault = Color(0xFFC1C8C4);

  // Errors & Alerts
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Success & Info
  static const Color success = Color(0xFF38675A);
  static const Color warning = Color(0xFFB45309);
  static const Color info = Color(0xFF1E40AF);

  // Compatibility Aliases for Existing Presentation Components
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color textMuted = outline;
  static const Color surfaceElevated = surfaceContainerLowest;
  static const Color primaryLight = secondaryContainer;
  static const Color secondaryLight = Color(0xFFE0F4EE);

  // Additional Fixed Surface/Container Tokens
  static const Color primaryFixed = Color(0xFFC7EBDD);
  static const Color onPrimaryFixed = Color(0xFF002018);
  static const Color secondaryFixed = Color(0xFFB8EADA);
  static const Color onSecondaryFixed = Color(0xFF002018);

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
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  // Box Shadows
  static const List<BoxShadow> subtleShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: -2,
    ),
  ];
}
