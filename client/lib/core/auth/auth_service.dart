import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthUser, AuthState;
import 'auth_state.dart';
import 'auth_user.dart';

class AuthService extends StateNotifier<AuthState> {
  final SupabaseClient? _supabaseClient;
  StreamSubscription<AuthState>? _sub;

  AuthService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient,
      super(const AuthInitial()) {
    _initialize();
  }

  void _initialize() {
    try {
      final client = _supabaseClient ?? _safeGetSupabase();
      if (client != null) {
        final session = client.auth.currentSession;
        final user = client.auth.currentUser;
        if (session != null && user != null) {
          state = Authenticated(
            AuthUser(
              id: user.id,
              email: user.email,
              displayName:
                  (user.userMetadata?['full_name'] ??
                          user.userMetadata?['name'] ??
                          user.email?.split('@').first)
                      as String?,
              photoUrl:
                  (user.userMetadata?['avatar_url'] ??
                          user.userMetadata?['picture'])
                      as String?,
              createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
            ),
          );
        } else {
          state = const Unauthenticated();
        }

        // Listen for live Supabase auth state changes
        client.auth.onAuthStateChange.listen((data) {
          final session = data.session;
          final user = session?.user;
          if (user != null) {
            state = Authenticated(
              AuthUser(
                id: user.id,
                email: user.email,
                displayName:
                    (user.userMetadata?['full_name'] ??
                            user.userMetadata?['name'] ??
                            user.email?.split('@').first)
                        as String?,
                photoUrl:
                    (user.userMetadata?['avatar_url'] ??
                            user.userMetadata?['picture'])
                        as String?,
                createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
              ),
            );
          } else if (state is! Authenticated ||
              !(state as Authenticated).user.isGuest) {
            state = const Unauthenticated();
          }
        });
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      debugPrint('[AuthService] Supabase not initialized or offline: $e');
      state = const Unauthenticated();
    }
  }

  static SupabaseClient? _safeGetSupabase() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthLoading('Connecting with Google...');
    try {
      final client = _supabaseClient ?? _safeGetSupabase();
      if (client == null) {
        throw Exception(
          'Supabase client is not available. Please verify connection.',
        );
      }

      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'com.nutrientearth.app://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      if (!success) {
        state = const AuthError('Could not launch Google Sign-In.');
      }
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In error: $e');
      state = AuthError('Google Sign-In failed: ${e.toString()}');
    }
  }

  void signInAsGuest() {
    final guestUser = AuthUser.guest();
    state = Authenticated(guestUser);
  }

  Future<void> signOut() async {
    state = const AuthLoading('Signing out...');
    try {
      final client = _supabaseClient ?? _safeGetSupabase();
      if (client != null) {
        await client.auth.signOut();
      }
    } catch (e) {
      debugPrint('[AuthService] Sign out error: $e');
    } finally {
      state = const Unauthenticated();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authServiceProvider = StateNotifierProvider<AuthService, AuthState>((
  ref,
) {
  return AuthService();
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authServiceProvider);
  return switch (authState) {
    Authenticated(:final user) => user,
    _ => null,
  };
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authServiceProvider);
  return authState is Authenticated;
});
