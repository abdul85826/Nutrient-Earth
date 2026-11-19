// ==============================================================================
// Nutrient Earth — Goal-Driven Movement & Action Engine Tests
// Verifies:
// 1. JITAI task lifecycle state machine
// 2. Dynamic environmental adaptation (weather/AQI indoor fallbacks)
// 3. Wearable sensor verification vs. user self-reporting
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/movement/movement_task_models.dart';
import 'package:nutrient_earth_client/core/services/movement/movement_engine_service.dart';

void main() {
  group('Goal-Driven Movement & Action Engine Tests', () {
    late SupabaseMovementEngineService movementService;
    const testUserId = 'usr_test_movement_engine';

    setUp(() {
      movementService = SupabaseMovementEngineService(supabase: null);
    });

    test('Loads canonical movement tasks with correct goal categories and attributes', () async {
      final tasks = await movementService.getTasksForDate(userId: testUserId);

      expect(tasks.length, equals(3));
      expect(tasks.any((t) => t.movementCategory == MovementCategory.circadianPhotobiology), isTrue);
      expect(tasks.any((t) => t.movementCategory == MovementCategory.postprandialMetabolic), isTrue);
      expect(tasks.any((t) => t.movementCategory == MovementCategory.restorativeMobility), isTrue);

      final morningTask = tasks.firstWhere((t) => t.isOutdoorDependent);
      expect(morningTask.indoorAlternativeTitle, isNotNull);
      expect(morningTask.indoorAlternativeDescription, isNotNull);
      expect(morningTask.currentStatus, equals(TaskLifecycleStatus.planned));
    });

    test('JITAI task lifecycle transitions accurately track timestamps and states', () async {
      final tasks = await movementService.getTasksForDate(userId: testUserId);
      final task = tasks.first;

      // 1. planned -> started
      final startedTask = await movementService.transitionTaskStatus(
        taskId: task.id,
        userId: testUserId,
        newStatus: TaskLifecycleStatus.started,
      );
      expect(startedTask.currentStatus, equals(TaskLifecycleStatus.started));
      expect(startedTask.startedAt, isNotNull);
      expect(startedTask.completedAt, isNull);

      // 2. started -> completed (user self-reported)
      final completedTask = await movementService.transitionTaskStatus(
        taskId: task.id,
        userId: testUserId,
        newStatus: TaskLifecycleStatus.completed,
        mode: CompletionMode.userSelfReported,
      );
      expect(completedTask.currentStatus, equals(TaskLifecycleStatus.completed));
      expect(completedTask.completedAt, isNotNull);
      expect(completedTask.completionMode, equals(CompletionMode.userSelfReported));
    });

    test('Environmental adaptation switches outdoor-dependent tasks to indoor alternatives', () async {
      // Trigger adaptation due to high AQI (145) and rain
      final adaptedTasks = await movementService.adaptTasksForEnvironment(
        userId: testUserId,
        isWeatherAdverse: true,
        aqi: 145,
      );

      final outdoorTask = adaptedTasks.firstWhere((t) => t.isOutdoorDependent);
      expect(outdoorTask.title, equals('Indoor Circadian Mobility & Full-Spectrum Light'));
      expect(outdoorTask.adaptationReason, contains('adverse weather/precipitation'));

      // Non-outdoor tasks remain unchanged
      final indoorTask = adaptedTasks.firstWhere((t) => !t.isOutdoorDependent);
      expect(indoorTask.adaptationReason, isNull);
    });

    test('Wearable sensor telemetry verifies completion without requiring manual check-in', () async {
      final tasks = await movementService.getTasksForDate(userId: testUserId);
      final task = tasks.firstWhere((t) => t.targetSteps != null && t.targetSteps! > 0);

      // Verify completion via wearable sensor telemetry: recorded 1950 steps (target 1800)
      final verified = await movementService.verifyWearableCompletion(
        taskId: task.id,
        userId: testUserId,
        recordedSteps: 1950,
        recordedDurationMinutes: 16,
      );

      expect(verified, isNotNull);
      expect(verified!.currentStatus, equals(TaskLifecycleStatus.completed));
      expect(verified.completionMode, equals(CompletionMode.sensorStepVerified));
      expect(verified.completionTelemetry?['verified_via'], equals('wearable_telemetry_sync'));
      expect(verified.completionTelemetry?['recorded_steps'], equals(1950));
    });
  });
}
