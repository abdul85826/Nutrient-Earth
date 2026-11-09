// ==============================================================================
// Unit & Integration Test: unified_chat_and_memory_test.dart
// ONE INTERFACE INTELLIGENCE ARCHITECTURE VERIFICATION
// Proves:
// 1. Personal Health Memory Confirmation Gate and Multi-User Isolation.
// 2. Doctor-Ready Clinical Consultation Summary (9 structured clinical domains).
// 3. Unified Continuous Chat Stream StateNotifier (Intent routing, action milestones, stop gen).
// 4. Widget rendering for ChatMessageTile and UnifiedChatComposer.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:nutrient_earth_client/core/domain/memory/personal_health_memory_models.dart';
import 'package:nutrient_earth_client/core/domain/personalization/user_profile_context.dart';
import 'package:nutrient_earth_client/core/services/memory/personal_health_memory_service.dart';
import 'package:nutrient_earth_client/core/services/profile_repository.dart';
import 'package:nutrient_earth_client/core/services/research_persistence_service.dart';
import 'package:nutrient_earth_client/core/services/summary/doctor_summary_service.dart';
import 'package:nutrient_earth_client/core/services/task_repository.dart';
import 'package:nutrient_earth_client/features/chat/domain/chat_message.dart';
import 'package:nutrient_earth_client/features/chat/presentation/widgets/chat_message_tile.dart';
import 'package:nutrient_earth_client/features/chat/presentation/widgets/unified_chat_composer.dart';
import 'package:nutrient_earth_client/features/chat/state/chat_stream_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('Personal Health Memory Service & Confirmation Gate', () {
    const userA = 'user-aaa-111';
    const userB = 'user-bbb-222';

    test('Draft records require user confirmation and do not appear in confirmedOnly queries', () async {
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);

      // AI extracts a suspected allergy from chat or document
      final draftAllergy = HealthMemoryRecord(
        id: const Uuid().v4(),
        userId: userA,
        recordType: HealthRecordType.allergy,
        provenanceSource: MemoryProvenanceSource.documentExtracted,
        entityName: 'Penicillin',
        recordValue: 'Severe urticaria',
        recordedDate: DateTime.now(),
        verificationStatus: MemoryVerificationStatus.draftPendingReview,
      );

      await memoryService.saveRecord(draftAllergy, userId: userA);

      // Query confirmed only -> should be empty
      final confirmed = await memoryService.getHealthRecords(userId: userA, confirmedOnly: true);
      expect(confirmed.isEmpty, isTrue);

      // Query all records -> draft is present
      final all = await memoryService.getHealthRecords(userId: userA, confirmedOnly: false);
      expect(all.length, 1);
      expect(all.first.verificationStatus, MemoryVerificationStatus.draftPendingReview);

      // User confirms the draft
      final confirmedSuccess = await memoryService.confirmRecord(draftAllergy.id, userId: userA);
      expect(confirmedSuccess, isTrue);

      // Now query confirmed only -> should contain confirmed Penicillin allergy
      final confirmedAfter = await memoryService.getHealthRecords(userId: userA, confirmedOnly: true);
      expect(confirmedAfter.length, 1);
      expect(confirmedAfter.first.entityName, 'Penicillin');
      expect(confirmedAfter.first.verificationStatus, MemoryVerificationStatus.userConfirmed);
    });

    test('User can reject a draft record, preventing it from entering health memory', () async {
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);

      final draftMed = HealthMemoryRecord(
        id: const Uuid().v4(),
        userId: userA,
        recordType: HealthRecordType.medication,
        provenanceSource: MemoryProvenanceSource.aiInferred,
        entityName: 'Atorvastatin',
        recordValue: '20mg',
        recordedDate: DateTime.now(),
        verificationStatus: MemoryVerificationStatus.draftPendingReview,
      );

      await memoryService.saveRecord(draftMed, userId: userA);
      final beforeReject = await memoryService.getHealthRecords(userId: userA);
      expect(beforeReject.length, 1);

      // Reject draft
      final rejected = await memoryService.rejectRecord(draftMed.id, userId: userA);
      expect(rejected, isTrue);

      final afterReject = await memoryService.getHealthRecords(userId: userA);
      expect(afterReject.isEmpty, isTrue);
    });

    test('Multi-user health memory isolation: User A records are invisible to User B', () async {
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);

      final userARecord = HealthMemoryRecord(
        id: const Uuid().v4(),
        userId: userA,
        recordType: HealthRecordType.condition,
        provenanceSource: MemoryProvenanceSource.userReported,
        entityName: 'Celiac Disease',
        recordedDate: DateTime.now(),
        verificationStatus: MemoryVerificationStatus.userConfirmed,
      );

      final userBRecord = HealthMemoryRecord(
        id: const Uuid().v4(),
        userId: userB,
        recordType: HealthRecordType.supplement,
        provenanceSource: MemoryProvenanceSource.userReported,
        entityName: 'Creatine Monohydrate',
        recordedDate: DateTime.now(),
        verificationStatus: MemoryVerificationStatus.userConfirmed,
      );

      await memoryService.saveRecord(userARecord, userId: userA);
      await memoryService.saveRecord(userBRecord, userId: userB);

      final recordsA = await memoryService.getHealthRecords(userId: userA);
      expect(recordsA.length, 1);
      expect(recordsA.first.entityName, 'Celiac Disease');

      final recordsB = await memoryService.getHealthRecords(userId: userB);
      expect(recordsB.length, 1);
      expect(recordsB.first.entityName, 'Creatine Monohydrate');
    });
  });

  group('Doctor-Ready Consultation Summary Service (9 Domains)', () {
    const userId = 'patient-test-user-001';

    test('Synthesizes 9 clinical sections without fabricating unverified data', () async {
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final profileRepo = SupabaseProfileRepository(prefs: prefs);

      final profile = UserProfileContext(
        userId: userId,
        displayName: 'Dr. Jane Doe Patient',
        age: 42,
        biologicalSex: 'female',
        primaryGoals: const ['Cardiovascular Health', 'Endurance'],
        heightCm: 168.0,
        weightKg: 62.0,
        activityLevel: 'moderate',
        dietaryPreference: 'mediterranean',
        budgetConstraint: 'moderate',
        willingnessToChange: 'high',
        knownConditions: const ['Mild Asthma'],
        activeSupplements: const ['CoQ10', 'Magnesium Bisglycinate'],
        allergies: const ['Latex'],
      );
      await profileRepo.saveUserProfile(profile);

      // Add confirmed lab biomarker
      await memoryService.saveRecord(
        HealthMemoryRecord(
          id: const Uuid().v4(),
          userId: userId,
          recordType: HealthRecordType.labResult,
          provenanceSource: MemoryProvenanceSource.documentExtracted,
          entityName: 'Lipoprotein(a)',
          recordValue: '125',
          recordUnit: 'nmol/L',
          referenceRange: '< 75 nmol/L',
          isAbnormal: true,
          recordedDate: DateTime.now(),
          verificationStatus: MemoryVerificationStatus.userConfirmed,
        ),
        userId: userId,
      );

      final summaryService = DoctorSummaryService(
        profileRepo: profileRepo,
        memoryService: memoryService,
      );

      final summary = await summaryService.compileConsultationSummary(explicitUserId: userId);

      expect(summary.patientDisplayName, 'Dr. Jane Doe Patient');
      expect(summary.age, 42);
      expect(summary.biologicalSex, 'female');
      expect(summary.chiefConcernsAndGoals.contains('Cardiovascular Health'), isTrue);
      expect(summary.confirmedConditions.any((c) => c.entityName.contains('Asthma')), isTrue);
      expect(summary.recentBiomarkersAndLabs.any((l) => l.entityName == 'Lipoprotein(a)' && l.isAbnormal == true), isTrue);
      expect(summary.questionsForClinician.isNotEmpty, isTrue);
      expect(summary.clinicalDisclaimer.contains('Does not constitute an independent clinical diagnosis'), isTrue);

      final clinicalText = summary.toFormattedClinicalText();
      expect(clinicalText.contains('1. CHIEF CONCERNS & WELLNESS GOALS:'), isTrue);
      expect(clinicalText.contains('2. SYMPTOM TIMELINE & REPORTED ISSUES:'), isTrue);
      expect(clinicalText.contains('3. CONFIRMED MEDICAL HISTORY & CONDITIONS:'), isTrue);
      expect(clinicalText.contains('4. ACTIVE MEDICATIONS & SUPPLEMENTS:'), isTrue);
      expect(clinicalText.contains('5. ALLERGIES & ADVERSE REACTIONS:'), isTrue);
      expect(clinicalText.contains('6. RECENT BIOMARKERS & LAB RESULTS:'), isTrue);
      expect(clinicalText.contains('7. LIFESTYLE & BIOMETRICS:'), isTrue);
      expect(clinicalText.contains('8. QUESTIONS PREPARED FOR CLINICIAN:'), isTrue);
      expect(clinicalText.contains('9. DISCLOSURE OF UNCERTAIN / MISSING INFORMATION:'), isTrue);
    });
  });

  group('Unified Chat Stream Notifier', () {
    test('Initializes with welcome message and conversation id', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      // Wait a microtask for _initChat to settle
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.activeConversationId.isNotEmpty, isTrue);
      expect(notifier.state.messages.length, 1);
      expect(notifier.state.messages.first.isAssistant, isTrue);
      expect(notifier.state.messages.first.text.contains('Nutrient Earth intelligence assistant'), isTrue);

      notifier.dispose();
    });

    test('Handles Doctor consultation intent and synthesizes DoctorSummary capability', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.sendMessage('Prepare a summary for my upcoming doctor appointment');

      expect(notifier.state.messages.length, 3); // welcome, user, assistant
      final assistantMsg = notifier.state.messages.last;
      expect(assistantMsg.capabilityType, ChatCapabilityType.doctorSummary);
      expect(assistantMsg.doctorSummary, isNotNull);
      expect(assistantMsg.doctorSummary!.patientDisplayName.isNotEmpty, isTrue);

      notifier.dispose();
    });

    test('Handles Goal Action Protocol intent and toggles milestones', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      await notifier.sendMessage('Give me a sleep routine plan');

      final assistantMsg = notifier.state.messages.last;
      expect(assistantMsg.capabilityType, ChatCapabilityType.goalActionPlan);
      expect(assistantMsg.actionItems.length, greaterThanOrEqualTo(3));

      // Toggle first milestone
      final firstItemId = assistantMsg.actionItems.first.id;
      expect(assistantMsg.actionItems.first.isCompleted, isFalse);

      await notifier.toggleActionItem(assistantMsg.id, firstItemId);

      final updatedAssistantMsg = notifier.state.messages.last;
      final toggledItem = updatedAssistantMsg.actionItems.firstWhere((i) => i.id == firstItemId);
      expect(toggledItem.isCompleted, isTrue);

      notifier.dispose();
    });

    test('Stop generation stops active streaming placeholder', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      // Send message without waiting for resolution, immediately call stopGeneration
      final sendFuture = notifier.sendMessage('What is the clinical evidence for berberine vs metformin?');
      notifier.stopGeneration();
      await sendFuture;

      expect(notifier.state.isGenerating, isFalse);

      notifier.dispose();
    });

    test('startNewConversation resets conversation ID and turns', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      final originalId = notifier.state.activeConversationId;

      await notifier.sendMessage('How does cold plunge affect dopamine?');
      expect(notifier.state.messages.length, greaterThan(1));

      await notifier.startNewConversation();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.activeConversationId != originalId, isTrue);
      expect(notifier.state.messages.length, 1); // Reset to just welcoming message

      notifier.dispose();
    });

    test('Handles Document attachment and drafts biomarker under clinical governance', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      const attachment = ChatAttachment(
        id: 'att_lab_001',
        fileName: 'annual_bloodwork_panel.pdf',
        mimeType: 'application/pdf',
      );

      await notifier.sendMessage('Please analyze my bloodwork', attachments: const [attachment]);

      expect(notifier.state.messages.length, 3);
      final assistantMsg = notifier.state.messages.last;
      expect(assistantMsg.capabilityType, ChatCapabilityType.healthMemoryReview);
      expect(assistantMsg.text.contains('Clinical Governance Rule'), isTrue);

      // Verify that the extracted biomarker is strictly draft_pending_review in memory
      final drafts = await memoryService.getHealthRecords(confirmedOnly: false);
      expect(drafts.any((d) => d.entityName == 'Vitamin D (25-OH)'), isTrue);
      final vitD = drafts.firstWhere((d) => d.entityName == 'Vitamin D (25-OH)');
      expect(vitD.verificationStatus, MemoryVerificationStatus.draftPendingReview);
      expect(vitD.isAbnormal, isTrue);

      notifier.dispose();
    });

    test('Handles Food photo image attachment and computes whole food nutrition', () async {
      final profileRepo = SupabaseProfileRepository(prefs: prefs);
      final memoryService = SupabasePersonalHealthMemoryService(prefs: prefs);
      final summaryService = DoctorSummaryService(profileRepo: profileRepo, memoryService: memoryService);
      const taskRepo = SupabaseTaskRepository();

      final notifier = ChatStreamNotifier(
        profileRepo: profileRepo,
        persistenceService: ResearchPersistenceService.instance,
        memoryService: memoryService,
        summaryService: summaryService,
        taskRepo: taskRepo,
      );

      await Future.delayed(const Duration(milliseconds: 50));

      const attachment = ChatAttachment(
        id: 'att_food_001',
        fileName: 'morning_scramble.jpg',
        mimeType: 'image/jpeg',
      );

      await notifier.sendMessage('What are the macros for this breakfast?', attachments: const [attachment]);

      expect(notifier.state.messages.length, 3);
      final assistantMsg = notifier.state.messages.last;
      expect(assistantMsg.capabilityType, ChatCapabilityType.nutritionCalculation);
      expect(assistantMsg.foodItem, isNotNull);
      expect(assistantMsg.energyBreakdown, isNotNull);

      notifier.dispose();
    });
  });

  group('UI Presentation & Widget Tests', () {
    testWidgets('ChatMessageTile renders user and assistant turns with actions', (tester) async {
      final userMessage = ChatMessage(
        id: 'msg-user-1',
        conversationId: 'conv-1',
        role: ChatRole.user,
        text: 'How does creatine support cognitive performance?',
        timestamp: DateTime.now(),
      );

      final assistantMessage = ChatMessage(
        id: 'msg-assistant-1',
        conversationId: 'conv-1',
        role: ChatRole.assistant,
        text: 'Creatine monohydrate enhances brain phosphocreatine resynthesis during high cognitive demand.',
        timestamp: DateTime.now(),
        capabilityType: ChatCapabilityType.scientificResearch,
        actionItems: const [
          ChatActionItem(
            id: 'action-1',
            title: 'Take 5g Creatine Monohydrate',
            subtitle: 'With morning hydration protocol',
            isCompleted: false,
          ),
        ],
      );

      bool toggled = false;
      bool accepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ChatMessageTile(message: userMessage),
                ChatMessageTile(
                  message: assistantMessage,
                  onActionItemToggled: (_) => toggled = true,
                  onAcceptAllActions: () => accepted = true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('How does creatine support cognitive performance?'), findsOneWidget);
      expect(find.textContaining('phosphocreatine resynthesis'), findsOneWidget);
      expect(find.text('ACTIONABLE MILESTONES'), findsOneWidget);
      expect(find.text('Take 5g Creatine Monohydrate'), findsOneWidget);

      // Tap milestone
      await tester.tap(find.text('Take 5g Creatine Monohydrate'));
      expect(toggled, isTrue);

      // Tap add to daily plan
      await tester.tap(find.text('+ Add to Daily Plan'));
      expect(accepted, isTrue);
    });

    testWidgets('UnifiedChatComposer renders input controls and triggers submit', (tester) async {
      String? submittedText;
      bool cameraTapped = false;
      bool voiceTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: UnifiedChatComposer(
              onSubmitted: (text) => submittedText = text,
              onCameraTap: () => cameraTapped = true,
              onVoiceTap: () => voiceTapped = true,
              isGenerating: false,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

      // Tap camera
      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      expect(cameraTapped, isTrue);

      // Tap voice
      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      expect(voiceTapped, isTrue);

      // Enter text and submit
      await tester.enterText(find.byType(TextField), 'Optimal protein for recovery');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      expect(submittedText, 'Optimal protein for recovery');
    });
  });
}
