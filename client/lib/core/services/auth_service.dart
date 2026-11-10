// ==============================================================================
// Nutrient Earth — Authentic Authentication Service
// Manages real Supabase sessions (Sign Up, Sign In, Sign Out, Password Recovery, Google OAuth).
// Strictly enforces zero mock bypasses for production authentication.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';

abstract class AuthService {
  User? get currentUser;
  Session? get currentSession;
  bool get isAuthenticated;
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  });
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });
  Future<void> signInWithOtp({
    required String email,
    String? redirectTo,
    String? captchaToken,
  });
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
    String? captchaToken,
  });
  Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.email,
    String? captchaToken,
  });
  Future<bool> signInWithGoogle({String? redirectTo});
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code);
  Future<void> signOut();
  Future<void> resetPasswordForEmail({required String email, String? redirectTo});
  Future<UserResponse> updatePassword({required String newPassword});
  Stream<AuthState> get authStateChanges;
}

class SupabaseAuthService implements AuthService {
  final GoogleSignIn? _googleSignIn;

  const SupabaseAuthService({GoogleSignIn? googleSignIn}) : _googleSignIn = googleSignIn;

  @override
  User? get currentUser => SupabaseConfig.client?.auth.currentUser;

  @override
  Session? get currentSession => SupabaseConfig.client?.auth.currentSession;

  @override
  bool get isAuthenticated => currentUser != null && currentSession != null;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: data,
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
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  @override
  Future<void> signInWithOtp({
    required String email,
    String? redirectTo,
    String? captchaToken,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    final target = redirectTo ?? AppConfig.authCallbackUrl;
    await client.auth.signInWithOtp(
      email: email.trim().toLowerCase(),
      emailRedirectTo: target,
      captchaToken: captchaToken,
    );
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.verifyOTP(
      email: email.trim().toLowerCase(),
      token: token.trim(),
      type: type,
      captchaToken: captchaToken,
    );
  }

  @override
  Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    if (type == OtpType.signup || type == OtpType.emailChange) {
      await client.auth.resend(
        email: email.trim().toLowerCase(),
        type: type,
        captchaToken: captchaToken,
      );
    } else {
      await client.auth.signInWithOtp(
        email: email.trim().toLowerCase(),
        captchaToken: captchaToken,
      );
    }
  }

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }

    // 1. Web or non-mobile desktop platforms: Use browser OAuth redirect with PKCE & prompt=select_account
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      final target = redirectTo ?? AppConfig.authCallbackUrl;
      return client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: target,
        queryParams: const {
          'prompt': 'select_account',
          'access_type': 'offline',
        },
      );
    }

    // 2. Native Mobile (Android & iOS): Use native GoogleSignIn SDK + signInWithIdToken
    try {
      final serverClientId = AppConfig.googleWebClientId.isNotEmpty ? AppConfig.googleWebClientId : null;
      final clientId = defaultTargetPlatform == TargetPlatform.iOS && AppConfig.googleIosClientId.isNotEmpty
          ? AppConfig.googleIosClientId
          : null;

      final signInInstance = _googleSignIn ??
          GoogleSignIn(
            clientId: clientId,
            serverClientId: serverClientId,
            scopes: const ['email', 'profile', 'openid'],
          );

      // Force native account chooser to display every time by signing out cached session
      try {
        await signInInstance.signOut();
      } catch (_) {
        // Safe to ignore if not signed in previously
      }

      final googleUser = await signInInstance.signIn();
      if (googleUser == null) {
        // User explicitly cancelled or closed native bottom-sheet chooser
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Could not retrieve a valid ID token from Google Sign-In.');
      }

      final authResponse = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      return authResponse.session != null;
    } on AuthException {
      rethrow;
    } on PlatformException catch (pe) {
      if (pe.code == 'sign_in_canceled' ||
          pe.code == '12501' ||
          (pe.message?.toLowerCase().contains('cancel') ?? false)) {
        return false;
      }
      throw AuthException(pe.message ?? 'Native Google Sign-In failed on device.');
    } catch (e) {
      final str = e.toString().toLowerCase();
      if (str.contains('cancel') || str.contains('12501')) {
        return false;
      }
      throw AuthException('Native Google Sign-In failed: $e');
    }
  }

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.exchangeCodeForSession(code);
  }

  @override
  Future<void> signOut() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      await client.auth.signOut();
    }
    // Also disconnect native Google Sign-In session if active
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        final signInInstance = _googleSignIn ?? GoogleSignIn();
        await signInInstance.signOut();
      } catch (_) {
        // Best effort clean up
      }
    }
  }

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    final target = redirectTo ?? AppConfig.authCallbackUrl;
    await client.auth.resetPasswordForEmail(
      email.trim().toLowerCase(),
      redirectTo: target,
    );
  }

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async {
    final client = SupabaseConfig.client;
    if (client == null) {
      throw const AuthException('Authentication backend is offline or uninitialized.');
    }
    return client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
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
  final authService = ref.watch(authServiceProvider);
  return user != null && authService.isAuthenticated;
});
