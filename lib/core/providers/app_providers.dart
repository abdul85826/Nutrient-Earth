import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/app_models.dart';
import '../services/sync_service.dart';

final syncServiceProvider = Provider((ref) => SyncService());

final actionProvider = StateNotifierProvider<ActionNotifier, ActionState>((ref) {
  return ActionNotifier(ref.watch(syncServiceProvider));
});

class ActionState {
  final List<ActionStep> steps;
  final DateTime lastReset;

  ActionState({required this.steps, required this.lastReset});

  Map<String, dynamic> toMap() {
    return {
      'steps': steps.map((s) => s.toMap()).toList(),
      'last_reset': lastReset.toIso8601String(),
    };
  }

  factory ActionState.fromMap(Map<String, dynamic> map) {
    return ActionState(
      steps: (map['steps'] as List?)?.map((s) => ActionStep.fromMap(s as Map<String, dynamic>)).toList() ?? [],
      lastReset: DateTime.parse(map['last_reset'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ActionNotifier extends StateNotifier<ActionState> {
  final SyncService _syncService;

  ActionNotifier(this._syncService) : super(ActionState(steps: _generateInitialSteps(), lastReset: DateTime.now())) {
    _init();
  }

  Future<void> _init() async {
    final localState = await _syncService.loadActionStateLocally();
    if (localState != null) {
      state = localState;
    }
    _checkDailyReset();
  }

  static List<ActionStep> _generateInitialSteps() {
    return [
      ActionStep(
        id: '1',
        title: 'WAKE HYDRATION',
        instruction: '200ml warm water + pinch of fenugreek.',
        benefit: 'The Ignition: Flushes system for recovery.',
        isLocked: false,
      ),
      ActionStep(
        id: '2',
        title: 'GENTLE MOVEMENT',
        instruction: 'Move for 5 minutes in fresh air.',
        benefit: 'The Taxi: Readies muscles for glucose uptake.',
      ),
      ActionStep(
        id: '3',
        title: 'BREATH RESET',
        instruction: '3 cycles of Box Breathing (4-4-4-4).',
        benefit: 'Engine Check: Oxygenates pancreas & liver.',
      ),
      ActionStep(
        id: '4',
        title: 'FIRST INTAKE',
        instruction: 'Take 1 serving of NE Body Reset Formula.',
        benefit: 'The Thrust: Direct nutrient delivery to cells.',
      ),
      ActionStep(
        id: '5',
        title: 'STABILIZATION',
        instruction: 'Avoid sitting. Light movement for 5 mins.',
        benefit: 'Takeoff: Prevents insulin spike.',
      ),
    ];
  }

  void completeStep(String id) {
    final index = state.steps.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final updatedSteps = List<ActionStep>.from(state.steps);
    updatedSteps[index] = updatedSteps[index].copyWith(isCompleted: true);

    // Unlock next step
    if (index + 1 < updatedSteps.length) {
      updatedSteps[index + 1] = updatedSteps[index + 1].copyWith(isLocked: false);
    }

    state = ActionState(steps: updatedSteps, lastReset: state.lastReset);
    _persist();
  }

  void updateSteps(List<ActionStep> newSteps) {
    state = ActionState(steps: newSteps, lastReset: state.lastReset);
    _persist();
  }

  void _persist() {
    _syncService.saveActionStateLocally(state);
    _syncService.syncActionStateToCloud(state);
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    final dayDiff = now.difference(state.lastReset).inDays;
    if (dayDiff >= 1) {
      state = ActionState(steps: _generateInitialSteps(), lastReset: now);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USER PROGRESS & PROFILE
// ─────────────────────────────────────────────────────────────────────────────

enum ProblemArea { sugar, energy, weight, stress, bp, none }

class UserProfile {
  final String? gender;
  final int? age;
  final double? weight;
  final ProblemArea problemArea;
  final bool hasCompletedOnboarding;

  UserProfile({
    this.gender,
    this.age,
    this.weight,
    this.problemArea = ProblemArea.none,
    this.hasCompletedOnboarding = false,
  });

  UserProfile copyWith({
    String? gender,
    int? age,
    double? weight,
    ProblemArea? problemArea,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      problemArea: problemArea ?? this.problemArea,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'age': age,
      'weight': weight,
      'problem_area': problemArea.name,
      'has_completed_onboarding': hasCompletedOnboarding,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      gender: map['gender'],
      age: map['age'],
      weight: map['weight']?.toDouble(),
      problemArea: ProblemArea.values.firstWhere(
        (e) => e.name == map['problem_area'],
        orElse: () => ProblemArea.none,
      ),
      hasCompletedOnboarding: map['has_completed_onboarding'] ?? false,
    );
  }

  double get completionPercentage {
    int totalFields = 4;
    int filledFields = 0;
    if (gender != null) filledFields++;
    if (age != null) filledFields++;
    if (weight != null) filledFields++;
    if (problemArea != ProblemArea.none) filledFields++;
    
    // Start at 47% as requested in requirements for "existing progress"
    double base = 0.47;
    double remaining = 0.53;
    return base + (remaining * (filledFields / totalFields));
  }

  bool get isComplete => completionPercentage >= 1.0;
}

class UserProgressNotifier extends StateNotifier<UserProfile> {
  final SyncService _syncService;

  UserProgressNotifier(this._syncService) : super(UserProfile()) {
    _init();
  }

  Future<void> _init() async {
    final localProfile = await _syncService.loadProfileLocally();
    if (localProfile != null) {
      state = localProfile;
    }
  }

  void updateGender(String gender) {
    state = state.copyWith(gender: gender);
    _persist();
  }

  void updateAge(int age) {
    state = state.copyWith(age: age);
    _persist();
  }

  void updateWeight(double weight) {
    state = state.copyWith(weight: weight);
    _persist();
  }

  void updateProblemArea(ProblemArea area) {
    state = state.copyWith(problemArea: area);
    _persist();
  }

  void setOnboardingComplete(bool complete) {
    state = state.copyWith(hasCompletedOnboarding: complete);
    _persist();
  }

  void _persist() {
    _syncService.saveProfileLocally(state);
    _syncService.syncProfileToCloud(state);
  }
}

final userProgressProvider = StateNotifierProvider<UserProgressNotifier, UserProfile>((ref) {
  return UserProgressNotifier(ref.watch(syncServiceProvider));
});

// Legacy personaProvider (kept for compatibility, but should migrate to userProgressProvider)
final personaProvider = StateProvider<ProblemArea>((ref) {
  return ref.watch(userProgressProvider).problemArea;
});

// ─────────────────────────────────────────────────────────────────────────────
// AUTHENTICATION PROVIDERS
// ─────────────────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session ?? Supabase.instance.client.auth.currentSession;
});

final userProvider = Provider<User?>((ref) {
  final session = ref.watch(sessionProvider);
  return session?.user;
});

