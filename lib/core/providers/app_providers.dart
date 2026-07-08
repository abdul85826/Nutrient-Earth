import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/models/app_models.dart';
import '../../domain/models/intelligence/biological_twin_snapshot.dart';
import '../services/sync_service.dart';
import '../services/local_storage_service.dart';
import '../services/supabase_service.dart';
import 'biological_profile_provider.dart';
import 'graph_provider.dart';
import '../bootstrap/identity_manager.dart';
// ─────────────────────────────────────────────────────────────────────────────
// RE-EXPORT ENVIRONMENT FROM SERVICE
// ─────────────────────────────────────────────────────────────────────────────
import '../services/device_intelligence_service.dart';
export '../services/environment_service.dart';
export '../services/device_intelligence_service.dart';

final syncServiceProvider = Provider((ref) => SyncService());
final supabaseServiceProvider = Provider((ref) => SupabaseService());

final deviceIntelligenceProvider = FutureProvider<DeviceIntelligenceState>((ref) async {
  return DeviceIntelligenceService().analyzeDeviceState();
});

class ActionState {
  final List<ActionStep> steps;
  final DateTime lastReset;
  final BodyState bodyState;
  final double currentTemp;
  final double energyLevel;
  final int waterIntake;
  final HealthIdentity? profile;

  ActionState({
    required this.steps,
    required this.lastReset,
    required this.bodyState,
    this.currentTemp = 37.0,
    this.energyLevel = 0.7,
    this.waterIntake = 2000,
    this.profile,
  });

  factory ActionState.fromMap(
    Map<String, dynamic> map, [
    HealthIdentity? profile,
  ]) {
    final temp = ((map['current_temp'] as num?)?.toDouble() ?? 37.0).clamp(
      30.0,
      45.0,
    );
    final energy = ((map['energy_level'] as num?)?.toDouble() ?? 0.7).clamp(
      0.0,
      1.0,
    );
    final water = (map['water_intake'] as int? ?? 2000).clamp(0, 4000);

    return ActionState(
      steps:
          (map['steps'] as List?)?.map((s) => ActionStep.fromMap(s)).toList() ??
          [],
      lastReset: map['last_reset'] != null
          ? DateTime.parse(map['last_reset'])
          : DateTime.now(),
      bodyState: BodyState(
        energyScore: 70,
        recoveryScore: 80,
        stressLoad: 30,
        hydrationStatus: 80,
        primaryMessage: 'System balance optimal. Keep following your rhythm.',
        status: 'GREEN',
        emoji: '⚡',
        headline: 'Metabolic Flux Stable',
        subtext: 'Your biological metrics indicate high adaptive capacity today.',
        actions: [],
      ),
      currentTemp: temp,
      energyLevel: energy,
      waterIntake: water,
      profile: profile,
    );
  }

  ActionState copyWith({
    List<ActionStep>? steps,
    DateTime? lastReset,
    BodyState? bodyState,
    double? currentTemp,
    double? energyLevel,
    int? waterIntake,
    HealthIdentity? profile,
  }) {
    return ActionState(
      steps: steps ?? this.steps,
      lastReset: lastReset ?? this.lastReset,
      bodyState: bodyState ?? this.bodyState,
      currentTemp: currentTemp ?? this.currentTemp,
      energyLevel: energyLevel ?? this.energyLevel,
      waterIntake: waterIntake ?? this.waterIntake,
      profile: profile ?? this.profile,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'steps': steps.map((s) => s.toMap()).toList(),
      'last_reset': lastReset.toIso8601String(),
      'current_temp': currentTemp,
      'energy_level': energyLevel,
      'water_intake': waterIntake,
    };
  }
}

class ActionNotifier extends StateNotifier<ActionState> {
  final SyncService _syncService;
  final SupabaseService _supabaseService;
  final Ref _ref;

  ActionNotifier(this._syncService, this._supabaseService, this._ref)
    : super(
        ActionState(
          steps: [],
          lastReset: DateTime.now(),
          bodyState: BodyState(
            energyScore: 70,
            recoveryScore: 80,
            stressLoad: 30,
            hydrationStatus: 80,
            primaryMessage: 'System balance optimal. Keep following your rhythm.',
            status: 'GREEN',
            emoji: '⚡',
            headline: 'Metabolic Flux Stable',
            subtext: 'Your biological metrics indicate high adaptive capacity today.',
            actions: [],
          ),
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    _ref.listen<AsyncValue<GraphState?>>(graphStateProvider, (previous, next) {
      next.whenData((graph) {
        if (graph != null) {
          _updateFromGraph(graph);
        }
      });
    }, fireImmediately: true);

    final localState = await _syncService.loadActionStateLocally();
    if (localState != null) {
      state = localState;
    }
    _checkDailyReset();
  }

  void _updateFromGraph(GraphState graph) {
    final actionRecs = graph.candidateRecommendations;

    final steps = actionRecs.map((rec) => ActionStep(
      id: rec.recommendationId,
      title: rec.title,
      instruction: rec.summary,
      benefit: rec.explanation,
      timing: rec.category,
      isCompleted: false,
      isLocked: false,
    )).toList();

    if (steps.isEmpty && state.steps.isNotEmpty) {
      return;
    }

    final bodyState = _calculateBodyState(graph.twinSnapshot, steps);
    state = state.copyWith(
      steps: steps,
      bodyState: bodyState,
    );
    _persist();
  }

  BodyState _calculateBodyState(BiologicalTwinSnapshot snapshot, List<ActionStep> steps) {
    final current = snapshot.currentState;
    final energy = ((current['recovery'] ?? 0.7) * 100).toDouble();
    final recovery = ((current['sleep'] ?? 0.8) * 100).toDouble();
    final stress = ((current['stress'] ?? 0.3) * 100).toDouble();
    final hydration = ((current['hydration'] ?? 0.8) * 100).toDouble();

    final status = stress > 70 ? 'RED' : (energy < 50 ? 'YELLOW' : 'GREEN');
    final emoji = status == 'RED' ? '🔥' : (status == 'YELLOW' ? '🔋' : '⚡');
    final headline = status == 'RED' ? 'Hyper-Stress Detected' : (status == 'YELLOW' ? 'Energy Conservation' : 'Metabolic Flux Stable');
    final subtext = status == 'RED' ? 'System is entering a compensatory state. Immediate cooldown required.' : (status == 'YELLOW' ? 'Cellular ATP production is sub-optimal. Prioritize restorative protocols.' : 'Your biological metrics indicate high adaptive capacity today.');

    final actions = steps.map((s) => DailyAction(
      title: s.title,
      type: s.id.contains('walk') ? 'activity' : (s.id.contains('water') ? 'hydration' : 'food'),
      instruction: s.instruction,
      benefit: s.benefit,
      icon: s.id.contains('walk') ? '🏃' : (s.id.contains('water') ? '💧' : '🍊'),
    )).toList();

    return BodyState(
      energyScore: energy,
      recoveryScore: recovery,
      stressLoad: stress,
      hydrationStatus: hydration,
      primaryMessage: subtext,
      status: status,
      emoji: emoji,
      headline: headline,
      subtext: subtext,
      actions: actions,
    );
  }

  void updateBiometrics({double? temp, double? energy, int? water}) {
    state = state.copyWith(
      currentTemp: temp?.clamp(30.0, 45.0),
      energyLevel: energy?.clamp(0.0, 1.0),
      waterIntake: water?.clamp(0, 4000),
    );
    _persist();
  }

  void refreshPlan() {
    // Reactively updated via graphStateProvider
  }

  void completeStep(String id) async {
    final user = _ref.read(userProvider);
    if (user == null) return;

    final index = state.steps.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final updatedSteps = List<ActionStep>.from(state.steps);
    updatedSteps[index] = updatedSteps[index].copyWith(isCompleted: true);

    if (index + 1 < updatedSteps.length) {
      updatedSteps[index + 1] = updatedSteps[index + 1].copyWith(
        isLocked: false,
      );
    }

    state = state.copyWith(steps: updatedSteps);
    _persist();

    await _supabaseService.markTaskComplete(user.id, id, state.steps.length);
  }

  void _persist() {
    _syncService.saveActionStateLocally(state);
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    final dayDiff = now.difference(state.lastReset).inDays;
    if (dayDiff >= 1) {
      state = state.copyWith(lastReset: now);
      _persist();
    }
  }
}

final actionProvider = StateNotifierProvider<ActionNotifier, ActionState>((
  ref,
) {
  return ActionNotifier(
    ref.watch(syncServiceProvider),
    ref.watch(supabaseServiceProvider),
    ref,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// USER PROGRESS & PROFILE
// ─────────────────────────────────────────────────────────────────────────────

final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final session = ref.watch(sessionProvider);
  final isGuest = IdentityManager().isGuest;
  
  final uid = session?.user.id ?? (isGuest ? IdentityManager().currentUuid : null);
  if (uid == null) return null;
  
  if (session != null) {
    try {
      final appUser = await SupabaseService().getAppUser(uid);
      if (appUser != null && appUser.healthIdentity != null) {
        await saveHealthIdentityToIsar(uid, appUser.healthIdentity!.toMap());
        return appUser;
      }
    } catch (e) {
      print('appUserProvider: Supabase fetch failed/errored: $e');
    }
  }

  // Fallback to local Isar load
  try {
    final localProfileData = await readHealthIdentityFromIsar(uid);
    if (localProfileData != null) {
      final userProfile = HealthIdentity.fromMap(localProfileData);
      return AppUser(
        id: uid,
        email: session?.user.email ?? 'guest@nutrientearth.local',
        profileCompleted: true,
        healthIdentity: userProfile,
      );
    }
  } catch (e) {
    print('appUserProvider: Fallback Isar load failed: $e');
  }

  return null;
});

final userProfileProvider = Provider<HealthIdentity?>((ref) {
  return ref.watch(appUserProvider).value?.healthIdentity;
});

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
final personaProvider = StateProvider<ProblemArea>((ref) => ProblemArea.none);

final userProgressProvider = StateProvider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  if (profile == null) return 0.47; // Start at 47% as per requirement

  int totalFields = 8;
  int filledFields = 0;
  if (profile.age > 0) filledFields++;
  if (profile.gender.isNotEmpty) filledFields++;
  if (profile.weight > 0) filledFields++;
  if (profile.height > 0) filledFields++;
  if (profile.primaryGoal.isNotEmpty) filledFields++;
  if (profile.sleepTime.isNotEmpty) filledFields++;
  if (profile.activityLevel.isNotEmpty) filledFields++;
  if (profile.waterIntake > 0) filledFields++;

  return 0.47 + (0.53 * (filledFields / totalFields));
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

final userPlanProvider = FutureProvider<UserPlan?>((ref) async {
  final user = ref.watch(userProvider);
  if (user == null) return null;
  return SupabaseService().getActivePlan(user.id);
});

final recentInsightsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(graphStateProvider);
  final userId = IdentityManager().currentUuid;
  if (userId.isEmpty) return const [];
  final allRecs = await LocalStorageService().readRecommendations(userId);
  return allRecs.where((r) => r['type'] == 'insight').toList();
});
