// ==============================================================================
// Nutrient Earth — Deterministic State Change Detection Model
// Compares live observations against personal baselines using robust statistical rules.
// Classifies changes without arbitrary LLM hallucinations.
// ==============================================================================

import 'package:uuid/uuid.dart';
import 'personal_baseline.dart';

enum ChangeClassification {
  normalVariation('normal_variation', 'Within individual historical range'),
  possibleChange('possible_change', 'Deviates from personal baseline; monitoring'),
  sustainedChange('sustained_change', 'Persistent statistically significant deviation'),
  dataQualityIssue('data_quality_issue', 'Implausible value or sensor anomaly detected'),
  insufficientData('insufficient_data', 'No established baseline available for comparison');

  final String value;
  final String label;

  const ChangeClassification(this.value, this.label);

  static ChangeClassification fromString(String val) {
    return ChangeClassification.values.firstWhere(
      (c) => c.value == val,
      orElse: () => ChangeClassification.insufficientData,
    );
  }
}

enum ChangeDirection {
  increased('increased'),
  decreased('decreased'),
  unchanged('unchanged'),
  divergent('divergent');

  final String value;

  const ChangeDirection(this.value);

  static ChangeDirection fromString(String val) {
    return ChangeDirection.values.firstWhere(
      (d) => d.value == val,
      orElse: () => ChangeDirection.unchanged,
    );
  }
}

class StateChangeDetection {
  final String id;
  final String userId;
  final String metricName;
  final ChangeClassification classification;
  final double? baselineReference;
  final double observedValue;
  final double? deviationPercent;
  final ChangeDirection direction;
  final String explanation;
  final DateTime detectedAt;

  const StateChangeDetection({
    required this.id,
    required this.userId,
    required this.metricName,
    required this.classification,
    this.baselineReference,
    required this.observedValue,
    this.deviationPercent,
    required this.direction,
    required this.explanation,
    required this.detectedAt,
  });

  /// Evaluates an observed value against an established PersonalBaseline deterministically.
  factory StateChangeDetection.evaluate({
    required String userId,
    required String metricName,
    required double observedValue,
    PersonalBaseline? baseline,
    double outlierThresholdMultiplier = 3.5,
  }) {
    final now = DateTime.now().toUtc();

    // 1. Check for missing or insufficient baseline
    if (baseline == null || baseline.status == BaselineStatus.insufficientData) {
      return StateChangeDetection(
        id: const Uuid().v4(),
        userId: userId,
        metricName: metricName,
        classification: ChangeClassification.insufficientData,
        observedValue: observedValue,
        direction: ChangeDirection.unchanged,
        explanation: 'No personal baseline established yet (requires ${PersonalBaseline.minSamplesRequired}+ observations).',
        detectedAt: now,
      );
    }

    final baseVal = baseline.baselineValue;
    final stdDev = baseline.standardDeviation ?? 0.0;

    // 2. Outlier / Sensor Artifact detection
    if (stdDev > 0 && (observedValue - baseVal).abs() > (outlierThresholdMultiplier * stdDev)) {
      return StateChangeDetection(
        id: const Uuid().v4(),
        userId: userId,
        metricName: metricName,
        classification: ChangeClassification.dataQualityIssue,
        baselineReference: baseVal,
        observedValue: observedValue,
        deviationPercent: double.parse((((observedValue - baseVal) / (baseVal == 0 ? 1 : baseVal)) * 100).toStringAsFixed(1)),
        direction: observedValue > baseVal ? ChangeDirection.increased : ChangeDirection.decreased,
        explanation: 'Extreme deviation detected (${(observedValue - baseVal).abs().toStringAsFixed(1)} vs baseline ${baseVal.toStringAsFixed(1)}). Potential device or sensor artifact.',
        detectedAt: now,
      );
    }

    // 3. Normal range check using 10th and 90th percentiles or 1.5 * stdDev
    final minBound = baseline.baselineMin ?? (baseVal - (1.5 * stdDev));
    final maxBound = baseline.baselineMax ?? (baseVal + (1.5 * stdDev));

    if (observedValue >= minBound && observedValue <= maxBound) {
      return StateChangeDetection(
        id: const Uuid().v4(),
        userId: userId,
        metricName: metricName,
        classification: ChangeClassification.normalVariation,
        baselineReference: baseVal,
        observedValue: observedValue,
        deviationPercent: 0.0,
        direction: ChangeDirection.unchanged,
        explanation: 'Observed value is within normal historical baseline (${minBound.toStringAsFixed(1)} - ${maxBound.toStringAsFixed(1)}).',
        detectedAt: now,
      );
    }

    // 4. Meaningful change detected
    final diff = observedValue - baseVal;
    final devPct = (baseVal != 0) ? ((diff / baseVal) * 100) : 0.0;
    final dir = diff > 0 ? ChangeDirection.increased : ChangeDirection.decreased;

    final isSignificant = devPct.abs() >= 20.0 || (stdDev > 0 && diff.abs() >= (2.0 * stdDev));
    final classification = isSignificant
        ? ChangeClassification.sustainedChange
        : ChangeClassification.possibleChange;

    final explanation = isSignificant
        ? 'Significant ${dir.value} of ${devPct.abs().toStringAsFixed(1)}% compared to established baseline (${baseVal.toStringAsFixed(1)}).'
        : 'Noticeable ${dir.value} of ${devPct.abs().toStringAsFixed(1)}% compared to typical baseline (${baseVal.toStringAsFixed(1)}).';

    return StateChangeDetection(
      id: const Uuid().v4(),
      userId: userId,
      metricName: metricName,
      classification: classification,
      baselineReference: baseVal,
      observedValue: observedValue,
      deviationPercent: double.parse(devPct.toStringAsFixed(1)),
      direction: dir,
      explanation: explanation,
      detectedAt: now,
    );
  }

  factory StateChangeDetection.fromJson(Map<String, dynamic> json) {
    return StateChangeDetection(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      metricName: json['metric_name'] as String? ?? '',
      classification: ChangeClassification.fromString(
        json['classification'] as String? ?? '',
      ),
      baselineReference: (json['baseline_reference'] as num?)?.toDouble(),
      observedValue: (json['observed_value'] as num?)?.toDouble() ?? 0.0,
      deviationPercent: (json['deviation_percent'] as num?)?.toDouble(),
      direction: ChangeDirection.fromString(
        json['direction'] as String? ?? '',
      ),
      explanation: json['explanation'] as String? ?? '',
      detectedAt: DateTime.tryParse(json['detected_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'metric_name': metricName,
      'classification': classification.value,
      if (baselineReference != null) 'baseline_reference': baselineReference,
      'observed_value': observedValue,
      if (deviationPercent != null) 'deviation_percent': deviationPercent,
      'direction': direction.value,
      'explanation': explanation,
      'detected_at': detectedAt.toIso8601String(),
    };
  }
}
