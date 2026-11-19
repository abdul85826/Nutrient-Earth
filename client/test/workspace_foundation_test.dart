// ==============================================================================
// Nutrient Earth — Intelligence Workspace Foundation Test Suite
// Verifies:
// 1. WorkspaceConversation domain model & serialization
// 2. WorkspaceProject organization & domain model
// 3. WorkspaceSavedItem intelligence bookmarks
// 4. Universal Cross-Entity Search Engine
// 5. WorkspaceRepository CRUD operations & offline cache
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/workspace/workspace_models.dart';
import 'package:nutrient_earth_client/core/services/workspace/workspace_repository.dart';

void main() {
  const testUserId = 'workspace-test-user-001';

  group('1. Workspace Conversation Model', () {
    test('Creates conversation and verifies initial states', () {
      final conv = WorkspaceConversation.create(
        userId: testUserId,
        title: 'Metabolic & Fiber Optimization',
      );

      expect(conv.userId, equals(testUserId));
      expect(conv.title, equals('Metabolic & Fiber Optimization'));
      expect(conv.isPinned, isFalse);
      expect(conv.isArchived, isFalse);
      expect(conv.projectId, isNull);
    });

    test('Serializes to and from JSON preserving pin and archive status', () {
      final original = WorkspaceConversation.create(
        userId: testUserId,
        title: 'Sleep Architecture Review',
        projectId: 'proj-123',
      ).copyWith(isPinned: true);

      final json = original.toJson();
      final restored = WorkspaceConversation.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.title, equals('Sleep Architecture Review'));
      expect(restored.projectId, equals('proj-123'));
      expect(restored.isPinned, isTrue);
      expect(restored.isArchived, isFalse);
    });
  });

  group('2. Research Projects & Groupings', () {
    test('Creates and serializes research workspace project', () {
      final project = WorkspaceProject.create(
        userId: testUserId,
        name: 'Herbal Adaptogens Investigation',
        description: 'Examining clinical evidence for Ashwagandha and Rhodiola Rosea',
        colorHex: '#166534',
      );

      expect(project.name, equals('Herbal Adaptogens Investigation'));
      expect(project.colorHex, equals('#166534'));
      expect(project.isArchived, isFalse);

      final json = project.toJson();
      final restored = WorkspaceProject.fromJson(json);

      expect(restored.name, equals(project.name));
      expect(restored.description, equals(project.description));
      expect(restored.colorHex, equals('#166534'));
    });
  });

  group('3. Saved Intelligence Bookmarks', () {
    test('Saves research finding with structured payload and source attribution', () {
      final saved = WorkspaceSavedItem.create(
        userId: testUserId,
        title: 'Magnesium Bisglycinate Sleep Latency',
        itemType: SavedItemType.researchPaper,
        contentSnippet: 'Double-blind RCT showing 17-minute reduction in sleep latency.',
        sourceReference: 'PMID: 35112345',
        payload: {'doseMg': 250, 'effectSize': 0.65},
      );

      expect(saved.itemType, equals(SavedItemType.researchPaper));
      expect(saved.sourceReference, equals('PMID: 35112345'));
      expect(saved.payload['doseMg'], equals(250));

      final json = saved.toJson();
      final restored = WorkspaceSavedItem.fromJson(json);

      expect(restored.title, equals(saved.title));
      expect(restored.contentSnippet, equals(saved.contentSnippet));
      expect(restored.itemType, equals(SavedItemType.researchPaper));
    });
  });

  group('4. Workspace Repository & Universal Search Integration', () {
    test('Performs cross-entity universal search across chats, projects, and saved items', () async {
      final repo = SupabaseWorkspaceRepository();

      // Seed local cache via repository methods
      final conv = await repo.createConversation(
        userId: testUserId,
        title: 'Understanding Vitamin D3 Bioavailability',
      );
      expect(conv.title, contains('Vitamin D3'));

      final proj = await repo.createProject(
        userId: testUserId,
        name: 'Vitamin D & Immune Protocol',
        description: 'Tracking optimal 25-OH serum levels',
      );
      expect(proj.name, contains('Vitamin D'));

      final saved = await repo.saveItem(WorkspaceSavedItem.create(
        userId: testUserId,
        title: 'Vitamin D Cholecalciferol vs Ergocalciferol',
        itemType: SavedItemType.answer,
        contentSnippet: 'D3 demonstrates 87% higher potency in raising serum 25-OH.',
      ));
      expect(saved.title, contains('Vitamin D'));

      // Universal search for "Vitamin D"
      final results = await repo.searchEverything(
        userId: testUserId,
        query: 'Vitamin D',
      );

      expect(results.length, greaterThanOrEqualTo(3));

      final sources = results.map((r) => r.sourceType).toSet();
      expect(sources, contains(SearchResultSourceType.conversation));
      expect(sources, contains(SearchResultSourceType.project));
      expect(sources, contains(SearchResultSourceType.savedItem));
    });

    test('Conversation update, pin, and delete lifecycle', () async {
      final repo = SupabaseWorkspaceRepository();

      final created = await repo.createConversation(
        userId: testUserId,
        title: 'Temporary Discussion',
      );

      // Pin
      await repo.updateConversation(
        conversationId: created.id,
        isPinned: true,
      );

      final listPinned = await repo.getConversations(userId: testUserId);
      final pinnedItem = listPinned.firstWhere((c) => c.id == created.id);
      expect(pinnedItem.isPinned, isTrue);

      // Delete
      await repo.deleteConversation(created.id);
      final listAfterDelete = await repo.getConversations(userId: testUserId);
      expect(listAfterDelete.any((c) => c.id == created.id), isFalse);
    });
  });
}
