// ==============================================================================
// Nutrient Earth — Living Avatar Engine Comprehensive Test Suite
// Verifies:
// 1. Permanent Identity Immutability & Slot-Isolation Combination Matrix
// 2. 100% Offline Deterministic Astronomical Engine (NOAA Solar & Meeus Lunar)
// 3. Seasonal Chronobiology (Western 4-Season & Indian 6-Ritu Framework)
// 4. Cultural Presentation Privacy & Opt-in Isolation
// 5. High-Performance Multi-Layer Flutter Rendering & Reduced Motion
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:nutrient_earth_client/features/living_avatar/domain/entities/astronomical_state.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/entities/avatar_identity.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/entities/avatar_appearance.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/entities/avatar_behaviour.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/entities/world_state.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/entities/avatar_scene_state.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/entities/avatar_combination_matrix.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/services/astronomical_calculator.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/services/season_resolver.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/services/cultural_calendar_resolver.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/services/weather_state_adapter.dart';
import 'package:nutrient_earth_client/features/living_avatar/domain/services/avatar_state_resolver.dart';
import 'package:nutrient_earth_client/features/living_avatar/presentation/widgets/living_avatar_view.dart';
import 'package:nutrient_earth_client/features/living_avatar/presentation/widgets/avatar_accessibility_wrapper.dart';
import 'package:nutrient_earth_client/features/profile/presentation/widgets/avatar_state_switcher.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';

class MockTestProfileRepository implements ProfileRepository {
  final UserProfileContext _profile;

  MockTestProfileRepository(this._profile);

  @override
  Future<UserProfileContext?> getProfile(String userId) async => _profile;

  @override
  Future<UserProfileContext?> getCurrentUserProfile({String? explicitUserId}) async => _profile;

  @override
  UserProfileContext? getCachedProfileSync(String? userId) => _profile;

  @override
  Future<bool> saveUserProfile(UserProfileContext profile) async => true;

  @override
  Future<bool> clearCacheForUser(String userId) async => true;

  @override
  Future<bool> updateProfile(UserProfileContext profile) async => true;

  @override
  Future<bool> updateAvatar({required String skinTone, Map<String, dynamic>? avatarConfig}) async => true;

  @override
  Future<bool> resetAvatar() async => true;
}

void main() {
  group('1. Permanent Avatar Identity & Combination Matrix', () {
    test('Identity parameters remain immutable across state transitions', () {
      final initialIdentity = AvatarIdentity(
        identityId: 'usr_sarah_immutable',
        name: 'Sarah',
        faceGeometry: FaceGeometryType.oval,
        eyeShape: EyeShapeType.almond,
        noseShape: NoseShapeType.straight,
        mouthShape: MouthShapeType.neutral,
        hairIdentity: HairstyleIdentity.wavyMedium,
        skinToneHex: '#E0AC69',
        eyeColorHex: '#2C1E14',
        hairColorHex: '#1B1C19',
      );

      // Resolve scene during daytime sunny conditions
      final daytimeScene = AvatarStateResolver.resolve(
        identity: initialIdentity,
        timeUtc: DateTime.utc(2026, 6, 21, 19, 0), // Summer noon PDT
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
        weather: const AmbientWeatherState(
          temperatureCelsius: 28.0,
          condition: WeatherConditionType.clearSky,
          atmosphericAqi: 22.0,
          relativeHumidity: 40.0,
        ),
      );

      // Resolve scene during nocturnal freezing storm
      final stormNightScene = AvatarStateResolver.resolve(
        identity: initialIdentity,
        timeUtc: DateTime.utc(2026, 12, 21, 6, 0), // Winter midnight PDT
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
        weather: const AmbientWeatherState(
          temperatureCelsius: 2.0,
          condition: WeatherConditionType.heavyShowers,
          atmosphericAqi: 45.0,
          relativeHumidity: 95.0,
        ),
      );

      // Verify that facial geometry and biological identity remain 100% IDENTICAL
      expect(daytimeScene.identity.identityId, equals(initialIdentity.identityId));
      expect(stormNightScene.identity.identityId, equals(initialIdentity.identityId));
      expect(stormNightScene.identity.faceGeometry, equals(daytimeScene.identity.faceGeometry));
      expect(stormNightScene.identity.eyeShape, equals(daytimeScene.identity.eyeShape));
      expect(stormNightScene.identity.noseShape, equals(daytimeScene.identity.noseShape));
      expect(stormNightScene.identity.skinToneHex, equals(daytimeScene.identity.skinToneHex));
      expect(stormNightScene.identity.hairIdentity, equals(daytimeScene.identity.hairIdentity));
    });

    test('Combination matrix prevents dual-hand conflicts and adapts to weather', () {
      // Hot weather (30°C) -> breathable linen/cotton shirt
      final hotResolved = AvatarCombinationMatrix.resolveAdaptiveAppearance(
        base: AvatarAppearance.defaultBaseline(),
        temperatureCelsius: 30.0,
        isRaining: false,
        isNight: false,
        season: RegionalSeason.summer,
        diurnalAction: CharacterAction.hydrating,
      );
      expect(hotResolved.clothing, equals(ClothingType.botanicalLinenShirt));
      expect(hotResolved.outerwear, equals(OuterwearType.none));
      expect(hotResolved.handAttachment, equals(HandAttachmentType.waterGlass));

      // Heavy rain -> outerwear applied and paper props stowed
      final rainResolved = AvatarCombinationMatrix.resolveAdaptiveAppearance(
        base: const AvatarAppearance(
          clothing: ClothingType.botanicalLinenShirt,
          handAttachment: HandAttachmentType.leatherJournal, // Unsafe paper prop in rain!
        ),
        temperatureCelsius: 16.0,
        isRaining: true,
        isNight: false,
        season: RegionalSeason.autumn,
        diurnalAction: CharacterAction.readingJournal,
      );
      expect(rainResolved.outerwear, equals(OuterwearType.tailoredTrench));
      // Journal must be safely stowed in rain
      expect(rainResolved.handAttachment, isNot(HandAttachmentType.leatherJournal));

      // Freezing weather (2°C) -> insulated coat
      final winterResolved = AvatarCombinationMatrix.resolveAdaptiveAppearance(
        base: AvatarAppearance.defaultBaseline(),
        temperatureCelsius: 2.0,
        isRaining: false,
        isNight: true,
        season: RegionalSeason.winter,
        diurnalAction: CharacterAction.relaxingHerbalTea,
      );
      expect(winterResolved.outerwear, equals(OuterwearType.insulatedCoat));
      expect(winterResolved.handAttachment, equals(HandAttachmentType.herbalMug));
    });

    test('Slot exclusivity prevents multi-slot collision', () {
      final base = AvatarAppearance.defaultBaseline();
      final customized = base.copyWithSafeSlots(
        outerwear: OuterwearType.knittedCardigan,
        handAttachment: HandAttachmentType.waterGlass,
      );

      expect(customized.outerwear, equals(OuterwearType.knittedCardigan));
      expect(customized.handAttachment, equals(HandAttachmentType.waterGlass));

      // Stowing outerwear leaves other slots intact
      final stowed = customized.copyWithSafeSlots(outerwear: OuterwearType.none);
      expect(stowed.outerwear, equals(OuterwearType.none));
      expect(stowed.handAttachment, equals(HandAttachmentType.waterGlass));
    });
  });

  group('2. Continuous Astronomical Engine (NOAA & Meeus Offline Math)', () {
    test('Calculates solar noon and midnight altitude accurately in San Francisco', () {
      // June 21, 2026 Solar Noon in San Francisco (around 20:12 UTC)
      final noonState = AstronomicalCalculator.calculate(
        timeUtc: DateTime.utc(2026, 6, 21, 20, 12),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );

      // Solar altitude should be high in the sky (> 65°) on Summer Solstice noon
      expect(noonState.solarAltitude, greaterThan(65.0));
      expect(noonState.isDay, isTrue);
      expect(noonState.isNight, isFalse);

      // June 21, 2026 Solar Midnight in San Francisco (around 08:12 UTC)
      final midnightState = AstronomicalCalculator.calculate(
        timeUtc: DateTime.utc(2026, 6, 21, 8, 12),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );

      // Solar altitude should be deep below horizon (< -18°) at midnight
      expect(midnightState.solarAltitude, lessThan(-18.0));
      expect(midnightState.isDay, isFalse);
      expect(midnightState.isNight, isTrue);
    });

    test('Resolves twilight tiers accurately', () {
      // Civil twilight: -6.0° <= solarAltitude < 0.0°
      final civilState = WorldAstronomyState.defaultBaseline().copyWith(
        solarAltitude: -3.5,
        solarAzimuth: 290.0,
        sunriseUtc: DateTime.utc(2026, 6, 21, 12, 48),
        sunsetUtc: DateTime.utc(2026, 6, 21, 3, 35),
        lunarPhase: LunarPhase.waxingCrescent,
        lunarIllumination: 0.25,
        lunarAltitude: 15.0,
        lunarAzimuth: 180.0,
        timezoneId: 'America/Los_Angeles',
      );
      expect(civilState.isCivilTwilight, isTrue);
      expect(civilState.isDay, isFalse);
      expect(civilState.isNight, isFalse);

      // Nautical twilight: -12.0° <= solarAltitude < -6.0°
      final nauticalState = civilState.copyWith(solarAltitude: -9.0);
      expect(nauticalState.isNauticalTwilight, isTrue);

      // Full night: solarAltitude < -18.0°
      final fullNightState = civilState.copyWith(solarAltitude: -25.0);
      expect(fullNightState.isNight, isTrue);
    });

    test('Handles polar day (midnight sun) and polar night without NaN or crashes', () {
      // Longyearbyen, Svalbard (78.2232° N, 15.6267° E) during Summer Solstice
      final polarDayState = AstronomicalCalculator.calculate(
        timeUtc: DateTime.utc(2026, 6, 21, 0, 0), // Midnight UTC
        latitude: 78.2232,
        longitude: 15.6267,
        timezoneId: 'Arctic/Longyearbyen',
      );

      expect(polarDayState.isPolarDay, isTrue);
      expect(polarDayState.solarAltitude, greaterThan(0.0)); // Stays above horizon even at midnight

      // Longyearbyen during Winter Solstice (Polar Night)
      final polarNightState = AstronomicalCalculator.calculate(
        timeUtc: DateTime.utc(2026, 12, 21, 12, 0), // Midday UTC
        latitude: 78.2232,
        longitude: 15.6267,
        timezoneId: 'Arctic/Longyearbyen',
      );

      expect(polarNightState.isPolarNight, isTrue);
      expect(polarNightState.solarAltitude, lessThan(0.0)); // Stays below horizon even at noon
    });

    test('Computes Meeus lunar phase and illumination fraction within valid [0.0, 1.0] bounds', () {
      final state = AstronomicalCalculator.calculate(
        timeUtc: DateTime.utc(2026, 10, 14, 15, 30),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );

      expect(state.lunarIlluminationFraction, greaterThanOrEqualTo(0.0));
      expect(state.lunarIlluminationFraction, lessThanOrEqualTo(1.0));
      expect(state.lunarPhase, isA<LunarPhase>());
      expect(state.lunarPhase.displayName, isNotEmpty);
    });
  });

  group('3. Seasonal Chronobiology & Cultural Presentation', () {
    test('Resolves Western 4 seasons in Northern Hemisphere', () {
      final summer = SeasonResolver.resolve(
        date: DateTime.utc(2026, 7, 15),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );
      expect(summer, equals(RegionalSeason.summer));

      final winter = SeasonResolver.resolve(
        date: DateTime.utc(2026, 1, 15),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );
      expect(winter, equals(RegionalSeason.winter));
    });

    test('Inverts seasons correctly in Southern Hemisphere', () {
      // Sydney, Australia (-33.8688° S): January is Summer, July is Winter
      final sydSummer = SeasonResolver.resolve(
        date: DateTime.utc(2026, 1, 15),
        latitude: -33.8688,
        longitude: 151.2093,
        timezoneId: 'Australia/Sydney',
      );
      expect(sydSummer, equals(RegionalSeason.summer));

      final sydWinter = SeasonResolver.resolve(
        date: DateTime.utc(2026, 7, 15),
        latitude: -33.8688,
        longitude: 151.2093,
        timezoneId: 'Australia/Sydney',
      );
      expect(sydWinter, equals(RegionalSeason.winter));
    });

    test('Resolves Indian 6-Ritu chronobiology in South Asia', () {
      // Bengaluru, India (12.9716° N, 77.5946° E)
      // July = Varsha (Monsoon)
      final monsoon = SeasonResolver.resolve(
        date: DateTime.utc(2026, 7, 15),
        latitude: 12.9716,
        longitude: 77.5946,
        timezoneId: 'Asia/Kolkata',
        culturalPreference: CulturalPresentationPreference.southAsian,
      );
      expect(monsoon, equals(RegionalSeason.varshaMonsoon));
      expect(monsoon.isIndianRitu, isTrue);

      // March = Vasanta (Spring)
      final spring = SeasonResolver.resolve(
        date: DateTime.utc(2026, 3, 25),
        latitude: 12.9716,
        longitude: 77.5946,
        timezoneId: 'Asia/Kolkata',
        culturalPreference: CulturalPresentationPreference.southAsian,
      );
      expect(spring, equals(RegionalSeason.vasantaSpring));
    });

    test('Cultural presentation is strictly opt-in and defaults to neutralNature', () {
      // Default preference has NO religious/cultural occasions imposed
      final defaultOccasion = CulturalCalendarResolver.resolveActiveOccasion(
        dateUtc: DateTime.utc(2026, 11, 8), // Diwali date 2026
        preference: CulturalPresentationPreference.neutralNature,
      );
      expect(defaultOccasion, isNull);

      // Explicit opt-in activates cultural calendar
      final southAsianOccasion = CulturalCalendarResolver.resolveActiveOccasion(
        dateUtc: DateTime.utc(2026, 11, 8),
        preference: CulturalPresentationPreference.southAsian,
      );
      expect(southAsianOccasion, isNotNull);
      expect(southAsianOccasion?.occasionId, contains('diwali'));
    });
  });

  group('4. Flutter Living Avatar Widgets & Accessibility', () {
    testWidgets('LivingAvatarView renders inside 110x110 boundary', (tester) async {
      final scene = AvatarStateResolver.resolve(
        identity: AvatarIdentity.defaultBaseline(),
        timeUtc: DateTime.utc(2026, 6, 21, 19, 0),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: LivingAvatarView(
                scene: scene,
                size: 110.0,
                enableAnimation: false, // Static snapshot for widget test
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the circular container
      final avatarContainer = find.byType(LivingAvatarView);
      expect(avatarContainer, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(avatarContainer);
      expect(renderBox.size.width, equals(110.0));
      expect(renderBox.size.height, equals(110.0));
    });

    testWidgets('AvatarAccessibilityWrapper provides rich semantic description', (tester) async {
      final scene = AvatarStateResolver.resolve(
        identity: AvatarIdentity.defaultBaseline(name: 'Sarah'),
        timeUtc: DateTime.utc(2026, 6, 21, 19, 0),
        latitude: 37.7749,
        longitude: -122.4194,
        timezoneId: 'America/Los_Angeles',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvatarAccessibilityWrapper(
              scene: scene,
              child: const SizedBox(width: 100, height: 100),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semantics = tester.getSemantics(find.byType(AvatarAccessibilityWrapper));
      expect(semantics.label, contains('Your companion avatar, Sarah'));
      expect(semantics.label, contains('Breathing steadily'));
    });

    testWidgets('AvatarStateSwitcher toggles between State A and State B seamlessly', (tester) async {
      // User with NO avatar -> State A (Create Avatar button)
      final mockRepoNoAvatar = MockTestProfileRepository(
        const UserProfileContext(
          userId: 'usr_no_avatar',
          displayName: 'Alex',
          hasAvatar: false,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockRepoNoAvatar),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AvatarStateSwitcher(size: 110.0, enableAnimation: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.text('Create\nAvatar'), findsOneWidget);

      // User WITH avatar -> State B (LivingAvatarView)
      final mockRepoWithAvatar = MockTestProfileRepository(
        const UserProfileContext(
          userId: 'usr_with_avatar',
          displayName: 'Alex',
          hasAvatar: true,
          skinTone: '#E0AC69',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(mockRepoWithAvatar),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AvatarStateSwitcher(size: 110.0, enableAnimation: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // State B renders LivingAvatarView, not the State A button
      expect(find.byType(LivingAvatarView), findsOneWidget);
      expect(find.text('Create\nAvatar'), findsNothing);
    });
  });
}
