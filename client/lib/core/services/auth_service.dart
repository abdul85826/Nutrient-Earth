// ==============================================================================
// Nutrient Earth — Authentic Authentication Service
// Manages real Supabase sessions (Sign Up, Sign In, Sign Out).
// Strictly enforces zero mock bypasses for production authentication.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

abstract class AuthService {
  User? get currentUser;
  Session? get currentSession;
  bool get isAuthenticated;
  Future<AuthResponse> signUp({required String email, required String password});
  Future<AuthResponse> signIn({required String email, required String password});
  Future<bool> signInWithGoogle();
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;
}

class SupabaseAuthService implements AuthService {
  const SupabaseAuthService();

  @override
  User? get currentUser => SupabaseConfig.client?.auth.currentUser;

  @override
  Session? get currentSession => SupabaseConfig.client?.auth.currentSession;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<bool> signInWithGoogle() async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.nutrientearth.nutrient_earth_client://login-callback',
    );
  }

  @override
  Future<void> signOut() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      await client.auth.signOut();
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    final client = SupabaseConfig.client;
    if (client == null) {
      return const Stream.empty();
    }
    return client.auth.onAuthStateChange;
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return const SupabaseAuthService();
});

/// Reactive stream of auth state changes (sign-in, sign-out, token refresh)
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Current authenticated Supabase user (reactive to auth changes)
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateStreamProvider);
  return ref.watch(authServiceProvider).currentUser;
});

/// Boolean flag indicating active authenticated session
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});
