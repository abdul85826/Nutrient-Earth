import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class DailyHabitItem {
  final String id;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final String iconKey;

  const DailyHabitItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    required this.iconKey,
  });

  DailyHabitItem copyWith({bool? isCompleted}) {
    return DailyHabitItem(
      id: id,
      title: title,
      subtitle: subtitle,
      isCompleted: isCompleted ?? this.isCompleted,
      iconKey: iconKey,
    );
  }
}

@immutable
class TodayState {
  final int healthReadinessScore;
  final List<DailyHabitItem> habits;
  final double hydrationCurrentLiters;
  final double hydrationTargetLiters;

  const TodayState({
    this.healthReadinessScore = 91,
    this.habits = const [
      DailyHabitItem(
        id: 'h1',
        title: 'Morning Hydration & Electrolytes',
        subtitle: '500ml water + trace minerals before caffeine',
        isCompleted: true,
        iconKey: 'water',
      ),
      DailyHabitItem(
        id: 'h2',
        title: 'Solar Exposure Protocol',
        subtitle: '15 min ambient outdoor light for circadian clock',
        isCompleted: false,
        iconKey: 'sun',
      ),
      DailyHabitItem(
        id: 'h3',
        title: 'Micronutrient Ingestion Window',
        subtitle: 'Target bioavailable protein & minerals with meal',
        isCompleted: false,
        iconKey: 'leaf',
      ),
    ],
    this.hydrationCurrentLiters = 1.25,
    this.hydrationTargetLiters = 2.5,
  });

  TodayState copyWith({
    int? healthReadinessScore,
    List<DailyHabitItem>? habits,
    double? hydrationCurrentLiters,
    double? hydrationTargetLiters,
  }) {
    return TodayState(
      healthReadinessScore: healthReadinessScore ?? this.healthReadinessScore,
      habits: habits ?? this.habits,
      hydrationCurrentLiters: hydrationCurrentLiters ?? this.hydrationCurrentLiters,
      hydrationTargetLiters: hydrationTargetLiters ?? this.hydrationTargetLiters,
    );
  }
}

class TodayNotifier extends StateNotifier<TodayState> {
  TodayNotifier() : super(const TodayState());

  void toggleHabit(String id) {
    final updatedHabits = state.habits.map((h) {
      if (h.id == id) {
        return h.copyWith(isCompleted: !h.isCompleted);
      }
      return h;
    }).toList();

    state = state.copyWith(habits: updatedHabits);
  }

  void addHydration(double liters) {
    final newHydration = (state.hydrationCurrentLiters + liters).clamp(0.0, 5.0);
    state = state.copyWith(hydrationCurrentLiters: newHydration);
  }
}

final todayStateProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  return TodayNotifier();
});
