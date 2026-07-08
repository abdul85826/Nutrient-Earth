import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_lifecycle_state.dart';
import '../services/permissions_service.dart';
import '../services/supabase_service.dart';
import '../models/app_models.dart';
import '../providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bootstrap/identity_manager.dart';
import '../providers/biological_profile_provider.dart';
import '../services/observation_engine.dart';
import '../services/local_storage_service.dart';

class AppLifecycleNotifier extends StateNotifier<AppLifecycleState> {
  final Ref _ref;
  final SupabaseService _supabase = SupabaseService();
  StreamSubscription<AuthState>? _authSubscription;

  AppLifecycleNotifier(this._ref) : super(AppLifecycleState()) {
    _init();
  }

  bool _isInitializing = false;

  void _init() {
    print("🚀 BOOT PHASE START: Waiting for session restoration...");
    
    // 1. Setup Auth Listener for future events
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      print("🔔 AUTH EVENT: ${data.event} | Session: ${session != null}");
      
      if (data.event == AuthChangeEvent.signedIn && session != null) {
        print("SIGNED IN SUCCESSFULLY: Forcing initialization");
        state = state.copyWith(isLoggedIn: true);
        
        final provider = session.user.appMetadata['provider'] ?? 'google';
        
        // Ensure user row exists in public.users
        await _supabase.ensureUserRecordExists(
          session.user.id, 
          session.user.email ?? '', 
          authProvider: provider,
        );
        
        final guestUserId = IdentityManager().currentUuid;
        final cloudUserId = session.user.id;
        
        if (IdentityManager().isGuest && guestUserId != cloudUserId) {
          print("🔄 Guest-to-cloud migration triggered! Migrating data from $guestUserId to $cloudUserId...");
          final localStorage = LocalStorageService();
          await localStorage.migrateGuestData(guestUserId, cloudUserId);
          await IdentityManager().upgradeToCloudIdentity(cloudUserId);
        } else {
          await IdentityManager().upgradeToCloudIdentity(cloudUserId);
        }

        // Log biological/system event about auth upgrade
        try {
          await ObservationEngine().logEvent(
            eventType: 'auth_provider_linked',
            payload: {
              'provider': provider,
              'user_id': cloudUserId,
              'migrated_from_guest': guestUserId != cloudUserId,
            },
            source: 'system_auth',
          );
        } catch (e) {
          print("⚠️ Failed to log auth event: $e");
        }
        
        _ref.invalidate(healthIdentityProvider);
        _ref.invalidate(appUserProvider);

        handleAuthenticatedUser(session.user);
      }
      
      if (session == null && data.event == AuthChangeEvent.signedOut) {
        state = state.copyWith(
          isLoggedIn: false, 
          startupState: AppStartupState.unauthenticated,
          isProfileComplete: false,
        );
      }
    });

    // 2. Start Boot Sequence
    _bootSequence();
  }

  Future<void> _bootSequence() async {
    try {
      // 2-3 second delay for Web session restoration race conditions
      await Future.delayed(const Duration(seconds: 2));
      
      // If auth listener or deep link already triggered initialization, skip
      if (state.startupState == AppStartupState.booting ||
          state.startupState == AppStartupState.ready ||
          state.startupState == AppStartupState.profileIncomplete ||
          state.startupState == AppStartupState.onboarding) {
        print("💎 BOOT SEQUENCE: Initialization already handled by auth listener. Skipping.");
        return;
      }
      
      final session = Supabase.instance.client.auth.currentSession;
      print("💎 BOOT SEQUENCE: Session restored -> ${session != null}");

      if (session != null) {
        state = state.copyWith(isLoggedIn: true);
        await initializeApp();
      } else {
        // If session is null, check if we have a local guest mode stored!
        final prefs = await SharedPreferences.getInstance();
        final mode = prefs.getString('ne_auth_mode');
        if (mode == 'guest') {
          state = state.copyWith(isLoggedIn: true);
          await initializeApp();
        } else {
          state = state.copyWith(
            isLoggedIn: false,
            startupState: AppStartupState.unauthenticated,
          );
        }
      }
    } catch (e) {
      print("🔥 BOOT ERROR: $e");
      state = state.copyWith(startupState: AppStartupState.error, error: e.toString());
    }
  }

  void handleAuthenticatedUser(User user) {
    if (!state.isLoggedIn || state.startupState == AppStartupState.unauthenticated) {
      state = state.copyWith(isLoggedIn: true);
      initializeApp();
    }
  }

  Future<void> initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;
    
    print("🚀 INIT START: Nutrient Earth AuthStateMachine Transition");
    
    try {
      state = state.copyWith(startupState: AppStartupState.booting, error: null);

      // 1. Check Auth Session or Guest Mode
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;
      final isGuest = IdentityManager().isGuest;

      if (user == null && !isGuest) {
        state = state.copyWith(
          isLoggedIn: false,
          startupState: AppStartupState.unauthenticated,
        );
        return;
      }

      state = state.copyWith(isLoggedIn: true);

      // Ensure user row exists in public.users for cloud user
      if (!isGuest && user != null) {
        final provider = user.appMetadata['provider'] ?? 'google';
        await _supabase.ensureUserRecordExists(
          user.id, 
          user.email ?? '', 
          authProvider: provider,
        );
      }

      // 2. Fetch Profile Data (Retry logic included in service)
      final userId = IdentityManager().currentUuid;
      HealthIdentity? healthId;

      if (isGuest) {
        final localData = await readHealthIdentityFromIsar(userId);
        if (localData != null) {
          healthId = HealthIdentity.fromMap(localData);
        }
      } else {
        // Authenticated Cloud User
        try {
          final appUser = await _supabase.getAppUser(userId).timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw TimeoutException("Biological Profile fetch timed out (5s)"),
          );
          healthId = appUser?.healthIdentity;
        } catch (e) {
          print("⚠️ Supabase getAppUser failed, falling back to local Isar: $e");
          final localData = await readHealthIdentityFromIsar(userId);
          if (localData != null) {
            healthId = HealthIdentity.fromMap(localData);
          } else {
            // General error during fetch (e.g. network) and no local profile
            state = state.copyWith(startupState: AppStartupState.error, error: "Database Connection Error: $e");
            return;
          }
        }
        
        // Fallback to local profile if cloud profile fetch returned null
        if (healthId == null) {
          print("ℹ️ Cloud profile was null, falling back to local Isar for $userId");
          final localData = await readHealthIdentityFromIsar(userId);
          if (localData != null) {
            healthId = HealthIdentity.fromMap(localData);
          }
        }
      }

      // 3. Evaluate Profile State
      if (healthId == null) {
        // Authenticated but no record in 'users' table or local profile
        state = state.copyWith(startupState: AppStartupState.onboarding);
        return;
      }

      // 4. Check Completeness (Real Detection)
      if (!healthId.isComplete) {
        print("⚠️ PROFILE INCOMPLETE: Required biological fields missing.");
        state = state.copyWith(
          startupState: AppStartupState.profileIncomplete,
          isProfileComplete: false,
        );
        return;
      }

      // 5. Alpha Consent Check
      final prefs = await SharedPreferences.getInstance();
      final bool alphaConsented = prefs.getBool('has_alpha_consent') ?? false;

      // 6. Ready Phase (Environment & Permissions)
      print("🛡️ PERMISSIONS: Checking Final Sync");
      final hasLocation = await PermissionsService.checkLocationPermission();
      
      state = state.copyWith(
        isProfileComplete: true,
        isPermissionsComplete: hasLocation,
        isAssistantInitialized: true,
        isAlphaConsented: alphaConsented,
        startupState: AppStartupState.ready,
      );
      
      print("💎 READY: AuthStateMachine -> READY");

      print("✅ INIT COMPLETE: Transitioning to -> ${state.startupState}");

    } catch (e) {
      print("💥 CRITICAL INIT ERROR: $e");
      state = state.copyWith(startupState: AppStartupState.error, error: e.toString());
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> acceptAlphaConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_alpha_consent', true);
    state = state.copyWith(isAlphaConsented: true);
  }

  OnboardingStep _mapIntToStep(int? step) {
    if (step == null) return OnboardingStep.bodyProblems;
    if (step >= OnboardingStep.values.length) return OnboardingStep.completed;
    return OnboardingStep.values[step];
  }

  Future<void> completeStep(OnboardingStep step) async {
    final userId = IdentityManager().currentUuid;
    final nextIndex = step.index + 1;
    state = state.copyWith(onboardingStep: _mapIntToStep(nextIndex));
    
    try {
      await _supabase.updateOnboardingStep(userId, nextIndex);
    } catch (e) {
      print("⚠️ Onboarding step update to Supabase failed (offline or guest): $e");
    }
    
    if (nextIndex >= OnboardingStep.values.length - 1) {
       try {
         await _supabase.completeProfile(userId);
       } catch (e) {
         print("⚠️ Profile completion to Supabase failed (offline or guest): $e");
       }
       _ref.invalidate(appUserProvider); // Refresh profile data
       state = state.copyWith(isProfileComplete: true, onboardingStep: OnboardingStep.completed);
    }
  }

  void devBypass() {
    print("🛠️ DEV BYPASS TRIGGERED: Forcing UI to Ready State");
    state = state.copyWith(
      isLoggedIn: true,
      startupState: AppStartupState.ready,
      isProfileComplete: true,
      isPermissionsComplete: true,
      isAssistantInitialized: true,
    );
  }

  Future<void> signOut() async {
    print("🚪 SIGN OUT TRIGGERED: Clearing session and guest preferences");
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ne_auth_mode');
    await prefs.remove('ne_device_uuid');
    
    // Reset Identity
    await IdentityManager().initialize();
    
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (_) {}
    
    state = state.copyWith(
      isLoggedIn: false,
      startupState: AppStartupState.unauthenticated,
      isProfileComplete: false,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final appLifecycleProvider = StateNotifierProvider<AppLifecycleNotifier, AppLifecycleState>((ref) {
  return AppLifecycleNotifier(ref);
});
