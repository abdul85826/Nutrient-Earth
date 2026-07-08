import 'package:flutter/material.dart';

class BodySystem {
  final String key;
  final String name;
  final double score; // 0.0 to 1.0
  final IconData icon;
  final String description;
  final List<String> metrics;
  final List<String> recommendations;

  const BodySystem({
    required this.key,
    required this.name,
    required this.score,
    required this.icon,
    required this.description,
    required this.metrics,
    required this.recommendations,
  });
}

sealed class BodyState {
  const BodyState();
}

class BodyLoading extends BodyState {
  const BodyLoading();
}

class BodyEmpty extends BodyState {
  const BodyEmpty();
}

class BodyError extends BodyState {
  final String message;
  const BodyError(this.message);
}

class BodyReady extends BodyState {
  final List<BodySystem> systems;
  final String? selectedSystemKey;

  const BodyReady(this.systems, {this.selectedSystemKey});

  BodyReady copyWith({
    List<BodySystem>? systems,
    String? selectedSystemKey,
    bool clearSelection = false,
  }) {
    return BodyReady(
      systems ?? this.systems,
      selectedSystemKey: clearSelection ? null : (selectedSystemKey ?? this.selectedSystemKey),
    );
  }
}

class BodyUnavailable extends BodyState {
  final String message;
  const BodyUnavailable(this.message);
}
