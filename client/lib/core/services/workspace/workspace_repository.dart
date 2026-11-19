// ==============================================================================
// Nutrient Earth — Workspace Repository Service
// Powers the Intelligence Workspace:
// - Conversation History & Autosave
// - Research Projects & Groupings
// - Saved Intelligence Bookmarks
// - Universal Cross-Entity Search
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/workspace/workspace_models.dart';

abstract class WorkspaceRepository {
  // Conversations
  Future<List<WorkspaceConversation>> getConversations({
    required String userId,
    String? projectId,
    bool includeArchived = false,
  });

  Future<WorkspaceConversation> createConversation({
    required String userId,
    required String title,
    String? projectId,
  });

  Future<void> updateConversation({
    required String conversationId,
    String? title,
    String? projectId,
    bool? isPinned,
    bool? isArchived,
  });

  Future<void> deleteConversation(String conversationId);

  // Projects
  Future<List<WorkspaceProject>> getProjects({
    required String userId,
    bool includeArchived = false,
  });

  Future<WorkspaceProject> createProject({
    required String userId,
    required String name,
    String? description,
    String colorHex = '#00251D',
  });

  Future<void> updateProject({
    required String projectId,
    String? name,
    String? description,
    String? colorHex,
    bool? isArchived,
  });

  Future<void> deleteProject(String projectId);

  // Saved Intelligence
  Future<List<WorkspaceSavedItem>> getSavedItems({
    required String userId,
    String? projectId,
    SavedItemType? type,
  });

  Future<WorkspaceSavedItem> saveItem(WorkspaceSavedItem item);

  Future<void> deleteSavedItem(String itemId);

  // Universal Search
  Future<List<UniversalSearchResult>> searchEverything({
    required String userId,
    required String query,
    int limit = 20,
  });
}

class SupabaseWorkspaceRepository implements WorkspaceRepository {
  final SupabaseClient? _client;

  // Local fallback caches
  final Map<String, List<WorkspaceConversation>> _conversationsCache = {};
  final Map<String, List<WorkspaceProject>> _projectsCache = {};
  final Map<String, List<WorkspaceSavedItem>> _savedItemsCache = {};

  SupabaseWorkspaceRepository({SupabaseClient? client})
      : _client = client;

  SupabaseClient? get _effectiveClient => _client ?? SupabaseConfig.client;

  // ----------------------------------------------------------------------------
  // Conversations
  // ----------------------------------------------------------------------------
  @override
  Future<List<WorkspaceConversation>> getConversations({
    required String userId,
    String? projectId,
    bool includeArchived = false,
  }) async {
    final client = _effectiveClient;
    if (client != null) {
      try {
        var q = client
            .from('ai_conversations')
            .select()
            .eq('user_id', userId);

        if (!includeArchived) {
          q = q.eq('is_archived', false);
        }
        if (projectId != null) {
          q = q.eq('project_id', projectId);
        }

        final List<dynamic> res = await q
            .order('is_pinned', ascending: false)
            .order('updated_at', ascending: false);

        final items = res
            .map((r) => WorkspaceConversation.fromJson(r as Map<String, dynamic>))
            .toList();

        _conversationsCache[userId] = items;
        return items;
      } catch (e) {
        debugPrint('[WorkspaceRepo] getConversations fallback: $e');
      }
    }

    var cached = _conversationsCache[userId] ?? [];
    if (!includeArchived) {
      cached = cached.where((c) => !c.isArchived).toList();
    }
    if (projectId != null) {
      cached = cached.where((c) => c.projectId == projectId).toList();
    }
    return cached;
  }

  @override
  Future<WorkspaceConversation> createConversation({
    required String userId,
    required String title,
    String? projectId,
  }) async {
    final item = WorkspaceConversation.create(
      userId: userId,
      title: title,
      projectId: projectId,
    );

    _conversationsCache.putIfAbsent(userId, () => []).insert(0, item);

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('ai_conversations').insert(item.toJson());
      } catch (e) {
        debugPrint('[WorkspaceRepo] createConversation DB notice: $e');
      }
    }

    return item;
  }

  @override
  Future<void> updateConversation({
    required String conversationId,
    String? title,
    String? projectId,
    bool? isPinned,
    bool? isArchived,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (title != null) updates['title'] = title;
    if (projectId != null) updates['project_id'] = projectId;
    if (isPinned != null) updates['is_pinned'] = isPinned;
    if (isArchived != null) updates['is_archived'] = isArchived;

    // Update local cache
    for (final list in _conversationsCache.values) {
      final idx = list.indexWhere((c) => c.id == conversationId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          title: title,
          projectId: projectId,
          isPinned: isPinned,
          isArchived: isArchived,
          updatedAt: DateTime.now().toUtc(),
        );
      }
    }

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('ai_conversations').update(updates).eq('id', conversationId);
      } catch (e) {
        debugPrint('[WorkspaceRepo] updateConversation DB notice: $e');
      }
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    for (final list in _conversationsCache.values) {
      list.removeWhere((c) => c.id == conversationId);
    }

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('ai_conversations').delete().eq('id', conversationId);
      } catch (e) {
        debugPrint('[WorkspaceRepo] deleteConversation DB notice: $e');
      }
    }
  }

  // ----------------------------------------------------------------------------
  // Projects
  // ----------------------------------------------------------------------------
  @override
  Future<List<WorkspaceProject>> getProjects({
    required String userId,
    bool includeArchived = false,
  }) async {
    final client = _effectiveClient;
    if (client != null) {
      try {
        var q = client
            .from('workspace_projects')
            .select()
            .eq('user_id', userId);

        if (!includeArchived) {
          q = q.eq('is_archived', false);
        }

        final List<dynamic> res = await q.order('updated_at', ascending: false);
        final items = res
            .map((r) => WorkspaceProject.fromJson(r as Map<String, dynamic>))
            .toList();

        _projectsCache[userId] = items;
        return items;
      } catch (e) {
        debugPrint('[WorkspaceRepo] getProjects fallback: $e');
      }
    }

    var cached = _projectsCache[userId] ?? [];
    if (!includeArchived) {
      cached = cached.where((p) => !p.isArchived).toList();
    }
    return cached;
  }

  @override
  Future<WorkspaceProject> createProject({
    required String userId,
    required String name,
    String? description,
    String colorHex = '#00251D',
  }) async {
    final item = WorkspaceProject.create(
      userId: userId,
      name: name,
      description: description,
      colorHex: colorHex,
    );

    _projectsCache.putIfAbsent(userId, () => []).insert(0, item);

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('workspace_projects').insert(item.toJson());
      } catch (e) {
        debugPrint('[WorkspaceRepo] createProject DB notice: $e');
      }
    }

    return item;
  }

  @override
  Future<void> updateProject({
    required String projectId,
    String? name,
    String? description,
    String? colorHex,
    bool? isArchived,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (colorHex != null) updates['color_hex'] = colorHex;
    if (isArchived != null) updates['is_archived'] = isArchived;

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('workspace_projects').update(updates).eq('id', projectId);
      } catch (e) {
        debugPrint('[WorkspaceRepo] updateProject DB notice: $e');
      }
    }
  }

  @override
  Future<void> deleteProject(String projectId) async {
    for (final list in _projectsCache.values) {
      list.removeWhere((p) => p.id == projectId);
    }

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('workspace_projects').delete().eq('id', projectId);
      } catch (e) {
        debugPrint('[WorkspaceRepo] deleteProject DB notice: $e');
      }
    }
  }

  // ----------------------------------------------------------------------------
  // Saved Intelligence
  // ----------------------------------------------------------------------------
  @override
  Future<List<WorkspaceSavedItem>> getSavedItems({
    required String userId,
    String? projectId,
    SavedItemType? type,
  }) async {
    final client = _effectiveClient;
    if (client != null) {
      try {
        var q = client
            .from('workspace_saved_items')
            .select()
            .eq('user_id', userId);

        if (projectId != null) {
          q = q.eq('project_id', projectId);
        }
        if (type != null) {
          q = q.eq('item_type', type.value);
        }

        final List<dynamic> res = await q.order('created_at', ascending: false);
        final items = res
            .map((r) => WorkspaceSavedItem.fromJson(r as Map<String, dynamic>))
            .toList();

        _savedItemsCache[userId] = items;
        return items;
      } catch (e) {
        debugPrint('[WorkspaceRepo] getSavedItems fallback: $e');
      }
    }

    var cached = _savedItemsCache[userId] ?? [];
    if (projectId != null) {
      cached = cached.where((s) => s.projectId == projectId).toList();
    }
    if (type != null) {
      cached = cached.where((s) => s.itemType == type).toList();
    }
    return cached;
  }

  @override
  Future<WorkspaceSavedItem> saveItem(WorkspaceSavedItem item) async {
    _savedItemsCache.putIfAbsent(item.userId, () => []).insert(0, item);

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('workspace_saved_items').insert(item.toJson());
      } catch (e) {
        debugPrint('[WorkspaceRepo] saveItem DB notice: $e');
      }
    }

    return item;
  }

  @override
  Future<void> deleteSavedItem(String itemId) async {
    for (final list in _savedItemsCache.values) {
      list.removeWhere((s) => s.id == itemId);
    }

    final client = _effectiveClient;
    if (client != null) {
      try {
        await client.from('workspace_saved_items').delete().eq('id', itemId);
      } catch (e) {
        debugPrint('[WorkspaceRepo] deleteSavedItem DB notice: $e');
      }
    }
  }

  // ----------------------------------------------------------------------------
  // Universal Cross-Entity Search
  // ----------------------------------------------------------------------------
  @override
  Future<List<UniversalSearchResult>> searchEverything({
    required String userId,
    required String query,
    int limit = 20,
  }) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];

    final results = <UniversalSearchResult>[];

    // Search local conversation titles
    final convs = _conversationsCache[userId] ?? [];
    for (final c in convs) {
      if (c.title.toLowerCase().contains(clean)) {
        results.add(UniversalSearchResult(
          id: 'res-conv-${c.id}',
          title: c.title,
          snippet: 'Conversation created on ${c.createdAt.toIso8601String().split("T").first}',
          sourceType: SearchResultSourceType.conversation,
          entityId: c.id,
          createdAt: c.createdAt,
        ));
      }
    }

    // Search local projects
    final projects = _projectsCache[userId] ?? [];
    for (final p in projects) {
      if (p.name.toLowerCase().contains(clean) ||
          (p.description != null && p.description!.toLowerCase().contains(clean))) {
        results.add(UniversalSearchResult(
          id: 'res-proj-${p.id}',
          title: p.name,
          snippet: p.description ?? 'Research project workspace',
          sourceType: SearchResultSourceType.project,
          entityId: p.id,
          createdAt: p.createdAt,
        ));
      }
    }

    // Search local saved items
    final saved = _savedItemsCache[userId] ?? [];
    for (final s in saved) {
      if (s.title.toLowerCase().contains(clean) ||
          s.contentSnippet.toLowerCase().contains(clean)) {
        results.add(UniversalSearchResult(
          id: 'res-saved-${s.id}',
          title: s.title,
          snippet: s.contentSnippet,
          sourceType: SearchResultSourceType.savedItem,
          entityId: s.id,
          createdAt: s.createdAt,
        ));
      }
    }

    return results.take(limit).toList();
  }
}

// ------------------------------------------------------------------------------
// Riverpod Providers
// ------------------------------------------------------------------------------
final workspaceRepositoryProvider = Provider<WorkspaceRepository>((ref) {
  return SupabaseWorkspaceRepository();
});

final userConversationsProvider = FutureProvider.family<List<WorkspaceConversation>, String>((ref, userId) async {
  final repo = ref.watch(workspaceRepositoryProvider);
  return repo.getConversations(userId: userId);
});

final userProjectsProvider = FutureProvider.family<List<WorkspaceProject>, String>((ref, userId) async {
  final repo = ref.watch(workspaceRepositoryProvider);
  return repo.getProjects(userId: userId);
});

final userSavedItemsProvider = FutureProvider.family<List<WorkspaceSavedItem>, String>((ref, userId) async {
  final repo = ref.watch(workspaceRepositoryProvider);
  return repo.getSavedItems(userId: userId);
});
