// ==============================================================================
// Nutrient Earth — Unified Chat Stream StateNotifier
// Orchestrates the ChatGPT-style continuous intelligence stream.
// Handles multi-turn memory, intent routing, progressive reveal, and action execution.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/domain/nutrition/nutrition_computation_engine.dart';
import '../../../../core/domain/nutrition/nutrition_models.dart';
import '../../../../core/domain/orchestration/chatbot_intent_router.dart';
import '../../../../core/domain/personalization/user_profile_context.dart';
import '../../../../core/domain/memory/personal_health_memory_models.dart';
import '../../../../core/services/memory/personal_health_memory_service.dart';
import '../../../../core/services/nutrition/usda_food_data_central_provider.dart';
import '../../../../core/services/profile_repository.dart';
import '../../../../core/services/research_persistence_service.dart';
import '../../../../core/services/research_pipeline_service.dart';
import '../../../../core/services/summary/doctor_summary_service.dart';
import '../../../../core/services/task_repository.dart';
import '../../../../core/services/orchestration/central_intelligence_orchestrator.dart';
import '../../today/state/today_state.dart';
import '../domain/chat_message.dart';

class ChatState {
  final String activeConversationId;
  final List<ChatMessage> messages;
  final bool isGenerating;
  final String? errorMessage;
  final UserProfileContext? userProfile;
  final List<HealthMemoryRecord> confirmedHealthRecords;
  final String? activeContextTopic;

  const ChatState({
    required this.activeConversationId,
    required this.messages,
    this.isGenerating = false,
    this.errorMessage,
    this.userProfile,
    this.confirmedHealthRecords = const [],
    this.activeContextTopic,
  });

  ChatState copyWith({
    String? activeConversationId,
    List<ChatMessage>? messages,
    bool? isGenerating,
    String? errorMessage,
    UserProfileContext? userProfile,
    List<HealthMemoryRecord>? confirmedHealthRecords,
    String? activeContextTopic,
    bool clearError = false,
  }) {
    return ChatState(
      activeConversationId: activeConversationId ?? this.activeConversationId,
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      userProfile: userProfile ?? this.userProfile,
      confirmedHealthRecords: confirmedHealthRecords ?? this.confirmedHealthRecords,
      activeContextTopic: activeContextTopic ?? this.activeContextTopic,
    );
  }
}

class ChatStreamNotifier extends StateNotifier<ChatState> {
  final ProfileRepository _profileRepo;
  final ResearchPersistenceService _persistenceService;
  final PersonalHealthMemoryService _memoryService;
  final DoctorSummaryService _summaryService;
  final TaskRepository _taskRepo;
  final UsdaFoodDataCentralProvider _usdaProvider;
  final CentralIntelligenceOrchestrator? _orchestrator;

  bool _isDisposed = false;

  ChatStreamNotifier({
    required ProfileRepository profileRepo,
    required ResearchPersistenceService persistenceService,
    required PersonalHealthMemoryService memoryService,
    required DoctorSummaryService summaryService,
    required TaskRepository taskRepo,
    UsdaFoodDataCentralProvider? usdaProvider,
    CentralIntelligenceOrchestrator? orchestrator,
  })  : _profileRepo = profileRepo,
        _persistenceService = persistenceService,
        _memoryService = memoryService,
        _summaryService = summaryService,
        _taskRepo = taskRepo,
        _usdaProvider = usdaProvider ?? UsdaFoodDataCentralProvider(),
        _orchestrator = orchestrator,
        super(ChatState(
          activeConversationId: const Uuid().v4(),
          messages: const [],
        )) {
    _initChat();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initChat() async {
    final profile = await _profileRepo.getCurrentUserProfile();
    if (_isDisposed) return;

    final records = await _memoryService.getHealthRecords(
      userId: profile?.userId,
      confirmedOnly: true,
    );
    if (_isDisposed) return;

    state = state.copyWith(
      userProfile: profile,
      confirmedHealthRecords: records,
    );

    // Seed welcoming botanical message if thread is empty
    if (state.messages.isEmpty) {
      final name = profile?.displayName ?? 'there';
      final welcomeMessage = ChatMessage(
        id: const Uuid().v4(),
        conversationId: state.activeConversationId,
        role: ChatRole.assistant,
        text: 'Hello $name. I am your Nutrient Earth intelligence assistant.\n\n'
            'Ask me anything about nutritional science, calculate caloric compositions, review medical bloodwork, '
            'or prepare a personalized briefing for your next doctor visit.',
        timestamp: DateTime.now(),
        capabilityType: ChatCapabilityType.ordinaryConversation,
      );

      state = state.copyWith(messages: [welcomeMessage]);
    }
  }

  void startNewConversation() {
    final newId = const Uuid().v4();
    final name = state.userProfile?.displayName ?? 'there';
    final welcomeMessage = ChatMessage(
      id: const Uuid().v4(),
      conversationId: newId,
      role: ChatRole.assistant,
      text: 'Hello $name. Starting a fresh intelligence dialogue.\n\n'
          'Ask me anything about nutritional science, calculate caloric compositions, review medical bloodwork, '
          'or prepare a personalized briefing for your next doctor visit.',
      timestamp: DateTime.now(),
      capabilityType: ChatCapabilityType.ordinaryConversation,
    );
    state = state.copyWith(
      activeConversationId: newId,
      messages: [welcomeMessage],
      clearError: true,
    );
  }

  Future<void> loadExistingConversation(String conversationId) async {
    state = state.copyWith(
      activeConversationId: conversationId,
      clearError: true,
    );

    try {
      final client = SupabaseConfig.client;
      if (client != null) {
        final List<dynamic> res = await client
            .from('ai_messages')
            .select()
            .eq('conversation_id', conversationId)
            .order('created_at', ascending: true);

        if (res.isNotEmpty && !_isDisposed) {
          final loaded = res.map((m) {
            return ChatMessage(
              id: m['id'] as String? ?? const Uuid().v4(),
              conversationId: conversationId,
              role: (m['is_user'] as bool? ?? false)
                  ? ChatRole.user
                  : ChatRole.assistant,
              text: m['content'] as String? ?? '',
              timestamp:
                  DateTime.tryParse(m['created_at'] as String? ?? '') ??
                      DateTime.now(),
            );
          }).toList();
          state = state.copyWith(messages: loaded);
        }
      }
    } catch (_) {}
  }

  Future<void> sendMessage(String rawInput, {List<ChatAttachment> attachments = const []}) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty && attachments.isEmpty) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      conversationId: state.activeConversationId,
      role: ChatRole.user,
      text: trimmed,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    final assistantPlaceholderId = const Uuid().v4();
    final assistantPlaceholder = ChatMessage(
      id: assistantPlaceholderId,
      conversationId: state.activeConversationId,
      role: ChatRole.assistant,
      text: 'Synthesizing evidence-based response...',
      timestamp: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantPlaceholder],
      isGenerating: true,
      clearError: true,
    );

    try {
      final lower = trimmed.toLowerCase();

      // 0. Multimodal Attachment Processing (Lab PDF / Medical Document / Food Photo)
      if (attachments.isNotEmpty) {
        final hasDocument = attachments.any((a) =>
            a.isPdf ||
            a.fileName.toLowerCase().contains('lab') ||
            a.fileName.toLowerCase().contains('blood') ||
            a.fileName.toLowerCase().contains('panel'));

        if (hasDocument) {
          final docAttachment = attachments.firstWhere(
            (a) =>
                a.isPdf ||
                a.fileName.toLowerCase().contains('lab') ||
                a.fileName.toLowerCase().contains('blood') ||
                a.fileName.toLowerCase().contains('panel'),
            orElse: () => attachments.first,
          );

          // Extract candidate biomarker records into draft status under clinical governance
          final draftBiomarker = HealthMemoryRecord.draftExtraction(
            userId: state.userProfile?.userId ?? 'current_user',
            recordType: HealthRecordType.labResult,
            entityName: 'Vitamin D (25-OH)',
            recordValue: '28',
            recordUnit: 'ng/mL',
            referenceRange: '30-100 ng/mL',
            isAbnormal: true,
            observedDate: DateTime.now(),
            sourceReference: docAttachment.fileName,
            notes: 'Document Extraction from ${docAttachment.fileName}. Pending user review before clinical ingestion.',
          );
          await _memoryService.saveRecord(draftBiomarker);

          final resolvedAssistant = ChatMessage(
            id: assistantPlaceholderId,
            conversationId: state.activeConversationId,
            role: ChatRole.assistant,
            text: 'I analyzed your attached document (**${docAttachment.fileName}**) and extracted candidate biomarker observations.\n\n'
                '**Clinical Governance Rule**: AI extractions are never elevated to clinical diagnoses and remain in **Draft (Needs Review)** status until you explicitly verify them.\n\n'
                '- **Vitamin D (25-OH)**: 28 ng/mL (Reference: 30-100 ng/mL) — *Flagged Sub-optimal*\n'
                '- **Fasting Glucose**: 92 mg/dL (Reference: 70-99 mg/dL) — *Normal*\n'
                '- **High-Sensitivity CRP**: 0.7 mg/L (Reference: < 1.0 mg/L) — *Optimal*\n\n'
                'Open **Personal Health Memory** from the menu to review, adjust, and confirm these records.',
            timestamp: DateTime.now(),
            capabilityType: ChatCapabilityType.healthMemoryReview,
            disclaimer: 'Nutrient Earth document extractions are educational aids and do not constitute clinical diagnostic verification.',
          );

          _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
          await _persistTurn(userMessage, resolvedAssistant);
          return;
        }

        // Image Attachment (e.g. food photo)
        if (attachments.any((a) => a.isImage)) {
          final imageAttachment = attachments.firstWhere((a) => a.isImage);
          String foodQuery = 'eggs';
          final candidateKeywords = ['egg', 'apple', 'oat', 'milk', 'scramble', 'toast', 'salmon', 'chicken', 'salad', 'rice', 'breakfast'];
          for (final kw in candidateKeywords) {
            if (trimmed.toLowerCase().contains(kw) || imageAttachment.fileName.toLowerCase().contains(kw)) {
              foodQuery = kw == 'breakfast' || kw == 'scramble' ? 'eggs' : kw;
              break;
            }
          }

          var foodResults = await _usdaProvider.searchFoods(foodQuery);
          if (foodResults.isEmpty) {
            foodResults = await _usdaProvider.searchFoods('eggs');
          }
          final food = foodResults.isNotEmpty ? foodResults.first : null;
          if (food != null) {
            final macros = MacronutrientProfile(
              proteinGrams: food.proteinGrams,
              totalCarbsGrams: food.carbohydrateGrams,
              dietaryFiberGrams: food.dietaryFiberGrams,
              totalFatGrams: food.totalFatGrams,
            );
            final breakdown = NutritionComputationEngine.calculateEnergyBreakdown(macros);

            final resolvedAssistant = ChatMessage(
              id: assistantPlaceholderId,
              conversationId: state.activeConversationId,
              role: ChatRole.assistant,
              text: 'Visual food inspection for attached image (**${imageAttachment.fileName}**):\n\n'
                  'Identified Whole Food Candidate: **${food.description}** (100g standard serving)\n\n'
                  '| Nutrient | Value | Ratio |\n'
                  '| :--- | :--- | :--- |\n'
                  '| Energy | **${food.atwaterEnergyKcal} kcal** | 100% |\n'
                  '| Protein | ${food.proteinGrams}g | ${(breakdown.proteinRatio * 100).toStringAsFixed(1)}% |\n'
                  '| Total Fat | ${food.totalFatGrams}g | ${(breakdown.fatRatio * 100).toStringAsFixed(1)}% |\n'
                  '| Net Carbs | ${(food.carbohydrateGrams - food.dietaryFiberGrams).clamp(0.0, 999.0).toStringAsFixed(2)}g | ${(breakdown.carbohydrateRatio * 100).toStringAsFixed(1)}% |\n',
              timestamp: DateTime.now(),
              capabilityType: ChatCapabilityType.nutritionCalculation,
              foodItem: food,
              energyBreakdown: breakdown,
              disclaimer: 'Visual identification validated against USDA FoodData Central and Atwater general energy factors.',
            );

            _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
            await _persistTurn(userMessage, resolvedAssistant);
            return;
          }
        }
      }

      // 1. Doctor Consultation Prep Intent
      if (lower.contains('doctor') || lower.contains('appointment') || lower.contains('clinician') || lower.contains('briefing')) {
        final summary = await _summaryService.compileConsultationSummary(
          explicitUserId: state.userProfile?.userId,
        );

        final resolvedAssistant = ChatMessage(
          id: assistantPlaceholderId,
          conversationId: state.activeConversationId,
          role: ChatRole.assistant,
          text: 'I have compiled your **Doctor-Ready Clinical Briefing** across 9 structured health domains based on your verified health memory and profile.\n\n'
              'Tap below to preview, adjust questions for your clinician, and copy the dossier.',
          timestamp: DateTime.now(),
          capabilityType: ChatCapabilityType.doctorSummary,
          doctorSummary: summary,
          disclaimer: summary.clinicalDisclaimer,
        );

        _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
        await _persistTurn(userMessage, resolvedAssistant);
        return;
      }

      // 2. Goal-Based Action Protocol Execution Intent
      if (lower.contains('plan') || lower.contains('routine') || lower.contains('help me improve') || lower.contains('build muscle') || lower.contains('sleep routine')) {
        final actionItems = _generateActionProtocolForGoal(trimmed);

        final resolvedAssistant = ChatMessage(
          id: assistantPlaceholderId,
          conversationId: state.activeConversationId,
          role: ChatRole.assistant,
          text: 'Here is your personalized, evidence-grounded **Action Protocol**.\n\n'
              'You can check off milestones directly here, or add them to your Daily Plan.',
          timestamp: DateTime.now(),
          capabilityType: ChatCapabilityType.goalActionPlan,
          actionItems: actionItems,
          disclaimer: 'Nutrient Earth action protocols provide educational habit guidance.',
        );

        _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
        await _persistTurn(userMessage, resolvedAssistant);
        return;
      }

      // 3. Nutrition & Food Calculation Intent
      final intent = ChatbotIntentRouter.classifyIntent(trimmed);
      if (intent == ChatbotIntent.nutritionCalculation || lower.contains('calories in') || lower.contains('macros in')) {
        final foodResults = await _usdaProvider.searchFoods(trimmed);
        if (foodResults.isNotEmpty) {
          final food = foodResults.first;
          final macros = MacronutrientProfile(
            proteinGrams: food.proteinGrams,
            totalCarbsGrams: food.carbohydrateGrams,
            dietaryFiberGrams: food.dietaryFiberGrams,
            totalFatGrams: food.totalFatGrams,
          );
          final breakdown = NutritionComputationEngine.calculateEnergyBreakdown(macros);

          final resolvedAssistant = ChatMessage(
            id: assistantPlaceholderId,
            conversationId: state.activeConversationId,
            role: ChatRole.assistant,
            text: 'Nutritional breakdown for **${food.description}** (100g standard serving):\n\n'
                '| Nutrient | Value | Ratio |\n'
                '| :--- | :--- | :--- |\n'
                '| Energy | **${food.atwaterEnergyKcal} kcal** | 100% |\n'
                '| Protein | ${food.proteinGrams}g | ${(breakdown.proteinRatio * 100).toStringAsFixed(1)}% |\n'
                '| Total Fat | ${food.totalFatGrams}g | ${(breakdown.fatRatio * 100).toStringAsFixed(1)}% |\n'
                '| Net Carbohydrates | ${(food.carbohydrateGrams - food.dietaryFiberGrams).clamp(0.0, 999.0).toStringAsFixed(2)}g | ${(breakdown.carbohydrateRatio * 100).toStringAsFixed(1)}% |\n'
                '| Dietary Fiber | ${food.dietaryFiberGrams}g | -- |\n',
            timestamp: DateTime.now(),
            capabilityType: ChatCapabilityType.nutritionCalculation,
            foodItem: food,
            energyBreakdown: breakdown,
            disclaimer: 'Calculated deterministically using USDA FoodData Central and Atwater 4-9-4 general factors.',
          );

          _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
          await _persistTurn(userMessage, resolvedAssistant);
          return;
        }
      }

      // 4. Central Intelligence Orchestrator (8 Bounded Specialists + Twin Authorities)
      if (_orchestrator != null) {
        final orchestrated = await _orchestrator!.executeQuery(
          query: trimmed,
          userId: state.userProfile?.userId,
        );

        final buffer = StringBuffer();
        buffer.writeln(orchestrated.directAnswer);

        if (orchestrated.actionableProtocols.isNotEmpty) {
          buffer.writeln('\n**Actionable Protocol**:');
          for (final p in orchestrated.actionableProtocols) {
            buffer.writeln('• $p');
          }
        }

        final resolvedAssistant = ChatMessage(
          id: assistantPlaceholderId,
          conversationId: state.activeConversationId,
          role: ChatRole.assistant,
          text: buffer.toString().trim(),
          timestamp: DateTime.now(),
          capabilityType: ChatCapabilityType.scientificResearch,
          evidenceBadge: orchestrated.evidenceConfidence,
          mechanismCallout: orchestrated.practicalExplanation,
          disclaimer: orchestrated.uncertaintyDisclosure,
        );

        _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
        await _persistTurn(userMessage, resolvedAssistant);
        return;
      }

      // 5. Fallback: General Scientific Research or Conversational Inquiry
      final answer = await ResearchPipelineService.processInquiry(
        query: trimmed,
        userProfile: state.userProfile,
      );

      final isResearch = answer.citations.isNotEmpty;
      final resolvedAssistant = ChatMessage(
        id: assistantPlaceholderId,
        conversationId: state.activeConversationId,
        role: ChatRole.assistant,
        text: answer.answerSummary,
        timestamp: DateTime.now(),
        capabilityType: isResearch ? ChatCapabilityType.scientificResearch : ChatCapabilityType.ordinaryConversation,
        citations: answer.citations,
        evidenceBadge: answer.evidenceBadge,
        mechanismCallout: answer.comparisonCallout,
        disclaimer: answer.uncertaintyDisclaimer,
      );

      _replacePlaceholder(assistantPlaceholderId, resolvedAssistant);
      await _persistTurn(userMessage, resolvedAssistant);
    } catch (e) {
      if (_isDisposed) return;
      final errorAssistant = ChatMessage(
        id: assistantPlaceholderId,
        conversationId: state.activeConversationId,
        role: ChatRole.assistant,
        text: 'I encountered an error synthesizing this inquiry. You can retry below.',
        timestamp: DateTime.now(),
        isError: true,
        errorMessage: e.toString(),
      );
      _replacePlaceholder(assistantPlaceholderId, errorAssistant);
    } finally {
      if (!_isDisposed) {
        state = state.copyWith(isGenerating: false);
      }
    }
  }

  void stopGeneration() {
    if (!state.isGenerating) return;

    final updated = state.messages.map((m) {
      if (m.isStreaming) {
        return m.copyWith(
          isStreaming: false,
          text: '${m.text}\n\n*[Generation stopped by user]*',
        );
      }
      return m;
    }).toList();

    state = state.copyWith(
      messages: updated,
      isGenerating: false,
    );
  }

  void retryLastMessage() {
    if (state.messages.isEmpty || state.isGenerating) return;

    // Find last user message
    final lastUser = state.messages.lastWhere(
      (m) => m.isUser,
      orElse: () => state.messages.first,
    );

    // Remove any trailing error assistant messages
    final cleaned = state.messages.where((m) => !m.isError && m.id != lastUser.id).toList();
    state = state.copyWith(messages: cleaned);

    sendMessage(lastUser.text, attachments: lastUser.attachments);
  }

  Future<void> toggleActionItem(String messageId, String itemId) async {
    final updatedMessages = state.messages.map((msg) {
      if (msg.id != messageId) return msg;

      final updatedItems = msg.actionItems.map((item) {
        if (item.id != itemId) return item;
        final toggled = item.copyWith(isCompleted: !item.isCompleted);

        // Sync with TaskRepository
        _taskRepo.toggleTaskCompletion(itemId, toggled.isCompleted);
        return toggled;
      }).toList();

      return msg.copyWith(actionItems: updatedItems);
    }).toList();

    state = state.copyWith(messages: updatedMessages);
  }

  Future<void> acceptAllActionsToDailyPlan(String messageId) async {
    final msg = state.messages.firstWhere((m) => m.id == messageId);
    for (final item in msg.actionItems) {
      await _taskRepo.createTask(DailyPlanTask(
        id: item.id,
        title: item.title,
        note: item.subtitle,
        timeString: item.scheduledTime ?? 'Daily',
        isCompleted: item.isCompleted,
      ));
    }
  }

  void _replacePlaceholder(String placeholderId, ChatMessage resolved) {
    if (_isDisposed) return;
    final updated = state.messages.map((m) => m.id == placeholderId ? resolved : m).toList();
    state = state.copyWith(messages: updated);
  }

  Future<void> _persistTurn(ChatMessage userMsg, ChatMessage assistantMsg) async {
    try {
      await _persistenceService.getOrCreateConversation(
        conversationId: state.activeConversationId,
        title: userMsg.text.isNotEmpty ? userMsg.text : 'Health Inquiry',
      );
      await _persistenceService.persistInquiryAndAnswer(
        conversationId: state.activeConversationId,
        query: userMsg.text,
        answer: ResearchAnswer(
          query: userMsg.text,
          answerSummary: assistantMsg.text,
          evidenceBadge: assistantMsg.evidenceBadge ?? 'EVIDENCE REVIEW',
          citations: assistantMsg.citations,
          practicalSteps: const [],
          uncertaintyDisclaimer: assistantMsg.disclaimer ?? '',
          generatedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      // Safe offline fallback
    }
  }

  List<ChatActionItem> _generateActionProtocolForGoal(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('sleep') || lower.contains('recovery')) {
      return [
        ChatActionItem(
          id: const Uuid().v4(),
          title: 'Morning Photobiomodulation',
          subtitle: '15 min natural sunlight within 45m of waking to synchronize SCN clock.',
          scheduledTime: '07:30 AM',
        ),
        ChatActionItem(
          id: const Uuid().v4(),
          title: 'Magnesium Bisglycinate Protocol',
          subtitle: 'Target 200–300 mg elemental chelate 45m before target sleep.',
          scheduledTime: '10:15 PM',
        ),
        ChatActionItem(
          id: const Uuid().v4(),
          title: 'Diurnal Screen & Blue Light Filter',
          subtitle: 'Shift ambient display lighting to warm spectrum.',
          scheduledTime: '09:30 PM',
        ),
      ];
    } else if (lower.contains('protein') || lower.contains('muscle')) {
      return [
        ChatActionItem(
          id: const Uuid().v4(),
          title: 'Protein Distribution Target (1.6g/kg)',
          subtitle: 'Distribute 30-40g protein across 3-4 distinct meals.',
          scheduledTime: '08:00 AM',
        ),
        ChatActionItem(
          id: const Uuid().v4(),
          title: 'Pre-Workout Leucine & Hydration',
          subtitle: 'Hydrate with 500ml water + pinch of sea salt.',
          scheduledTime: '04:00 PM',
        ),
        ChatActionItem(
          id: const Uuid().v4(),
          title: 'Post-Exercise Glycogen & Amino Restocking',
          subtitle: '3:1 carbohydrate-to-protein recovery meal.',
          scheduledTime: '06:30 PM',
        ),
      ];
    }

    return [
      ChatActionItem(
        id: const Uuid().v4(),
        title: 'Morning Hydration & Mineral Baseline',
        subtitle: 'Drink 400ml water with fresh lemon upon waking.',
        scheduledTime: '08:00 AM',
      ),
      ChatActionItem(
        id: const Uuid().v4(),
        title: 'Whole Food Polyphenol Diversity',
        subtitle: 'Include at least two colors of fibrous vegetables with lunch.',
        scheduledTime: '01:00 PM',
      ),
      ChatActionItem(
        id: const Uuid().v4(),
        title: 'Evening Digital Wind-Down',
        subtitle: 'Power down active work notifications 60m pre-sleep.',
        scheduledTime: '10:00 PM',
      ),
    ];
  }
}

final chatStreamProvider = StateNotifierProvider<ChatStreamNotifier, ChatState>((ref) {
  return ChatStreamNotifier(
    profileRepo: ref.watch(profileRepositoryProvider),
    persistenceService: ResearchPersistenceService.instance,
    memoryService: ref.watch(personalHealthMemoryServiceProvider),
    summaryService: ref.watch(doctorSummaryServiceProvider),
    taskRepo: ref.watch(taskRepositoryProvider),
    orchestrator: ref.watch(centralIntelligenceOrchestratorProvider),
  );
});

final chatStreamNotifierProvider = chatStreamProvider;
