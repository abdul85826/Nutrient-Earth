import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/intelligence/intelligence_contracts.dart';
import '../../../core/intelligence/intelligence_orchestrator.dart';
import '../../../core/network/environmental_service.dart';

@immutable
class ResearchState {
  final bool isLoading;
  final String? currentQuery;
  final Uint8List? capturedImageBytes;
  final String? pastedUrl;
  final AnswerPlan? currentAnswerPlan;
  final String? errorMessage;
  final bool isSpeaking;

  const ResearchState({
    this.isLoading = false,
    this.currentQuery,
    this.capturedImageBytes,
    this.pastedUrl,
    this.currentAnswerPlan,
    this.errorMessage,
    this.isSpeaking = false,
  });

  ResearchState copyWith({
    bool? isLoading,
    String? currentQuery,
    Uint8List? capturedImageBytes,
    String? pastedUrl,
    AnswerPlan? currentAnswerPlan,
    String? errorMessage,
    bool? isSpeaking,
  }) {
    return ResearchState(
      isLoading: isLoading ?? this.isLoading,
      currentQuery: currentQuery ?? this.currentQuery,
      capturedImageBytes: capturedImageBytes ?? this.capturedImageBytes,
      pastedUrl: pastedUrl ?? this.pastedUrl,
      currentAnswerPlan: currentAnswerPlan ?? this.currentAnswerPlan,
      errorMessage: errorMessage,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }
}

class ResearchNotifier extends StateNotifier<ResearchState> {
  final IntelligenceOrchestrator _orchestrator;
  final Ref _ref;

  ResearchNotifier(this._orchestrator, this._ref) : super(const ResearchState());

  void setCapturedImage(Uint8List bytes) {
    state = state.copyWith(capturedImageBytes: bytes);
  }

  void clearCapturedImage() {
    state = state.copyWith(capturedImageBytes: null);
  }

  void setPastedUrl(String url) {
    state = state.copyWith(pastedUrl: url);
  }

  void toggleSpeech() {
    state = state.copyWith(isSpeaking: !state.isSpeaking);
  }

  Future<void> executeResearch(String query, {QueryInputType inputType = QueryInputType.text}) async {
    if (query.trim().isEmpty && state.capturedImageBytes == null) return;

    state = state.copyWith(
      isLoading: true,
      currentQuery: query,
      errorMessage: null,
    );

    try {
      final env = await _ref.read(ambientEnvironmentalProvider.future);
      final task = AgentTask(
        id: const Uuid().v4(),
        query: query.isNotEmpty ? query : 'Image Analysis & Nutritional Verification',
        inputType: inputType,
        imageBytes: state.capturedImageBytes,
        url: state.pastedUrl,
        timestamp: DateTime.now(),
      );

      final plan = await _orchestrator.orchestrate(task, environmentalContext: env);

      state = state.copyWith(
        isLoading: false,
        currentAnswerPlan: plan,
      );
    } catch (e) {
      debugPrint('[ResearchNotifier] Research execution error: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to complete research synthesis: ${e.toString()}',
      );
    }
  }
}

final researchProvider = StateNotifierProvider<ResearchNotifier, ResearchState>((ref) {
  final orchestrator = ref.watch(intelligenceOrchestratorProvider);
  return ResearchNotifier(orchestrator, ref);
});
