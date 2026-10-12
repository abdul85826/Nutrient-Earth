import 'package:flutter/material.dart';

/// Nutrient Earth Design Tokens — Sovereign Botanical System
class NEColors {
  const NEColors._();

  // Primary Botanical Palette
  static const Color primary = Color(0xFF1B382B); // Deep Botanical Evergreen
  static const Color primaryLight = Color(0xFF2C5642);
  static const Color primaryDark = Color(0xFF0F221A);
  static const Color primaryMuted = Color(0xFF4A735E);

  // Background & Surfaces (Warm Ivory & Calming Tones)
  static const Color background = Color(0xFFF9F7F2); // Warm Ivory Canvas
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF3F0E9);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF19231D); // Deep Obsidian Green
  static const Color textSecondary = Color(0xFF56655D); // Muted Sage
  static const Color textTertiary = Color(0xFF829188); // Subdued Leaf
  static const Color textMuted = Color(0xFFA6B3AB);

  // Accent & Botanical Foliage
  static const Color accent = Color(0xFF43765A);
  static const Color foliageLeaf = Color(0xFF2E6B4E);
  static const Color earthWarm = Color(0xFFB87D4B);

  // Status & Feedback Colors
  static const Color error = Color(0xFFB3261E);
  static const Color errorBackground = Color(0xFFF9DEDC);
  static const Color warning = Color(0xFF8D5B00);
  static const Color warningBackground = Color(0xFFFFF0D4);
  static const Color success = Color(0xFF2E6B4E);
  static const Color successBackground = Color(0xFFE8F5E9);

  // Borders & Dividers
  static const Color border = Color(0xFFE2DDD3);
  static const Color borderSubtle = Color(0xFFEFECE5);
  static const Color divider = Color(0xFFE8E4DB);

  // Shadows
  static const Color shadowSubtle = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
}

class NETypography {
  const NETypography._();

  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: NEColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: NEColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: NEColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: NEColors.textPrimary,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: NEColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: NEColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: NEColors.textPrimary,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: NEColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: NEColors.textPrimary,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: NEColors.textSecondary,
    letterSpacing: 0.2,
  );
}

class NESpacing {
  const NESpacing._();

  static const double xxs = 4.0;
  static const double xs = 6.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: s20,
    vertical: s16,
  );
}

class NERadius {
  const NERadius._();

  static const double xs = 4.0;
  static const double s8 = 8.0;
  static const double card = 16.0;
  static const double cardSecondary = 12.0;
  static const double input = 12.0;
  static const double chip = 20.0;
  static const double pill = 100.0;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius cardSecondaryRadius = BorderRadius.all(Radius.circular(cardSecondary));
  static const BorderRadius inputRadius = BorderRadius.all(Radius.circular(input));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
}

class NeTokens {
  const NeTokens._();

  // Botanical Palette
  static const Color botanicalEvergreen = Color(0xFF1B382B);
  static const Color warmIvory = Color(0xFFF9F7F2);
  static const Color deepForest = Color(0xFF19231D);
  static const Color mossGreen = Color(0xFF2E6B4E);
  static const Color sandDune = Color(0xFFE2DDD3);
  static const Color slateMuted = Color(0xFF56655D);
  static const Color alertCrimson = Color(0xFFB3261E);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Fonts
  static const String fontFamilySans = 'Roboto';
  static const String fontFamilySerif = 'Georgia';

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing6 = 6.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Radius
  static const double radius6 = 6.0;
  static const double radius10 = 10.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 999.0;

  // Shadow
  static const BoxShadow shadowBotanical = BoxShadow(
    color: Color(0x1A1B382B),
    blurRadius: 16.0,
    offset: Offset(0, 4),
  );
}

