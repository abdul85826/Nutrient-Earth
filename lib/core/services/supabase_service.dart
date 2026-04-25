import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithGoogle() async {
    // Supabase handles Google OAuth by redirecting to a provider URL
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.example.nutrientearth://login-callback/',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── DATABASE (users table) ────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  Future<void> upsertUserProfile(Map<String, dynamic> data) async {
    await _client.from('users').upsert(data);
  }

  // ─── STORAGE ───────────────────────────────────────────────────────────────

  Future<String?> uploadReport(String uid, File file, String fileName) async {
    final path = 'reports/$uid/$fileName';
    await _client.storage.from('reports').upload(path, file);
    return _client.storage.from('reports').getPublicUrl(path);
  }

  // ─── EDGE FUNCTIONS ────────────────────────────────────────────────────────

  Future<String> getAIInsight(Map<String, dynamic> body) async {
    try {
      final response = await _client.functions.invoke(
        'aiInsight',
        body: body,
      );
      return response.data['insight'] ?? 'No insight available';
    } catch (e) {
      return 'Error generating insight';
    }
  }
}
