// ==============================================================================
// Nutrient Earth — End-to-End Research Persistence & Tenant Isolation Tests
// Tests real Flutter client services (ResearchPersistenceService) against live
// Supabase database enforcing multi-tenant Row Level Security policies.
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nutrient_earth_client/core/services/research_persistence_service.dart';
import 'package:nutrient_earth_client/core/services/research_pipeline_service.dart';

void main() {
  const localSupabaseUrl = 'http://127.0.0.1:54321';
  const localAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  late SupabaseClient clientA;
  late SupabaseClient clientB;
  late SupabaseClient clientAnon;
  late ResearchPersistenceService serviceA;
  late ResearchPersistenceService serviceB;
  late ResearchPersistenceService serviceAnon;

  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final emailUserA = 'tester_a_$timestamp@nutrientearth.test';
  final emailUserB = 'tester_b_$timestamp@nutrientearth.test';
  const testPassword = 'Password_123456_Test!';

  setUpAll(() async {
    const authOptions = AuthClientOptions(authFlowType: AuthFlowType.implicit);
    
    // Truly anonymous client (never authenticated)
    clientAnon = SupabaseClient(localSupabaseUrl, localAnonKey, authOptions: authOptions);
    serviceAnon = ResearchPersistenceService.forClient(clientAnon);

    // Create and authenticate User A on clientA
    clientA = SupabaseClient(localSupabaseUrl, localAnonKey, authOptions: authOptions);
    final resA = await clientA.auth.signUp(
      email: emailUserA,
      password: testPassword,
    );
    expect(resA.user, isNotNull, reason: 'User A sign-up failed');
    serviceA = ResearchPersistenceService.forClient(clientA);

    // Create and authenticate User B on clientB
    clientB = SupabaseClient(localSupabaseUrl, localAnonKey, authOptions: authOptions);
    final resB = await clientB.auth.signUp(
      email: emailUserB,
      password: testPassword,
    );
    expect(resB.user, isNotNull, reason: 'User B sign-up failed');
    serviceB = ResearchPersistenceService.forClient(clientB);
  });

  tearDownAll(() async {
    try {
      await clientA.auth.signOut();
      await clientB.auth.signOut();
    } catch (_) {}
  });

  group('E2E Research Persistence: Multi-Tenant Isolation & Flow Verification', () {
    String? userAConvId;

    test('1. User A creates a research conversation', () async {
      userAConvId = await serviceA.getOrCreateConversation(
        title: 'Sleep quality and magnesium glycinate bioavailability',
      );

      expect(userAConvId, isNotNull);
      expect(userAConvId!.isNotEmpty, isTrue);
    });

    test('2. User A persists inquiry and structured answer atomically', () async {
      expect(userAConvId, isNotNull);

      final dummyAnswer = ResearchAnswer(
        query: 'Sleep quality and magnesium glycinate bioavailability',
        evidenceBadge: 'RCT REVIEW • GRADE A (SYSTEMATIC EVIDENCE)',
        answerSummary: 'Magnesium bisglycinate crosses the blood-brain barrier effectively.',
        generatedAt: DateTime.now(),
        citations: const [
          ResearchCitation(
            title: 'Oral magnesium supplementation for insomnia in older adults',
            authorsOrJournal: 'Sleep Medicine Reviews',
            year: '2023',
            pmid: '23853635',
            evidenceGrade: 'A',
          ),
        ],
        practicalSteps: const [
          'Take 200mg elemental magnesium bisglycinate 45 minutes prior to sleep',
        ],
        uncertaintyDisclaimer: 'Individual response varies with baseline serum magnesium levels.',
      );

      final success = await serviceA.persistInquiryAndAnswer(
        conversationId: userAConvId!,
        query: dummyAnswer.query,
        answer: dummyAnswer,
      );

      expect(success, isTrue);
    });

    test('3. User A retrieves their own conversation and messages', () async {
      final conversations = await serviceA.loadRecentConversations();
      expect(conversations.any((c) => c['id'] == userAConvId), isTrue);

      final messages = await serviceA.loadConversationMessages(userAConvId!);
      expect(messages.length, equals(2));
      expect(messages[0]['is_user'], isTrue);
      expect(messages[1]['is_user'], isFalse);
    });

    test('4. User B cannot see User A conversation or messages (Tenant Isolation)', () async {
      final bConversations = await serviceB.loadRecentConversations();
      expect(bConversations.any((c) => c['id'] == userAConvId), isFalse);

      final bMessages = await serviceB.loadConversationMessages(userAConvId!);
      expect(bMessages, isEmpty, reason: 'User B must not read User A messages');
    });

    test('5. User B cannot insert messages into User A conversation', () async {
      final maliciousAnswer = ResearchAnswer(
        query: 'Malicious injection into User A thread',
        evidenceBadge: 'UNVERIFIED',
        answerSummary: 'Injected response',
        generatedAt: DateTime.now(),
        citations: const [],
        practicalSteps: const [],
        uncertaintyDisclaimer: 'None',
      );

      final injected = await serviceB.persistInquiryAndAnswer(
        conversationId: userAConvId!,
        query: 'Malicious injection attempt',
        answer: maliciousAnswer,
      );

      expect(injected, isFalse, reason: 'Cross-conversation insertion must fail');
    });

    test('6. Anonymous / unauthenticated client cannot read or write', () async {
      final anonConversations = await serviceAnon.loadRecentConversations();
      expect(anonConversations, isEmpty);

      final anonMessages = await serviceAnon.loadConversationMessages(userAConvId!);
      expect(anonMessages, isEmpty);

      final anonConv = await serviceAnon.getOrCreateConversation(title: 'Anonymous inquiry');
      expect(anonConv, isNull);
    });

    test('7. Retrying a save with existing conversation ID avoids duplicate conversations', () async {
      final existingId = await serviceA.getOrCreateConversation(
        conversationId: userAConvId,
        title: 'New query title',
      );

      expect(existingId, equals(userAConvId));
    });

    test('8. User A deletes conversation with cascading message deletion', () async {
      final deleted = await serviceA.deleteConversation(userAConvId!);
      expect(deleted, isTrue);

      final conversations = await serviceA.loadRecentConversations();
      expect(conversations.any((c) => c['id'] == userAConvId), isFalse);

      final messages = await serviceA.loadConversationMessages(userAConvId!);
      expect(messages, isEmpty);
    });
  });
}
