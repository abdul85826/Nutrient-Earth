import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/ne_tokens.dart';
import '../../../core/domain/personalization/user_profile_context.dart';
import '../../../core/services/diurnal_service.dart';
import '../../../core/services/profile_repository.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../core/services/research_pipeline_service.dart';

class DailyPlanTask {
  final String id;
  final String title;
  final String note;
  final String timeString;
  final bool isCompleted;
  final bool isUpNext;

  const DailyPlanTask({
    required this.id,
    required this.title,
    required this.note,
    required this.timeString,
    this.isCompleted = false,
    this.isUpNext = false,
  });

  DailyPlanTask copyWith({
    bool? isCompleted,
    bool? isUpNext,
  }) {
    return DailyPlanTask(
      id: id,
      title: title,
      note: note,
      timeString: timeString,
      isCompleted: isCompleted ?? this.isCompleted,
      isUpNext: isUpNext ?? this.isUpNext,
    );
  }
}

class TodayState {
  final DiurnalContext diurnal;
  final TelemetryData telemetry;
  final List<DailyPlanTask> tasks;
  final bool isResearchLoading;
  final ResearchAnswer? activeAnswer;
  final String? researchError;
  final bool feedbackSubmitted;

  const TodayState({
    required this.diurnal,
    required this.telemetry,
    required this.tasks,
    this.isResearchLoading = false,
    this.activeAnswer,
    this.researchError,
    this.feedbackSubmitted = false,
  });

  int get completedTaskCount => tasks.where((t) => t.isCompleted).length;
  int get totalTaskCount => tasks.length;
  String get counterLabel => '$completedTaskCount of $totalTaskCount completed';

  TodayState copyWith({
    DiurnalContext? diurnal,
    TelemetryData? telemetry,
    List<DailyPlanTask>? tasks,
    bool? isResearchLoading,
    ResearchAnswer? activeAnswer,
    String? researchError,
    bool? feedbackSubmitted,
  }) {
    return TodayState(
      diurnal: diurnal ?? this.diurnal,
      telemetry: telemetry ?? this.telemetry,
      tasks: tasks ?? this.tasks,
      isResearchLoading: isResearchLoading ?? this.isResearchLoading,
      activeAnswer: activeAnswer ?? this.activeAnswer,
      researchError: researchError,
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
    );
  }
}

class TodayNotifier extends StateNotifier<TodayState> {
  final ProfileRepository _profileRepository;

  TodayNotifier({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? SupabaseProfileRepository(),
        super(
          TodayState(
            diurnal: DiurnalService.getContext(preferredName: 'Sarah'),
            telemetry: TelemetryData(
              formattedTime: '1:15 PM',
              solarCondition: 'Radiant',
              aqi: 42,
              aqiLabel: 'Good AQI',
              aqiColor: NETokens.aqiGreen,
              temperatureCelsius: 26.0,
              weatherCondition: 'Partly cloudy',
              streakDays: 3,
              streakLabel: 'Keep going',
              observationTime: DateTime.now(),
            ),
            tasks: const [
              DailyPlanTask(
                id: 'task-1',
                title: 'Morning hydration + mineral electrolyte water',
                note: 'Replenished fluid deficit upon waking',
                timeString: '7:30 AM',
                isCompleted: true,
              ),
              DailyPlanTask(
                id: 'task-2',
                title: '30-min brisk outdoor run in morning sunlight',
                note: 'Circadian entrainment + cardiovascular base',
                timeString: '8:45 AM',
                isCompleted: true,
              ),
              DailyPlanTask(
                id: 'task-3',
                title: 'Post-run nutrient recovery meal',
                note: 'Balanced 30g protein + complex carbohydrates',
                timeString: '11:30 AM',
                isCompleted: true,
              ),
              DailyPlanTask(
                id: 'task-4',
                title: 'Afternoon hydration check (500ml water or herbal tea)',
                note: 'Sustains cognitive alertness through mid-day dip · 2:00 PM',
                timeString: '2:00 PM',
                isCompleted: false,
                isUpNext: true,
              ),
              DailyPlanTask(
                id: 'task-5',
                title: 'Balanced fiber-rich dinner + magnesium-rich greens',
                note: 'Supports overnight recovery and restorative sleep',
                timeString: '7:00 PM',
                isCompleted: false,
              ),
            ],
          ),
        ) {
    refreshTelemetry();
  }

  Future<void> refreshTelemetry() async {
    final diurnal = DiurnalService.getContext(preferredName: 'Sarah');
    final telemetry = await TelemetryService.getTelemetry(
      solarConditionOverride: diurnal.solarCondition,
    );
    state = state.copyWith(
      diurnal: diurnal,
      telemetry: telemetry,
    );
  }

  void toggleTask(int index) {
    if (index < 0 || index >= state.tasks.length) return;
    final updatedList = List<DailyPlanTask>.from(state.tasks);
    final task = updatedList[index];
    updatedList[index] = task.copyWith(isCompleted: !task.isCompleted);
    state = state.copyWith(tasks: updatedList);
  }

  Future<void> submitResearch(
    String query, {
    String? imagePath,
    UserProfileContext? userProfile,
  }) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(
      isResearchLoading: true,
      researchError: null,
    );

    try {
      // Resolve authentic user profile: explicit caller profile, or fetch from ProfileRepository.
      // If user is unauthenticated or has not configured a profile, remains null (zero mock hallucination).
      UserProfileContext? profile = userProfile;
      if (profile == null) {
        try {
          profile = await _profileRepository.getCurrentUserProfile();
        } catch (_) {
          profile = null;
        }
      }

      final answer = await ResearchPipelineService.processInquiry(
        query: query,
        imagePath: imagePath,
        userProfile: profile,
      );
      state = state.copyWith(
        isResearchLoading: false,
        activeAnswer: answer,
        researchError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isResearchLoading: false,
        researchError: e.toString(),
      );
    }
  }

  void clearActiveAnswer() {
    state = state.copyWith(activeAnswer: null);
  }

  void submitFeedback(String text) {
    if (text.trim().isEmpty) return;
    state = state.copyWith(feedbackSubmitted: true);
  }

  void resetFeedback() {
    state = state.copyWith(feedbackSubmitted: false);
  }
}

final todayStateProvider = StateNotifierProvider<TodayNotifier, TodayState>((ref) {
  final profileRepo = ref.watch(profileRepositoryProvider);
  return TodayNotifier(profileRepository: profileRepo);
});
