import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/user_state_engine.dart';
import '../config/body_platform_config.dart';
import '../models/body_state.dart';
import '../repositories/body_repository.dart';

final bodyRepositoryProvider = Provider<IBodyRepository>((ref) {
  if (BodyPlatformConfig.enableBiologyEngine) {
    return ProductionBodyRepository();
  }
  return MockBodyRepository();
});

class BodyController extends StateNotifier<BodyState> {
  final IBodyRepository _repository;
  final Ref _ref;

  BodyController(this._repository, this._ref) : super(const BodyLoading()) {
    _init();
  }

  void _init() {
    if (!BodyPlatformConfig.enableBiologyEngine) {
      // Biology engine is disabled. Load mock data directly and do NOT listen to live providers
      loadMockData();
      return;
    }

    // If biology is enabled, listen to live user state updates reactively
    _ref.listen<AsyncValue<Map<String, dynamic>?>>(userUnderstandingProvider, (prev, next) {
      next.when(
        data: (userState) => loadData(userState),
        loading: () => setLoading(),
        error: (err, _) => setError(err.toString()),
      );
    }, fireImmediately: true);
  }

  Future<void> loadMockData() async {
    try {
      state = const BodyLoading();
      final systems = await _repository.fetchSystems(null);
      if (systems.isEmpty) {
        state = const BodyEmpty();
      } else {
        state = BodyReady(systems);
      }
    } catch (e) {
      state = BodyError(e.toString());
    }
  }

  Future<void> loadData(Map<String, dynamic>? userState) async {
    try {
      final systems = await _repository.fetchSystems(userState);
      if (systems.isEmpty) {
        state = const BodyEmpty();
      } else {
        final currentState = state;
        if (currentState is BodyReady) {
          state = currentState.copyWith(systems: systems);
        } else {
          state = BodyReady(systems);
        }
      }
    } catch (e) {
      state = BodyError(e.toString());
    }
  }

  void setLoading() {
    state = const BodyLoading();
  }

  void setError(String message) {
    state = BodyError(message);
  }

  void setUnavailable(String reason) {
    state = BodyUnavailable(reason);
  }

  void selectSystem(String key) {
    final currentState = state;
    if (currentState is BodyReady) {
      if (currentState.selectedSystemKey == key) {
        state = currentState.copyWith(clearSelection: true);
      } else {
        state = currentState.copyWith(selectedSystemKey: key);
      }
    }
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is BodyReady) {
      state = currentState.copyWith(clearSelection: true);
    }
  }
}

final bodyControllerProvider = StateNotifierProvider<BodyController, BodyState>((ref) {
  final repo = ref.watch(bodyRepositoryProvider);
  return BodyController(repo, ref);
});

// Coordinates selection of specific anatomy or systems
class BodySelectionController extends StateNotifier<String?> {
  BodySelectionController() : super(null);

  void select(String? key) {
    state = key;
  }

  void clear() {
    state = null;
  }
}

final bodySelectionProvider = StateNotifierProvider<BodySelectionController, String?>((ref) {
  return BodySelectionController();
});
