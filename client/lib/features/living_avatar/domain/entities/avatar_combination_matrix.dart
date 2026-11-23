// ==============================================================================
// Nutrient Earth — Versioned Avatar Combination Matrix
// Rigorously validates and arbitrates wardrobe, accessories, and prop attachments.
// Guarantees zero clothing clipping, zero dual-hand collisions, and physiological coherence.
// ==============================================================================

import 'avatar_appearance.dart';
import 'avatar_behaviour.dart';
import 'world_state.dart';
import 'astronomical_state.dart';

class AvatarCombinationMatrix {
  static const String matrixVersion = '2026.3.2';

  /// Resolves an adaptive appearance considering weather, temperature, diurnal rhythm, and action.
  static AvatarAppearance resolveAdaptiveAppearance({
    required AvatarAppearance base,
    required double temperatureCelsius,
    bool isRaining = false,
    bool isNight = false,
    RegionalSeason season = RegionalSeason.summer,
    CharacterAction? diurnalAction,
    CulturalPresentationPreference culturalPreference = CulturalPresentationPreference.neutralNature,
    VerifiedCulturalOccasion? occasion,
  }) {
    AvatarAppearance workingAppearance = base;

    // Apply prop from diurnalAction if base didn't explicitly override it
    if (diurnalAction != null) {
      if (diurnalAction == CharacterAction.hydrating) {
        workingAppearance = workingAppearance.copyWithSafeSlots(
          handAttachment: HandAttachmentType.waterGlass,
        );
      } else if (diurnalAction == CharacterAction.readingJournal) {
        workingAppearance = workingAppearance.copyWithSafeSlots(
          handAttachment: HandAttachmentType.leatherJournal,
        );
      } else if (diurnalAction == CharacterAction.relaxingHerbalTea) {
        workingAppearance = workingAppearance.copyWithSafeSlots(
          handAttachment: HandAttachmentType.herbalTeaCup,
        );
      }
    }

    final weatherCond = isRaining
        ? WeatherConditionType.heavyShowers
        : WeatherConditionType.partlyCloudy;
    final twilight = isNight ? TwilightState.deepNight : TwilightState.day;

    return resolveAppearance(
      requested: workingAppearance,
      temperatureCelsius: temperatureCelsius,
      weatherCondition: weatherCond,
      twilight: twilight,
      season: season,
      culturalPreference: culturalPreference,
      occasion: occasion,
    );
  }

  /// Resolves an approved, fully compatible AvatarAppearance based on physical world constraints.
  static AvatarAppearance resolveAppearance({
    required AvatarAppearance requested,
    required double temperatureCelsius,
    required WeatherConditionType weatherCondition,
    required TwilightState twilight,
    required RegionalSeason season,
    required CulturalPresentationPreference culturalPreference,
    VerifiedCulturalOccasion? occasion,
  }) {
    // 1. Temperature-governed outerwear and fabric selection
    ClothingType resolvedClothing = requested.clothing;
    OuterwearType resolvedOuterwear = requested.outerwear;
    String resolvedClothingColor = requested.clothingColorHex;

    if (temperatureCelsius < 8.0) {
      // Cold Climate: Ensure thermal protection
      if (resolvedClothing == ClothingType.linenShirt || resolvedClothing == ClothingType.activeTee) {
        resolvedClothing = ClothingType.knitSweater;
        resolvedClothingColor = '#1A3B32'; // Forest thermal pine
      }
      if (resolvedOuterwear == OuterwearType.none) {
        resolvedOuterwear = season.isMonsoon
            ? OuterwearType.rainWindbreaker
            : (season == RegionalSeason.hemanta || season == RegionalSeason.shishira || culturalPreference == CulturalPresentationPreference.indicTraditional
                ? OuterwearType.traditionalShawl
                : OuterwearType.thermalJacket);
      }
    } else if (temperatureCelsius > 28.0) {
      // Warm / Hot Climate: Lightweight, breathable fabric, eliminate heavy jackets
      if (resolvedClothing == ClothingType.knitSweater) {
        resolvedClothing = culturalPreference == CulturalPresentationPreference.indicTraditional
            ? ClothingType.organicKurta
            : ClothingType.linenShirt;
        resolvedClothingColor = '#FAF8F5'; // Off-white breathable linen
      }
      if (resolvedOuterwear == OuterwearType.thermalJacket || resolvedOuterwear == OuterwearType.traditionalShawl) {
        resolvedOuterwear = OuterwearType.none;
      }
    }

    // 2. Weather adjustments: Rain handling
    if (weatherCondition.hasPrecipitation) {
      if (resolvedOuterwear == OuterwearType.none) {
        resolvedOuterwear = OuterwearType.rainWindbreaker;
      }
    }

    // 3. Cultural Festive Attire (Strict opt-in only)
    if (occasion != null && !culturalPreference.isNeutral) {
      if (culturalPreference == CulturalPresentationPreference.indicTraditional) {
        resolvedClothing = ClothingType.organicKurta;
        resolvedClothingColor = '#0B2B26'; // Regal deep emerald
        if (temperatureCelsius < 20.0 && resolvedOuterwear == OuterwearType.none) {
          resolvedOuterwear = OuterwearType.traditionalShawl;
        }
      }
    }

    // 4. Night-time Diurnal Shift
    if (twilight == TwilightState.deepNight) {
      if (temperatureCelsius >= 8.0) {
        resolvedClothing = ClothingType.loungewear;
        resolvedClothingColor = '#2C3E35'; // Deep restorative sage
        resolvedOuterwear = OuterwearType.none;
      }
    }

    // 5. Hand Attachment Arbitration (Strict slot exclusivity & physics rules)
    HandAttachmentType left = requested.leftHandAttachment;
    HandAttachmentType right = requested.rightHandAttachment;

    // Rule A: An item cannot be in both hands
    if (left != HandAttachmentType.none && left == right) {
      left = HandAttachmentType.none;
    }

    // Rule B: Night-time deep night does not hold daytime books or athletic items
    if (twilight == TwilightState.deepNight) {
      if (left == HandAttachmentType.scientificBook || left == HandAttachmentType.leatherJournal) {
        left = HandAttachmentType.none;
      }
      if (right == HandAttachmentType.scientificBook || right == HandAttachmentType.leatherJournal) {
        right = HandAttachmentType.none;
      }
      // Nighttime default: calming herbal tea or resting hands
      if (right == HandAttachmentType.none && left == HandAttachmentType.none && requested.rightHandAttachment != HandAttachmentType.none) {
        right = HandAttachmentType.herbalTeaCup;
      }
    }

    // Rule C: Heavy rain outdoors prevents vulnerable paper journals
    if (weatherCondition == WeatherConditionType.heavyShowers) {
      if (left == HandAttachmentType.leatherJournal || left == HandAttachmentType.scientificBook) {
        left = HandAttachmentType.none;
      }
      if (right == HandAttachmentType.leatherJournal || right == HandAttachmentType.scientificBook) {
        right = HandAttachmentType.none;
      }
    }

    // Rule D: High heat recommends hydration prop
    if (temperatureCelsius > 32.0 && left == HandAttachmentType.none && right == HandAttachmentType.none) {
      right = HandAttachmentType.waterGlass;
    }

    return AvatarAppearance.validated(
      clothing: resolvedClothing,
      clothingColorHex: resolvedClothingColor,
      outerwear: resolvedOuterwear,
      outerwearColorHex: requested.outerwearColorHex,
      accessory: requested.accessory,
      headwear: (temperatureCelsius < 4.0 && requested.headwear == HeadwearType.none)
          ? HeadwearType.merinoBeanie
          : requested.headwear,
      leftHand: left,
      rightHand: right,
    );
  }
}
