import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthUser, AuthState;
import 'auth_state.dart';
import 'auth_user.dart';

class AuthService extends StateNotifier<AuthState> {
  final SupabaseClient? _supabaseClient;
  StreamSubscription<dynamic>? _authSubscription;

  AuthService({SupabaseClient? supabaseClient})
    : _supabaseClient = supabaseClient,
      super(const AuthInitial()) {
    _initialize();
  }

  void _initialize() {
    try {
      // Check for OAuth error query parameters on web startup
      if (kIsWeb) {
        final queryParams = Uri.base.queryParameters;
        if (queryParams.containsKey('error') ||
            queryParams.containsKey('error_description')) {
          final errorDesc =
              queryParams['error_description'] ??
              queryParams['error'] ??
              'Sign-in was canceled or denied.';
          state = AuthError('Google Sign-In: $errorDesc');
          return;
        }
      }

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

        // Listen for live Supabase auth state changes with deduplication
        _authSubscription = client.auth.onAuthStateChange.listen(
          (data) {
            final session = data.session;
            final user = session?.user;
            if (user != null) {
              // Prevent duplicate state transitions if already authenticated as this user
              if (state is Authenticated &&
                  (state as Authenticated).user.id == user.id &&
                  !(state as Authenticated).user.isGuest) {
                return;
              }
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
                  createdAt:
                      DateTime.tryParse(user.createdAt) ?? DateTime.now(),
                ),
              );
            } else if (state is! Authenticated ||
                !(state as Authenticated).user.isGuest) {
              state = const Unauthenticated();
            }
          },
          onError: (Object err) {
            debugPrint(
              '[AuthService] Auth state stream error: ${err.runtimeType}',
            );
            if (state is! Authenticated) {
              state = const AuthError('Authentication connection interrupted.');
            }
          },
        );
      } else {
        state = const Unauthenticated();
      }
    } catch (e) {
      debugPrint(
        '[AuthService] Supabase initialization check: ${e.runtimeType}',
      );
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

  /// Resolves the canonical redirect URI for OAuth authentication.
  /// On Web: Uses the active browser origin (e.g. http://localhost:5656/ or production domain).
  /// On Native (iOS/Android): Uses the verified app deep-link scheme.
  static String resolveRedirectUri({bool isWeb = kIsWeb, String? origin}) {
    if (isWeb) {
      final base =
          origin ?? (kIsWeb ? Uri.base.origin : 'http://localhost:5656');
      return base.endsWith('/') ? base : '$base/';
    }
    return 'com.nutrientearth.app://login-callback';
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

      final redirectUri = resolveRedirectUri();

      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUri,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      if (!success) {
        state = const AuthError('Could not launch Google Sign-In.');
      }
    } catch (e) {
      debugPrint(
        '[AuthService] Google Sign-In encountered an error: ${e.runtimeType}',
      );
      state = const AuthError('Google Sign-In failed. Please try again.');
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
      debugPrint('[AuthService] Sign out note: ${e.runtimeType}');
    } finally {
      state = const Unauthenticated();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
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
