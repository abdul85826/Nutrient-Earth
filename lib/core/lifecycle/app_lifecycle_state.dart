enum AppStartupState {
  booting,
  unauthenticated,
  authenticatedNoProfile,
  onboarding,
  profileIncomplete,
  ready,
  error,
}

enum OnboardingStep {
  bodyProblems,
  lifestyleFactors,
  permissions,
  biologicalProfile,
  goals,
  environmentSync,
  completed
}

class AppLifecycleState {
  final bool isLoggedIn;
  final bool isNewUser;
  final OnboardingStep onboardingStep;
  final bool isProfileComplete;
  final bool isPermissionsComplete;
  final bool isAssistantInitialized;
  final bool isEnvironmentSynced;
  final bool isAlphaConsented;
  final AppStartupState startupState;
  final String? error;

  AppLifecycleState({
    this.isLoggedIn = false,
    this.isNewUser = false,
    this.onboardingStep = OnboardingStep.bodyProblems,
    this.isProfileComplete = false,
    this.isPermissionsComplete = false,
    this.isAssistantInitialized = false,
    this.isEnvironmentSynced = false,
    this.isAlphaConsented = false,
    this.startupState = AppStartupState.booting,
    this.error,
  });

  AppLifecycleState copyWith({
    bool? isLoggedIn,
    bool? isNewUser,
    OnboardingStep? onboardingStep,
    bool? isProfileComplete,
    bool? isPermissionsComplete,
    bool? isAssistantInitialized,
    bool? isEnvironmentSynced,
    bool? isAlphaConsented,
    AppStartupState? startupState,
    String? error,
  }) {
    return AppLifecycleState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isNewUser: isNewUser ?? this.isNewUser,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isPermissionsComplete: isPermissionsComplete ?? this.isPermissionsComplete,
      isAssistantInitialized: isAssistantInitialized ?? this.isAssistantInitialized,
      isEnvironmentSynced: isEnvironmentSynced ?? this.isEnvironmentSynced,
      isAlphaConsented: isAlphaConsented ?? this.isAlphaConsented,
      startupState: startupState ?? this.startupState,
      error: error ?? this.error,
    );
  }

  bool get isFullyInitialized =>
      isLoggedIn &&
      isProfileComplete &&
      isPermissionsComplete &&
      isEnvironmentSynced &&
      onboardingStep == OnboardingStep.completed;
}
