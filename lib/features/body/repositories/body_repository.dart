import 'package:flutter/material.dart';
import '../config/body_platform_config.dart';
import '../models/body_state.dart';

abstract class IBodyRepository {
  Future<List<BodySystem>> fetchSystems(Map<String, dynamic>? userState);
}

class MockBodyRepository implements IBodyRepository {
  @override
  Future<List<BodySystem>> fetchSystems(Map<String, dynamic>? userState) async {
    // Return mock static anatomy reference data
    return [
      const BodySystem(
        key: 'nervous',
        name: 'Nervous System',
        score: 0.80,
        icon: Icons.psychology,
        description: 'Governs autonomic recovery, stress responses, and cognitive restoration.',
        metrics: [
          'Sleep Quality: 80%',
          'Stress Resilience: 75%',
        ],
        recommendations: [
          'Maintain consistent sleep and wake times to regulate circadian rhythms.',
          'Consider mindfulness exercises to modulate autonomic nervous system activity.',
        ],
      ),
      const BodySystem(
        key: 'cardiovascular',
        name: 'Cardiovascular System',
        score: 0.85,
        icon: Icons.favorite,
        description: 'Manages oxygen delivery, blood flow, and metabolic waste clearance.',
        metrics: [
          'Resting Heart Rate: 68 bpm (Optimal)',
          'Estimated HRV: High (Good)',
        ],
        recommendations: [
          'Engage in 20-30 minutes of low-intensity aerobic activity to sustain stroke volume.',
        ],
      ),
      const BodySystem(
        key: 'respiratory',
        name: 'Respiratory System',
        score: 0.90,
        icon: Icons.air,
        description: 'Coordinates gas exchange, oxygenation of tissues, and cellular respiration.',
        metrics: [
          'Blood Oxygenation: 98% (Optimal)',
          'Local Air Quality Index: Good',
        ],
        recommendations: [
          'Practice deep breathing intervals when working in closed environments.',
        ],
      ),
      const BodySystem(
        key: 'digestive',
        name: 'Digestive System',
        score: 0.70,
        icon: Icons.restaurant,
        description: 'Processes nutrient assimilation, metabolic flux, and energy storage.',
        metrics: [
          'Energy Balance: 70%',
          'Hydration Sufficiency: High',
        ],
        recommendations: [
          'Sustain steady hydration depth before meals to facilitate enzyme secretion.',
        ],
      ),
      const BodySystem(
        key: 'musculoskeletal',
        name: 'Musculoskeletal System',
        score: 0.75,
        icon: Icons.directions_run,
        description: 'Supports structural integrity, locomotion, and mechanical workload.',
        metrics: [
          'Daily Activity Level: Light',
          'Structural Strain: Low',
        ],
        recommendations: [
          'Take brief standing and mobility breaks every 90 minutes of desk work.',
        ],
      ),
    ];
  }
}

class ProductionBodyRepository implements IBodyRepository {
  final IBodyRepository _mockFallback = MockBodyRepository();

  @override
  Future<List<BodySystem>> fetchSystems(Map<String, dynamic>? userState) async {
    if (!BodyPlatformConfig.enableBiologyEngine) {
      // Fallback to mock directly if biology is disabled
      return _mockFallback.fetchSystems(userState);
    }

    // Simulate database query latency
    await Future.delayed(const Duration(milliseconds: 100));

    double getScore(String key, double fallback) {
      if (userState == null) return fallback;
      final val = userState[key];
      if (val == null) return fallback;
      if (val is num) return (val / 10.0).clamp(0.0, 1.0);
      return fallback;
    }

    return [
      BodySystem(
        key: 'nervous',
        name: 'Nervous System',
        score: getScore('sleep_quality', 0.7) * 0.5 + (1.0 - getScore('stress_level', 0.4)) * 0.5,
        icon: Icons.psychology,
        description: 'Governs autonomic recovery, stress responses, and cognitive restoration.',
        metrics: [
          'Sleep Quality: ${(getScore('sleep_quality', 0.7) * 100).toInt()}%',
          'Stress Resilience: ${(100 - getScore('stress_level', 0.4) * 100).toInt()}%',
        ],
        recommendations: [
          'Maintain consistent sleep and wake times to regulate circadian rhythms.',
          'Consider mindfulness exercises to modulate autonomic nervous system activity.',
        ],
      ),
      const BodySystem(
        key: 'cardiovascular',
        name: 'Cardiovascular System',
        score: 0.85,
        icon: Icons.favorite,
        description: 'Manages oxygen delivery, blood flow, and metabolic waste clearance.',
        metrics: [
          'Resting Heart Rate: 68 bpm (Optimal)',
          'Estimated HRV: High (Good)',
        ],
        recommendations: [
          'Engage in 20-30 minutes of low-intensity aerobic activity to sustain stroke volume.',
        ],
      ),
      const BodySystem(
        key: 'respiratory',
        name: 'Respiratory System',
        score: 0.90,
        icon: Icons.air,
        description: 'Coordinates gas exchange, oxygenation of tissues, and cellular respiration.',
        metrics: [
          'Blood Oxygenation: 98% (Optimal)',
          'Local Air Quality Index: Good',
        ],
        recommendations: [
          'Practice deep breathing intervals when working in closed environments.',
        ],
      ),
      BodySystem(
        key: 'digestive',
        name: 'Digestive System',
        score: getScore('energy_level', 0.6),
        icon: Icons.restaurant,
        description: 'Processes nutrient assimilation, metabolic flux, and energy storage.',
        metrics: [
          'Energy Balance: ${(getScore('energy_level', 0.6) * 100).toInt()}%',
          'Hydration Sufficiency: High',
        ],
        recommendations: [
          'Sustain steady hydration depth before meals to facilitate enzyme secretion.',
        ],
      ),
      const BodySystem(
        key: 'musculoskeletal',
        name: 'Musculoskeletal System',
        score: 0.75,
        icon: Icons.directions_run,
        description: 'Supports structural integrity, locomotion, and mechanical workload.',
        metrics: [
          'Daily Activity Level: Light',
          'Structural Strain: Low',
        ],
        recommendations: [
          'Take brief standing and mobility breaks every 90 minutes of desk work.',
        ],
      ),
    ];
  }
}
