import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/tokens/ne_tokens.dart';
import '../../../core/domain/answer_contract/universal_intelligence_answer.dart';
import '../../../core/domain/input_gateway/input_classification_gateway.dart';
import '../../../core/domain/input_gateway/universal_input_descriptor.dart';
import '../../../core/domain/personalization/user_profile_context.dart';
import '../../../core/services/diurnal_service.dart';
import '../../../core/services/profile_repository.dart';
import '../../../core/services/task_repository.dart';
import '../../../core/services/telemetry_service.dart';
import '../../../core/services/research_pipeline_service.dart';
import '../../../core/services/auth_service.dart';

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
  final UniversalIntelligenceAnswer? universalAnswer;
  final String? researchError;
  final bool feedbackSubmitted;
  final UserProfileContext? userProfile;
  final String? activeContextTopic;

  const TodayState({
    required this.diurnal,
    required this.telemetry,
    required this.tasks,
    this.isResearchLoading = false,
    this.activeAnswer,
    this.universalAnswer,
    this.researchError,
    this.feedbackSubmitted = false,
    this.userProfile,
    this.activeContextTopic,
  });

  int get completedTaskCount => tasks.where((t) => t.isCompleted).length;
  int get totalTaskCount => tasks.length;
  String get counterLabel {
    if (tasks.isEmpty) return '0 OF 0 COMPLETED';
    return '$completedTaskCount OF $totalTaskCount COMPLETED';
  }

  TodayState copyWith({
    DiurnalContext? diurnal,
    TelemetryData? telemetry,
    List<DailyPlanTask>? tasks,
    bool? isResearchLoading,
    ResearchAnswer? activeAnswer,
    UniversalIntelligenceAnswer? universalAnswer,
    String? researchError,
    bool? feedbackSubmitted,
    UserProfileContext? userProfile,
    String? activeContextTopic,
    bool clearAnswers = false,
  }) {
    return TodayState(
      diurnal: diurnal ?? this.diurnal,
      telemetry: telemetry ?? this.telemetry,
      tasks: tasks ?? this.tasks,
      isResearchLoading: isResearchLoading ?? this.isResearchLoading,
      activeAnswer: clearAnswers ? null : (activeAnswer ?? this.activeAnswer),
      universalAnswer: clearAnswers ? null : (universalAnswer ?? this.universalAnswer),
      researchError: researchError,
      feedbackSubmitted: feedbackSubmitted ?? this.feedbackSubmitted,
      userProfile: userProfile ?? this.userProfile,
      activeContextTopic: activeContextTopic ?? this.activeContextTopic,
    );
  }
}

class TodayNotifier extends StateNotifier<TodayState> {
  final ProfileRepository _profileRepository;
  final TaskRepository _taskRepository;
  final String? userId;

  TodayNotifier({
    this.userId,
    ProfileRepository? profileRepository,
    TaskRepository? taskRepository,
  })  : _profileRepository = profileRepository ?? const SupabaseProfileRepository(),
        _taskRepository = taskRepository ?? const SupabaseTaskRepository(),
        super(
          TodayState(
            diurnal: DiurnalService.getContext(),
            telemetry: TelemetryData(
              formattedTime: '',
              solarCondition: 'Radiant',
              aqi: 0,
              aqiLabel: 'Awaiting sync',
              aqiColor: NETokens.onSurfaceVariant,
              temperatureCelsius: 0.0,
              weatherCondition: 'Ready to connect',
              streakDays: 0,
              streakLabel: 'Fresh start',
              observationTime: DateTime.now(),
            ),
            tasks: const [],
          ),
        ) {
    _initialize();
  }

  Future<void> _initialize() async {
    await loadUserProfile();
    await refreshTelemetry();
    await loadDailyTasks();
  }

  Future<void> loadDailyTasks() async {
    try {
      final tasks = await _taskRepository.getDailyTasks();
      state = state.copyWith(tasks: tasks);
    } catch (_) {
      state = state.copyWith(tasks: const []);
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final profile = await _profileRepository.getCurrentUserProfile();
      if (profile != null) {
        final diurnal = DiurnalService.getContext(preferredName: profile.displayName);
        state = state.copyWith(
          userProfile: profile,
          diurnal: diurnal,
        );
      }
    } catch (_) {
      // Graceful fallback to guest state
    }
  }

  Future<void> refreshTelemetry() async {
    final name = state.userProfile?.displayName;
    final diurnal = DiurnalService.getContext(preferredName: name);
    final telemetry = await TelemetryService.getTelemetry(
      solarConditionOverride: diurnal.solarCondition,
    );
    state = state.copyWith(
      diurnal: diurnal,
      telemetry: telemetry,
    );
  }

  Future<void> toggleTask(int index) async {
    if (index < 0 || index >= state.tasks.length) return;
    final updatedList = List<DailyPlanTask>.from(state.tasks);
    final task = updatedList[index];
    final newStatus = !task.isCompleted;
    updatedList[index] = task.copyWith(isCompleted: newStatus);
    state = state.copyWith(tasks: updatedList);

    if (task.id.isNotEmpty) {
      await _taskRepository.toggleTaskCompletion(task.id, newStatus);
    }
  }

  Future<void> addTask(DailyPlanTask task) async {
    final created = await _taskRepository.createTask(task);
    final newTask = created ?? task;
    state = state.copyWith(tasks: [...state.tasks, newTask]);
  }

  Future<void> submitUniversalInquiry(
    UniversalInputDescriptor descriptor, {
    UserProfileContext? userProfile,
  }) async {
    state = state.copyWith(
      isResearchLoading: true,
      researchError: null,
      clearAnswers: true,
    );

    try {
      UserProfileContext? profile = userProfile;
      if (profile == null) {
        try {
          profile = await _profileRepository.getCurrentUserProfile();
        } catch (_) {
          profile = null;
        }
      }

      final universal = await ResearchPipelineService.processUniversalInquiry(
        descriptor: descriptor,
        userProfile: profile,
        activeContextTopic: state.activeContextTopic,
      );
      final legacyAnswer = ResearchAnswer.fromUniversalAnswer(universal);

      final lower = descriptor.rawPayload.toLowerCase();
      String? newTopic = state.activeContextTopic;
      if (lower.contains('isabgol') || lower.contains('psyllium')) {
        newTopic = 'isabgol';
      } else if (lower.contains('egg')) {
        newTopic = 'egg';
      } else if (lower.contains('apple')) {
        newTopic = 'apple';
      }

      state = state.copyWith(
        isResearchLoading: false,
        activeAnswer: legacyAnswer,
        universalAnswer: universal,
        activeContextTopic: newTopic,
        researchError: null,
      );
    } catch (e) {
      state = state.copyWith(
        isResearchLoading: false,
        researchError: e.toString(),
      );
    }
  }

  Future<void> submitResearch(
    String query, {
    String? imagePath,
    UserProfileContext? userProfile,
  }) async {
    if (query.trim().isEmpty) return;

    final descriptor = InputClassificationGateway.classifyRawInput(
      rawInput: query,
      sourceType: InputSourceType.userText,
    );

    await submitUniversalInquiry(descriptor, userProfile: userProfile);
  }

  void clearActiveAnswer() {
    state = state.copyWith(clearAnswers: true);
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
  final user = ref.watch(currentUserProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  return TodayNotifier(
    userId: user?.id,
    profileRepository: profileRepo,
    taskRepository: taskRepo,
  );
});
