import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/config/supabase_config.dart';
import 'package:nutrient_earth_client/core/services/auth_service.dart';
import 'package:nutrient_earth_client/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockBootAuthService implements AuthService {
  User? _user;
  Session? _session;
  final StreamController<AuthState> _authController = StreamController<AuthState>.broadcast();

  @override
  User? get currentUser => _user;

  @override
  Session? get currentSession => _session;

  @override
  bool get isAuthenticated => _user != null;

  @override
  Stream<AuthState> get authStateChanges => _authController.stream;

  @override
  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async =>
      AuthResponse(session: _session, user: _user);

  @override
  Future<AuthResponse> signIn({required String email, required String password}) async =>
      AuthResponse(session: _session, user: _user);

  @override
  Future<void> signInWithOtp({required String email, String? redirectTo, String? captchaToken}) async {}

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async => AuthResponse(session: _session, user: _user);

  @override
  Future<void> resendOtp({
    required String email,
    OtpType type = OtpType.email,
    String? captchaToken,
  }) async {}

  @override
  Future<bool> signInWithGoogle({String? redirectTo}) async => false;

  @override
  Future<AuthSessionUrlResponse> exchangeCodeForSession(String code) async =>
      AuthSessionUrlResponse(session: _session!, redirectType: 'web');

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPasswordForEmail({required String email, String? redirectTo}) async {}

  @override
  Future<UserResponse> updatePassword({required String newPassword}) async =>
      UserResponse.fromJson({'user': {}});
}

void main() {
  testWidgets('Full app main initialization test', (tester) async {
    dotenv.testLoad(fileInput: 'SUPABASE_URL=https://placeholder.supabase.co\nSUPABASE_ANON_KEY=placeholder-anon-key\n');
    await SupabaseConfig.initialize();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(_MockBootAuthService()),
        ],
        child: const NutrientEarthApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
