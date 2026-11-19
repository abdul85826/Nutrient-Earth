// ==============================================================================
// Nutrient Earth — Goal-Driven Movement & Action Engine Service
// Just-In-Time Adaptive Intervention (JITAI) lifecycle, environmental
// awareness, and wearable sensor verification.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/movement/movement_task_models.dart';

abstract class MovementEngineService {
  Future<List<MovementTask>> getTasksForDate({
    required String userId,
    DateTime? date,
  });

  Future<MovementTask> transitionTaskStatus({
    required String taskId,
    required String userId,
    required TaskLifecycleStatus newStatus,
    CompletionMode? mode,
    Map<String, dynamic>? telemetry,
  });

  Future<List<MovementTask>> adaptTasksForEnvironment({
    required String userId,
    required bool isWeatherAdverse,
    required int aqi,
    DateTime? date,
  });

  Future<MovementTask?> verifyWearableCompletion({
    required String taskId,
    required String userId,
    required int recordedSteps,
    required int recordedDurationMinutes,
  });

  Future<MovementTask> adaptTaskForBehavioralAdherence({
    required String taskId,
    required String userId,
    required int consecutiveSkips,
  });
}

class SupabaseMovementEngineService implements MovementEngineService {
  final SupabaseClient? _supabase;

  // Local fallback storage for offline operation and test suites
  final Map<String, MovementTask> _localTasks = {};

  SupabaseMovementEngineService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<List<MovementTask>> getTasksForDate({
    required String userId,
    DateTime? date,
  }) async {
    final targetDate = (date ?? DateTime.now()).toUtc();
    final dateStr = targetDate.toIso8601String().substring(0, 10);

    if (_supabase != null) {
      try {
        final data = await _supabase!
            .from('movement_tasks')
            .select()
            .eq('user_id', userId)
            .eq('scheduled_date', dateStr);

        final list = (data as List).map((e) => MovementTask.fromJson(e)).toList();
        if (list.isNotEmpty) {
          for (final t in list) {
            _localTasks[t.id] = t;
          }
          return list;
        }
      } catch (e) {
        debugPrint('[MovementEngineService] Supabase getTasks error: $e');
      }
    }

    // Check local storage
    final localForDate = _localTasks.values
        .where((t) => t.userId == userId && t.scheduledDate.toIso8601String().substring(0, 10) == dateStr)
        .toList();

    if (localForDate.isNotEmpty) {
      return localForDate;
    }

    // Generate canonical initial movement tasks for the day
    final initialTasks = _generateCanonicalDailyTasks(userId: userId, scheduledDate: targetDate);
    for (final task in initialTasks) {
      _localTasks[task.id] = task;
    }
    return initialTasks;
  }

  @override
  Future<MovementTask> transitionTaskStatus({
    required String taskId,
    required String userId,
    required TaskLifecycleStatus newStatus,
    CompletionMode? mode,
    Map<String, dynamic>? telemetry,
  }) async {
    final now = DateTime.now().toUtc();
    final current = _localTasks[taskId] ??
        MovementTask(
          id: taskId,
          userId: userId,
          title: 'Movement Task',
          movementCategory: MovementCategory.restorativeMobility,
          scheduledDate: now,
          createdAt: now,
          updatedAt: now,
        );

    final updated = current.copyWith(
      currentStatus: newStatus,
      completionMode: newStatus == TaskLifecycleStatus.completed
          ? (mode ?? current.completionMode ?? CompletionMode.userSelfReported)
          : current.completionMode,
      completionTelemetry: telemetry ?? current.completionTelemetry,
      startedAt: newStatus == TaskLifecycleStatus.started ? (current.startedAt ?? now) : current.startedAt,
      completedAt: newStatus == TaskLifecycleStatus.completed ? (current.completedAt ?? now) : current.completedAt,
    );

    _localTasks[taskId] = updated;

    if (_supabase != null) {
      try {
        await _supabase!
            .from('movement_tasks')
            .update(updated.toJson())
            .eq('id', taskId)
            .eq('user_id', userId);
      } catch (e) {
        debugPrint('[MovementEngineService] Supabase update task status error: $e');
      }
    }

    return updated;
  }

  @override
  Future<List<MovementTask>> adaptTasksForEnvironment({
    required String userId,
    required bool isWeatherAdverse,
    required int aqi,
    DateTime? date,
  }) async {
    final tasks = await getTasksForDate(userId: userId, date: date);
    final adaptedList = <MovementTask>[];

    for (final task in tasks) {
      if (task.isOutdoorDependent && (isWeatherAdverse || aqi > 100)) {
        final reason = isWeatherAdverse
            ? 'Adapted to indoor alternative due to adverse weather/precipitation.'
            : 'Adapted to indoor alternative due to elevated AQI ($aqi).';

        final adaptedTask = task.copyWith(
          title: task.indoorAlternativeTitle ?? '${task.title} (Indoor Routine)',
          description: task.indoorAlternativeDescription ?? task.description,
          adaptationReason: reason,
        );

        _localTasks[task.id] = adaptedTask;
        adaptedList.add(adaptedTask);

        if (_supabase != null) {
          try {
            await _supabase!.rpc('adapt_movement_task_for_environment', params: {
              'p_task_id': task.id,
              'p_user_id': userId,
              'p_is_weather_adverse': isWeatherAdverse,
              'p_air_quality_index': aqi,
              'p_reason': reason,
            });
          } catch (e) {
            debugPrint('[MovementEngineService] Supabase environmental adaptation RPC error: $e');
          }
        }
      } else {
        adaptedList.add(task);
      }
    }

    return adaptedList;
  }

  @override
  Future<MovementTask?> verifyWearableCompletion({
    required String taskId,
    required String userId,
    required int recordedSteps,
    required int recordedDurationMinutes,
  }) async {
    final task = _localTasks[taskId];
    if (task == null) return null;

    final targetSteps = task.targetSteps ?? 2000;
    final targetDuration = task.targetDurationMinutes;

    final meetsCriteria = recordedSteps >= targetSteps || recordedDurationMinutes >= targetDuration;

    if (meetsCriteria) {
      return transitionTaskStatus(
        taskId: taskId,
        userId: userId,
        newStatus: TaskLifecycleStatus.completed,
        mode: CompletionMode.sensorStepVerified,
        telemetry: {
          'recorded_steps': recordedSteps,
          'recorded_duration_minutes': recordedDurationMinutes,
          'verified_via': 'wearable_telemetry_sync',
        },
      );
    }

    return task;
  }

  @override
  Future<MovementTask> adaptTaskForBehavioralAdherence({
    required String taskId,
    required String userId,
    required int consecutiveSkips,
  }) async {
    final now = DateTime.now().toUtc();
    final task = _localTasks[taskId] ??
        MovementTask(
          id: taskId,
          userId: userId,
          title: 'Movement Task',
          movementCategory: MovementCategory.restorativeMobility,
          scheduledDate: now,
          createdAt: now,
          updatedAt: now,
        );

    if (consecutiveSkips >= 3) {
      final adapted = task.copyWith(
        title: '3-Minute Seated Soleus & Diaphragmatic Micro-Reset',
        description:
            'A low-friction, 3-minute seated movement routine to keep habit consistency alive effortlessly without fatigue.',
        targetDurationMinutes: 3,
        targetSteps: 300,
        adaptationReason:
            'Automatically scaled down to a zero-friction micro-habit after multiple skipped sessions to protect habit adherence without guilt or shame.',
        isOutdoorDependent: false,
      );

      _localTasks[taskId] = adapted;

      if (_supabase != null) {
        try {
          await _supabase!
              .from('movement_tasks')
              .update(adapted.toJson())
              .eq('id', taskId)
              .eq('user_id', userId);
        } catch (e) {
          debugPrint('[MovementEngineService] Supabase behavioral adaptation error: $e');
        }
      }

      return adapted;
    }

    return task;
  }

  List<MovementTask> _generateCanonicalDailyTasks({
    required String userId,
    required DateTime scheduledDate,
  }) {
    final now = DateTime.now().toUtc();

    return [
      MovementTask(
        id: const Uuid().v4(),
        userId: userId,
        goalId: 'goal_circadian_photobiology',
        title: 'Morning Natural Light & Stride Walk',
        description: 'Brisk 15-minute outdoor walk without sunglasses to trigger melanopsin ganglion cells.',
        movementCategory: MovementCategory.circadianPhotobiology,
        targetDurationMinutes: 15,
        targetSteps: 1800,
        preferredTimeOfDay: TimeOfDayPreference.morning,
        isOutdoorDependent: true,
        indoorAlternativeTitle: 'Indoor Circadian Mobility & Full-Spectrum Light',
        indoorAlternativeDescription: '15 minutes of gentle joint mobility and stretching beside a bright window.',
        currentStatus: TaskLifecycleStatus.planned,
        scheduledDate: scheduledDate,
        createdAt: now,
        updatedAt: now,
      ),
      MovementTask(
        id: const Uuid().v4(),
        userId: userId,
        goalId: 'goal_postprandial_metabolism',
        title: 'Post-Lunch Soleus Pushups & Micro-Walk',
        description: '10 minutes of rhythmic seated calf contractions or hallway pacing to clear postprandial glucose.',
        movementCategory: MovementCategory.postprandialMetabolic,
        targetDurationMinutes: 10,
        targetSteps: 1000,
        preferredTimeOfDay: TimeOfDayPreference.midday,
        isOutdoorDependent: false,
        currentStatus: TaskLifecycleStatus.planned,
        scheduledDate: scheduledDate,
        createdAt: now,
        updatedAt: now,
      ),
      MovementTask(
        id: const Uuid().v4(),
        userId: userId,
        goalId: 'goal_autonomic_regulation',
        title: 'Evening Spinal Decompression & Deep Breathing',
        description: '15 minutes of supine hamstring release, cat-cow, and physiological sighing to activate vagal tone.',
        movementCategory: MovementCategory.restorativeMobility,
        targetDurationMinutes: 15,
        preferredTimeOfDay: TimeOfDayPreference.evening,
        isOutdoorDependent: false,
        currentStatus: TaskLifecycleStatus.planned,
        scheduledDate: scheduledDate,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

final movementEngineServiceProvider = Provider<MovementEngineService>((ref) {
  return SupabaseMovementEngineService();
});

final todayMovementTasksProvider = FutureProvider.family<List<MovementTask>, String>((ref, userId) async {
  final service = ref.watch(movementEngineServiceProvider);
  return service.getTasksForDate(userId: userId);
});
