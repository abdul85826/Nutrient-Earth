import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_state.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/biological_profile_provider.dart';
import '../../../core/models/app_models.dart';
import '../../../core/bootstrap/identity_manager.dart';
import '../../../core/services/observation_engine.dart';

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final SupabaseService _supabase = SupabaseService();
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(OnboardingState());

  void updateStep2({
    String? name,
    int? age,
    String? sex,
    double? height,
    double? weight,
    String? country,
    String? city,
    String? occupation,
    String? goal,
  }) {
    state = state.copyWith(
      name: name ?? state.name,
      age: age ?? state.age,
      sex: sex ?? state.sex,
      height: height ?? state.height,
      weight: weight ?? state.weight,
      country: country ?? state.country,
      city: city ?? state.city,
      occupation: occupation ?? state.occupation,
      primaryGoal: goal ?? state.primaryGoal,
    );
    saveDraft();
  }

  void updateStep3({
    String? sleepTime,
    String? wakeTime,
    String? activityLevel,
    String? exercise,
    String? smoking,
    String? alcohol,
    int? stressLevel,
  }) {
    state = state.copyWith(
      sleepTime: sleepTime ?? state.sleepTime,
      wakeTime: wakeTime ?? state.wakeTime,
      activityLevel: activityLevel ?? state.activityLevel,
      exercise: exercise ?? state.exercise,
      smoking: smoking ?? state.smoking,
      alcohol: alcohol ?? state.alcohol,
      stressLevel: stressLevel ?? state.stressLevel,
    );
    saveDraft();
  }

  void updateStep4({
    String? dietPreference,
    double? waterIntake,
    String? mealTiming,
    List<String>? supplements,
  }) {
    state = state.copyWith(
      dietPreference: dietPreference ?? state.dietPreference,
      waterIntake: waterIntake ?? state.waterIntake,
      mealTiming: mealTiming ?? state.mealTiming,
      supplements: supplements ?? state.supplements,
    );
    saveDraft();
  }

  void updateStep5({
    bool? hasDiabetesRisk,
    bool? hasHeartDiseaseRisk,
    bool? hasCancerRisk,
    bool? hasThyroidRisk,
    bool? hasBloodPressureRisk,
  }) {
    state = state.copyWith(
      hasDiabetesRisk: hasDiabetesRisk ?? state.hasDiabetesRisk,
      hasHeartDiseaseRisk: hasHeartDiseaseRisk ?? state.hasHeartDiseaseRisk,
      hasCancerRisk: hasCancerRisk ?? state.hasCancerRisk,
      hasThyroidRisk: hasThyroidRisk ?? state.hasThyroidRisk,
      hasBloodPressureRisk: hasBloodPressureRisk ?? state.hasBloodPressureRisk,
    );
    saveDraft();
  }

  void setStep(int step) {
    state = state.copyWith(currentStep: step);
    saveDraft();
  }

  Future<void> saveDraft() async {
    final userId = IdentityManager().currentUuid;
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = jsonEncode({
        'step': state.currentStep,
        'data': state.toJson(),
      });
      await prefs.setString('ne_onboarding_draft_$userId', draftData);
      debugPrint('OnboardingNotifier: Local draft saved for $userId');

      if (!IdentityManager().isGuest) {
        await _supabase.saveOnboardingDraft(userId, state.currentStep, state.toJson());
      }
    } catch (e) {
      debugPrint('OnboardingNotifier: Silent draft save failure: $e');
    }
  }

  Future<void> loadDraft() async {
    final userId = IdentityManager().currentUuid;
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final localRaw = prefs.getString('ne_onboarding_draft_$userId');
      if (localRaw != null) {
        final decoded = jsonDecode(localRaw);
        state = OnboardingState.fromJson(decoded['data']).copyWith(
          currentStep: decoded['step'],
          isLoading: false,
        );
        debugPrint('OnboardingNotifier: Loaded draft from local SharedPreferences');
        return;
      }

      if (!IdentityManager().isGuest) {
        final draft = await _supabase.loadOnboardingDraft(userId);
        if (draft != null && draft['data'] != null) {
          state = OnboardingState.fromJson(draft['data']).copyWith(
            currentStep: draft['step'],
            isLoading: false,
          );
          await prefs.setString('ne_onboarding_draft_$userId', jsonEncode(draft));
          debugPrint('OnboardingNotifier: Loaded draft from Supabase');
        }
      }
    } catch (e) {
      debugPrint('OnboardingNotifier: Failed to load draft: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> finalizeOnboarding() async {
    final userId = IdentityManager().currentUuid;
    state = state.copyWith(isLoading: true);
    try {
      // 1. Construct HealthIdentity
      final healthIdentity = HealthIdentity(
        userId: userId,
        name: state.name,
        age: state.age,
        gender: state.sex,
        height: state.height,
        weight: state.weight,
        country: state.country,
        city: state.city,
        occupation: state.occupation,
        primaryGoal: state.primaryGoal,
        sleepTime: state.sleepTime,
        wakeTime: state.wakeTime,
        activityLevel: state.activityLevel,
        exercise: state.exercise,
        smoking: state.smoking,
        alcohol: state.alcohol,
        stressLevel: state.stressLevel,
        dietPreference: state.dietPreference,
        waterIntake: state.waterIntake,
        mealTiming: state.mealTiming,
        supplements: state.supplements,
        hasDiabetesRisk: state.hasDiabetesRisk,
        hasHeartDiseaseRisk: state.hasHeartDiseaseRisk,
        hasCancerRisk: state.hasCancerRisk,
        hasThyroidRisk: state.hasThyroidRisk,
        hasBloodPressureRisk: state.hasBloodPressureRisk,
        updatedAt: DateTime.now(),
      );

      // Save HealthIdentity to Isar
      await saveHealthIdentityToIsar(userId, healthIdentity.toMap());

      // Log biological profile creation event
      try {
        await ObservationEngine().logEvent(
          eventType: 'profile_updated',
          payload: {
            'age': state.age,
            'gender': state.sex,
            'weight': state.weight,
            'height': state.height,
            'primary_goal': state.primaryGoal,
          },
          source: 'user_profile_onboarding',
        );
      } catch (e) {
        debugPrint('OnboardingNotifier: Failed to log profile_updated event: $e');
      }

      // 2. Attempt Cloud Sync
      if (!IdentityManager().isGuest) {
        try {
          final email = _supabase.currentUser?.email ?? '';
          await _supabase.ensureUserRecordExists(userId, email);
        } catch (e) {
          debugPrint('OnboardingNotifier: ensureUserRecordExists failed: $e');
        }
      }

      try {
        await _supabase.upsertUserProfile(healthIdentity.toMap());
      } catch (e) {
        debugPrint('OnboardingNotifier: Cloud profile upsert failed (offline or guest): $e');
      }

      // Clear local onboarding draft on successful completion
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('ne_onboarding_draft_$userId');
        debugPrint('OnboardingNotifier: Local draft cleared for $userId');
      } catch (e) {
        debugPrint('OnboardingNotifier: Failed to clear local draft: $e');
      }

      // Force refresh of user profile providers so dashboard and GoRouter transition
      _ref.invalidate(healthIdentityProvider);
      _ref.invalidate(appUserProvider);

      return true;
    } catch (e) {
      debugPrint('OnboardingNotifier: Finalization failed: $e');
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier(ref);
});
