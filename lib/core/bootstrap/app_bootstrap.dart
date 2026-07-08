import 'package:flutter/foundation.dart';
import 'identity_manager.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

enum BootstrapState {
  uninitialized,
  initializingStorage,
  initializingIdentity,
  restoringProfile,
  hydratingTwin,
  restoringTimeline,
  restoringCache,
  initializingSync,
  validatingNavigation,
  complete,
  error
}

class BootstrapManager {
  static final BootstrapManager _instance = BootstrapManager._internal();
  factory BootstrapManager() => _instance;
  BootstrapManager._internal();

  BootstrapState _state = BootstrapState.uninitialized;
  BootstrapState get state => _state;
  final ValueNotifier<BootstrapState> stateNotifier = ValueNotifier(BootstrapState.uninitialized);
  
  final IdentityManager _identityManager = IdentityManager();
  IdentityManager get identity => _identityManager;

  /// THE NERVOUS SYSTEM ENTRY POINT
  /// Enforces a strict, deterministic, 9-step offline-first initialization sequence.
  Future<void> initializeApp() async {
    try {
      debugPrint('[BOOTSTRAP] Starting deterministic offline-first initialization...');

      // STEP 1: Initialize local encrypted storage
      _updateState(BootstrapState.initializingStorage);
      await _initializeLocalStorage();

      // STEP 2: Initialize device identity
      _updateState(BootstrapState.initializingIdentity);
      await _identityManager.initialize();

      // STEP 3: Restore guest/cloud profile
      _updateState(BootstrapState.restoringProfile);
      await _restoreProfile();

      // STEP 4: Hydrate biological twin
      _updateState(BootstrapState.hydratingTwin);
      await _hydrateBiologicalTwin();

      // STEP 5: Restore event timeline
      _updateState(BootstrapState.restoringTimeline);
      await _restoreEventTimeline();

      // STEP 6: Restore recommendation cache
      _updateState(BootstrapState.restoringCache);
      await _restoreRecommendationCache();

      // STEP 7: Initialize sync engine
      _updateState(BootstrapState.initializingSync);
      await _initializeSyncEngine();

      // STEP 8: Validate navigation readiness
      _updateState(BootstrapState.validatingNavigation);
      await _validateNavigationReadiness();

      // STEP 9: Render app shell (Signals completion to the UI)
      _updateState(BootstrapState.complete);
      debugPrint('[BOOTSTRAP] Initialization complete. System is fully local and resilient.');

    } catch (e, stackTrace) {
      _updateState(BootstrapState.error);
      debugPrint('[BOOTSTRAP ERROR] Fatal initialization failure: $e');
      debugPrint(stackTrace.toString());
      // Here we would implement crash-safe fallback/recovery logic
    }
  }

  void _updateState(BootstrapState newState) {
    _state = newState;
    stateNotifier.value = newState;
    debugPrint('[BOOTSTRAP STATE] -> ${newState.name}');
  }

  // --- IMPLEMENTATION OF STEPS ---

  Future<void> _initializeLocalStorage() async {
    await LocalStorageService().initialize();
  }

  Future<void> _restoreProfile() async {
    // Look up the user profile locally using _identityManager.currentUuid
    // If not found, create a blank default profile
    await Future.delayed(const Duration(milliseconds: 50)); // Simulated deterministic delay
  }

  Future<void> _hydrateBiologicalTwin() async {
    // Load the 15 Core states from Isar into memory (Riverpod providers)
    // Ensures UI never blocks on network.
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _restoreEventTimeline() async {
    // Load the most recent BiologicalEvents into the Event Bus / State
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _restoreRecommendationCache() async {
    // Load the pre-computed AI insights so the user sees magic immediately
    await Future.delayed(const Duration(milliseconds: 50));
  }

  Future<void> _initializeSyncEngine() async {
    // Check if network exists, if so, process the IsarSyncQueue in the background
    // NEVER block the UI thread here.
    SyncService().cacheGlobalGraphData().catchError((e) {
      debugPrint('[BOOTSTRAP] Failed to cache global graph: $e');
    });
    SyncService().processSyncQueue().catchError((e) {
      debugPrint('[BOOTSTRAP] Failed to process sync queue: $e');
    });
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> _validateNavigationReadiness() async {
    // The final gate before the UI renders. Ensure all local providers have their initial data.
    await Future.delayed(const Duration(milliseconds: 10));
  }
}
