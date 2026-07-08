import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class MovementState {
  final int steps;
  final String status;
  final bool isAvailable;

  MovementState({
    required this.steps,
    required this.status,
    this.isAvailable = false,
  });

  factory MovementState.initial() => MovementState(steps: 0, status: 'stopped');
}

class MovementNotifier extends StateNotifier<MovementState> {
  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  MovementNotifier() : super(MovementState.initial()) {
    init();
  }

  Future<void> init() async {
    // Request permission for activity recognition (Android 10+)
    if (await Permission.activityRecognition.request().isGranted) {
      _startTracking();
    } else {
      print('❌ Activity Recognition permission denied');
    }
  }

  void _startTracking() {
    _stepCountSubscription = Pedometer.stepCountStream.listen((
      StepCount event,
    ) {
      state = MovementState(
        steps: event.steps,
        status: state.status,
        isAvailable: true,
      );
    }, onError: (error) => print('Pedo Error: $error'));

    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen((
      PedestrianStatus event,
    ) {
      state = MovementState(
        steps: state.steps,
        status: event.status,
        isAvailable: true,
      );
    }, onError: (error) => print('Pedo Status Error: $error'));
  }

  @override
  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    super.dispose();
  }
}

final movementProvider = StateNotifierProvider<MovementNotifier, MovementState>(
  (ref) {
    return MovementNotifier();
  },
);
