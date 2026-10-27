// ==============================================================================
// Nutrient Earth — Research Persistence Service
// Manages durable storage of research inquiries and structured answers in Supabase
// tables (public.ai_conversations and public.ai_messages) enforcing Row Level Security.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'research_pipeline_service.dart';

class ResearchPersistenceService {
  ResearchPersistenceService._({SupabaseClient? client}) : _customClient = client;

  final SupabaseClient? _customClient;

  static final ResearchPersistenceService instance = ResearchPersistenceService._();

  /// Testing factory allowing dependency injection of a specific authenticated Supabase client.
  @visibleForTesting
  factory ResearchPersistenceService.forClient(SupabaseClient client) =>
      ResearchPersistenceService._(client: client);

  SupabaseClient? get _client => _customClient ?? SupabaseConfig.client;

  /// Creates a new conversation or retrieves the active conversation ID.
  /// If unauthenticated or offline, gracefully returns null without crashing.
  Future<String?> getOrCreateConversation({
    String? conversationId,
    required String title,
  }) async {
    final client = _client;
    if (client == null) return null;

    final user = client.auth.currentUser;
    if (user == null) return null;

    try {
      if (conversationId != null && conversationId.trim().isNotEmpty) {
        return conversationId;
      }

      final insertResponse = await client.from('ai_conversations').insert({
        'user_id': user.id,
        'title': title.length > 80 ? '${title.substring(0, 77)}...' : title,
      }).select('id').single();

      return insertResponse['id'] as String?;
    } catch (_) {
      // Gracefully handle persistence errors (e.g. offline, network disconnect)
      return null;
    }
  }

  /// Persists a user query message and the generated ResearchAnswer message in public.ai_messages.
  /// Enforces RLS with the authenticated user's uid.
  Future<bool> persistInquiryAndAnswer({
    required String conversationId,
    required String query,
    required ResearchAnswer answer,
  }) async {
    final client = _client;
    if (client == null) return false;

    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      // 1. Insert user query and AI answer messages atomically in a single statement
      final sourcesJson = answer.citations.map((c) => c.toJson()).toList();

      await client.from('ai_messages').insert([
        {
          'conversation_id': conversationId,
          'user_id': user.id,
          'is_user': true,
          'content': query,
        },
        {
          'conversation_id': conversationId,
          'user_id': user.id,
          'is_user': false,
          'content': answer.answerSummary,
          'sources': sourcesJson,
          'evidence_quality': answer.evidenceBadge,
          'uncertainty': answer.uncertaintyDisclaimer,
          'practical_next_steps': answer.practicalSteps,
          'missing_information_questions': answer.evidenceGap != null ? [answer.evidenceGap!] : [],
        },
      ]);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Loads recent research conversation summaries for the authenticated user.
  Future<List<Map<String, dynamic>>> loadRecentConversations({int limit = 15}) async {
    final client = _client;
    if (client == null) return const [];

    final user = client.auth.currentUser;
    if (user == null) return const [];

    try {
      final data = await client
          .from('ai_conversations')
          .select('id, title, created_at')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return const [];
    }
  }

  /// Loads messages for an active conversation owned by the authenticated user.
  Future<List<Map<String, dynamic>>> loadConversationMessages(String conversationId) async {
    final client = _client;
    if (client == null) return const [];

    final user = client.auth.currentUser;
    if (user == null) return const [];

    try {
      final data = await client
          .from('ai_messages')
          .select()
          .eq('conversation_id', conversationId)
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return const [];
    }
  }

  /// Deletes a conversation owned by the authenticated user.
  /// Due to ON DELETE CASCADE on the composite foreign key, associated messages are automatically deleted.
  Future<bool> deleteConversation(String conversationId) async {
    final client = _client;
    if (client == null) return false;

    final user = client.auth.currentUser;
    if (user == null) return false;

    try {
      await client
          .from('ai_conversations')
          .delete()
          .eq('id', conversationId)
          .eq('user_id', user.id);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final researchPersistenceServiceProvider = Provider<ResearchPersistenceService>((ref) {
  return ResearchPersistenceService.instance;
});
