import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class UserHealthProfile {
  final List<String> primaryGoals;
  final String dietaryBaseline;
  final String activityLevel;
  final bool hasCompletedOnboarding;

  const UserHealthProfile({
    this.primaryGoals = const ['Metabolic Balance'],
    this.dietaryBaseline = 'Plant-forward',
    this.activityLevel = 'Moderate',
    this.hasCompletedOnboarding = false,
  });

  UserHealthProfile copyWith({
    List<String>? primaryGoals,
    String? dietaryBaseline,
    String? activityLevel,
    bool? hasCompletedOnboarding,
  }) {
    return UserHealthProfile(
      primaryGoals: primaryGoals ?? this.primaryGoals,
      dietaryBaseline: dietaryBaseline ?? this.dietaryBaseline,
      activityLevel: activityLevel ?? this.activityLevel,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class OnboardingNotifier extends StateNotifier<UserHealthProfile> {
  static const String _prefKey = 'ne_onboarding_completed_v1';

  OnboardingNotifier() : super(const UserHealthProfile()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = prefs.getBool(_prefKey) ?? false;
      state = state.copyWith(hasCompletedOnboarding: completed);
    } catch (e) {
      debugPrint('[OnboardingNotifier] Load error: $e');
    }
  }

  void toggleGoal(String goal) {
    final current = List<String>.from(state.primaryGoals);
    if (current.contains(goal)) {
      if (current.length > 1) current.remove(goal);
    } else {
      current.add(goal);
    }
    state = state.copyWith(primaryGoals: current);
  }

  void setDietaryBaseline(String diet) {
    state = state.copyWith(dietaryBaseline: diet);
  }

  void setActivityLevel(String level) {
    state = state.copyWith(activityLevel: level);
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(hasCompletedOnboarding: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, true);
    } catch (e) {
      debugPrint('[OnboardingNotifier] Save error: $e');
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, UserHealthProfile>((ref) {
  return OnboardingNotifier();
});
