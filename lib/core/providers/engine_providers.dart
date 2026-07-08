import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/observation_engine.dart';
import '../services/baseline_engine.dart';
import '../services/local_storage_service.dart';
import '../bootstrap/identity_manager.dart';

final observationEngineProvider = Provider<ObservationEngine>((ref) {
  return ObservationEngine();
});

final baselineEngineProvider = Provider<BaselineEngine>((ref) {
  return BaselineEngine();
});

// A future provider for the timeline that reads from local storage
final observationTimelineProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = IdentityManager().currentUuid;
  if (userId.isEmpty) return [];
  return LocalStorageService().readBiologicalEvents(userId);
});

// A future provider for the baseline state that calculates baseline from the timeline
final baselineStateProvider = FutureProvider<BaselineState>((ref) async {
  final timeline = await ref.watch(observationTimelineProvider.future);
  final engine = ref.watch(baselineEngineProvider);
  return engine.calculateBaseline(timeline);
});
