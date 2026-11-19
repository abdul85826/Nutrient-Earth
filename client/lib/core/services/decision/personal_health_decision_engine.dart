// ==============================================================================
// Nutrient Earth — Personal Health Decision Engine
// Proactive, context-aware decision intelligence:
// - Evaluates user goals, current time/timezone, circadian meal windows,
//   available food inventory, and quiet hours.
// - Zero-Spam Principle: "If nothing meaningful needs to be said, say nothing."
// - Generates non-intrusive, grounded Today guidance cards:
//   1. Meal Routine guidance (millet/whole grain + dal + vegetables + protein)
//   2. Preparation insight (fat-soluble carotenoid absorption, phytate breakdown)
//   3. After-meal movement (gentle walk, soleus pushups)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../memory/bitemporal_memory_service.dart';
import '../movement/movement_engine_service.dart';
import '../personal_state/personal_data_foundation_service.dart';
import '../personal_state/personal_state_engine.dart';
import '../../domain/memory/bitemporal_memory_models.dart';

enum CircadianDecisionWindow {
  morningWaking,   // 06:00 - 09:30: Sunlight, hydration, morning movement
  middayLunch,     // 11:30 - 13:45: Prime digestive fire (Agni), whole food meal, postprandial movement
  afternoonFocus,  // 14:00 - 17:00: Sustained energy, hydration, posture break
  eveningDinner,   // 18:00 - 20:30: Lighter meal, winding down
  nighttimeSleep,  // 21:00 - 05:59: Quiet hours; NO notifications
}

class ContextualGuidanceCard {
  final String categoryTag; // e.g. 'Personal Guidance • 12:15 PM'
  final String routineTitle;
  final String routineBody;
  final String preparationInsightTitle;
  final String preparationInsightBody;
  final String afterMealMovementTitle;
  final String afterMealMovementBody;
  final String rationale;

  const ContextualGuidanceCard({
    required this.categoryTag,
    required this.routineTitle,
    required this.routineBody,
    required this.preparationInsightTitle,
    required this.preparationInsightBody,
    required this.afterMealMovementTitle,
    required this.afterMealMovementBody,
    required this.rationale,
  });
}

abstract class PersonalHealthDecisionEngine {
  Future<ContextualGuidanceCard?> evaluateProactiveGuidance({
    required String userId,
    DateTime? currentTimeOverride,
  });

  CircadianDecisionWindow resolveWindow(DateTime time);
}

class DefaultPersonalHealthDecisionEngine implements PersonalHealthDecisionEngine {
  final BitemporalMemoryService _memoryService;
  final MovementEngineService _movementService;
  final PersonalDataFoundationService _personalDataFoundation;

  DefaultPersonalHealthDecisionEngine({
    required BitemporalMemoryService memoryService,
    required MovementEngineService movementService,
    required PersonalDataFoundationService personalDataFoundation,
  })  : _memoryService = memoryService,
        _movementService = movementService,
        _personalDataFoundation = personalDataFoundation;

  @override
  CircadianDecisionWindow resolveWindow(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final timeMinutes = hour * 60 + minute;

    if (timeMinutes >= 6 * 60 && timeMinutes < 9 * 60 + 30) {
      return CircadianDecisionWindow.morningWaking;
    } else if (timeMinutes >= 11 * 60 + 30 && timeMinutes < 13 * 60 + 45) {
      return CircadianDecisionWindow.middayLunch;
    } else if (timeMinutes >= 14 * 60 && timeMinutes < 17 * 60) {
      return CircadianDecisionWindow.afternoonFocus;
    } else if (timeMinutes >= 18 * 60 && timeMinutes < 20 * 60 + 30) {
      return CircadianDecisionWindow.eveningDinner;
    } else {
      return CircadianDecisionWindow.nighttimeSleep;
    }
  }

  @override
  Future<ContextualGuidanceCard?> evaluateProactiveGuidance({
    required String userId,
    DateTime? currentTimeOverride,
  }) async {
    final now = currentTimeOverride ?? DateTime.now();
    final window = resolveWindow(now);

    // 1. Quiet Hours Enforcement: Never notify or intrude during sleep hours
    if (window == CircadianDecisionWindow.nighttimeSleep) {
      return null; // Zero-Spam Principle: Say nothing during sleep
    }

    // 2. Query User Authority: Check personal facts and dietary preferences
    final activeFacts = await _memoryService.getCurrentActiveFacts(userId: userId);

    final prefersTraditional = activeFacts.any((f) =>
        f.factKey.contains('preference.dietary') &&
        (f.currentValue.toString().contains('traditional') || f.currentValue.toString().contains('home')));

    // 3. Midday Lunch Guidance Window (11:30 - 13:45)
    if (window == CircadianDecisionWindow.middayLunch) {
      final hourStr = now.hour > 12 ? '${now.hour - 12}' : '${now.hour}';
      final minStr = now.minute.toString().padLeft(2, '0');
      final amPm = now.hour >= 12 ? 'PM' : 'AM';

      return ContextualGuidanceCard(
        categoryTag: 'Personal Guidance • $hourStr:$minStr $amPm',
        routineTitle: 'Your lunch routine',
        routineBody: prefersTraditional
            ? 'If you are ready for lunch, consider a balanced meal with a traditional millet (e.g. Ragi or Foxtail) or whole grain, dal, vegetables, and a suitable protein source. Adapted to your home-cooking preferences.'
            : 'If you are ready for lunch, consider a balanced meal with a whole grain or millet, legumes, mixed colorful vegetables, and an adequate protein source.',
        preparationInsightTitle: 'A small preparation insight',
        preparationInsightBody:
            'Cooking certain vegetables (such as spinach, carrots, or tomatoes) with a small amount of healthy culinary fat (e.g. olive oil or cold-pressed sesame oil) enhances absorption of fat-soluble carotenoids and lycopene by up to 3-fold.',
        afterMealMovementTitle: 'After lunch movement',
        afterMealMovementBody:
            'If comfortable and appropriate for your health, consider a gentle 10-15 minute walk or seated soleus calf raises. It can be a practical, non-strenuous way to accelerate postprandial glucose clearance.',
        rationale: 'Generated because user is currently in their primary midday digestive window (Agni peak).',
      );
    }

    // 4. Morning Waking Window (06:00 - 09:30)
    if (window == CircadianDecisionWindow.morningWaking) {
      return const ContextualGuidanceCard(
        categoryTag: 'Morning Circadian Alignment',
        routineTitle: 'Daylight & Hydration Kickstart',
        routineBody: 'View natural outdoor light within 30-45 minutes of waking to anchor your central SCN clock, and drink a glass of room-temperature water.',
        preparationInsightTitle: 'Morning Nutrition',
        preparationInsightBody: 'If consuming tea or coffee, consider waiting 60 minutes after waking to allow morning cortisol to complete its natural awakening spike.',
        afterMealMovementTitle: 'Morning Mobility',
        afterMealMovementBody: 'A light 10-minute walk outdoors provides simultaneous photobiomodulation and joint lubrication.',
        rationale: 'Generated for morning circadian entrainment.',
      );
    }

    // 5. Default: If no high-value decision is needed right now, say nothing!
    return null;
  }
}

final personalHealthDecisionEngineProvider = Provider<PersonalHealthDecisionEngine>((ref) {
  return DefaultPersonalHealthDecisionEngine(
    memoryService: ref.watch(bitemporalMemoryServiceProvider),
    movementService: ref.watch(movementEngineServiceProvider),
    personalDataFoundation: ref.watch(personalDataFoundationProvider),
  );
});
