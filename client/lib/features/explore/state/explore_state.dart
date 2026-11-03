// ==============================================================================
// Nutrient Earth — Explore / Research State Management
// Riverpod state notifier managing active inquiry, progressive 10-stage execution,
// evidence caching, history, and cryptographic proof verification.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/blockchain/blockchain_anchor_provider.dart';
import '../../../core/domain/blockchain/evidence_integrity_service.dart';
import '../../../core/services/profile_repository.dart';
import '../../../core/services/research_persistence_service.dart';
import '../../../core/services/research_pipeline_service.dart';

class ExploreState {
  final String searchQuery;
  final bool isSearching;
  final String currentStage;
  final ResearchAnswer? activeAnswer;
  final String selectedCategory;
  final String? errorMessage;
  final List<Map<String, dynamic>> recentHistory;
  final bool isVerifyingProof;
  final ProofVerificationResult? proofVerificationResult;
  final bool isBookmarked;

  const ExploreState({
    this.searchQuery = '',
    this.isSearching = false,
    this.currentStage = '',
    this.activeAnswer,
    this.selectedCategory = 'All',
    this.errorMessage,
    this.recentHistory = const [],
    this.isVerifyingProof = false,
    this.proofVerificationResult,
    this.isBookmarked = false,
  });

  ExploreState copyWith({
    String? searchQuery,
    bool? isSearching,
    String? currentStage,
    ResearchAnswer? activeAnswer,
    bool clearActiveAnswer = false,
    String? selectedCategory,
    String? errorMessage,
    bool clearErrorMessage = false,
    List<Map<String, dynamic>>? recentHistory,
    bool? isVerifyingProof,
    ProofVerificationResult? proofVerificationResult,
    bool clearProofResult = false,
    bool? isBookmarked,
  }) {
    return ExploreState(
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      currentStage: currentStage ?? this.currentStage,
      activeAnswer: clearActiveAnswer ? null : (activeAnswer ?? this.activeAnswer),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      recentHistory: recentHistory ?? this.recentHistory,
      isVerifyingProof: isVerifyingProof ?? this.isVerifyingProof,
      proofVerificationResult: clearProofResult ? null : (proofVerificationResult ?? this.proofVerificationResult),
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class ExploreNotifier extends StateNotifier<ExploreState> {
  final ProfileRepository _profileRepo;
  final ResearchPersistenceService _persistenceService;
  final EvidenceIntegrityService _integrityService;

  ExploreNotifier({
    ProfileRepository? profileRepo,
    ResearchPersistenceService? persistenceService,
    EvidenceIntegrityService? integrityService,
  })  : _profileRepo = profileRepo ?? const SupabaseProfileRepository(),
        _persistenceService = persistenceService ?? ResearchPersistenceService.instance,
        _integrityService = integrityService ?? EvidenceIntegrityService(),
        super(const ExploreState()) {
    loadRecentHistory();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void clearActiveAnswer() {
    state = state.copyWith(
      clearActiveAnswer: true,
      clearProofResult: true,
      searchQuery: '',
      clearErrorMessage: true,
    );
  }

  void toggleBookmark() {
    state = state.copyWith(isBookmarked: !state.isBookmarked);
  }

  Future<void> loadRecentHistory() async {
    final history = await _persistenceService.loadRecentConversations(limit: 10);
    if (mounted) {
      state = state.copyWith(recentHistory: history);
    }
  }

  Future<void> submitInquiry(String rawQuery, {String? imagePath, String? audioPath}) async {
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(
      searchQuery: trimmed,
      isSearching: true,
      currentStage: 'Validating scientific query & security constraints...',
      clearActiveAnswer: true,
      clearErrorMessage: true,
      clearProofResult: true,
    );

    try {
      // Step 1: User context retrieval
      state = state.copyWith(currentStage: 'Retrieving authorized user health context...');
      final userProfile = await _profileRepo.getCurrentUserProfile();

      // Step 2: Scientific evidence synthesis & pipeline
      state = state.copyWith(currentStage: 'Retrieving peer-reviewed clinical literature & RCTs...');
      final answer = await ResearchPipelineService.processInquiry(
        query: trimmed,
        imagePath: imagePath,
        audioPath: audioPath,
        userProfile: userProfile,
      );

      // Step 3: Persistence to Supabase
      state = state.copyWith(currentStage: 'Finalizing cryptographic provenance commitment...');
      final convId = await _persistenceService.getOrCreateConversation(title: trimmed);
      if (convId != null) {
        await _persistenceService.persistInquiryAndAnswer(
          conversationId: convId,
          query: trimmed,
          answer: answer,
        );
      }

      await loadRecentHistory();

      if (mounted) {
        state = state.copyWith(
          isSearching: false,
          currentStage: '',
          activeAnswer: answer,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isSearching: false,
          currentStage: '',
          errorMessage: 'Research inquiry could not be completed: $e',
        );
      }
    }
  }

  Future<void> verifyProof() async {
    final dossier = state.activeAnswer?.provenanceDossier;
    if (dossier == null) return;

    state = state.copyWith(isVerifyingProof: true, clearProofResult: true);

    try {
      final result = await _integrityService.verifyDossier(dossier);
      if (mounted) {
        state = state.copyWith(
          isVerifyingProof: false,
          proofVerificationResult: result,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isVerifyingProof: false,
          proofVerificationResult: ProofVerificationResult(
            isValid: false,
            merkleRootMatches: false,
            manifestHashMatches: false,
            onChainConfirmation: false,
            details: 'Verification error: $e',
          ),
        );
      }
    }
  }
}

final exploreStateProvider = StateNotifierProvider<ExploreNotifier, ExploreState>((ref) {
  return ExploreNotifier(
    profileRepo: ref.watch(profileRepositoryProvider),
    persistenceService: ref.watch(researchPersistenceServiceProvider),
    integrityService: ref.watch(evidenceIntegrityServiceProvider),
  );
});
