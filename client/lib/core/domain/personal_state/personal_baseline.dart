// ==============================================================================
// Nutrient Earth — Individual Personal Baseline Model
// Tracks established historical reference patterns and statistical confidence.
// Enforces minimum sample requirements before manufacturing baselines.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum BaselineStatus {
  insufficientData('insufficient_data', 'Fewer observations than minimum requirement'),
  provisional('provisional', 'Emerging pattern; below full statistical stability'),
  established('established', 'Statistically stable personalized baseline'),
  stale('stale', 'Baseline older than observation window without recent data');

  final String value;
  final String label;

  const BaselineStatus(this.value, this.label);

  static BaselineStatus fromString(String val) {
    return BaselineStatus.values.firstWhere(
      (s) => s.value == val,
      orElse: () => BaselineStatus.insufficientData,
    );
  }
}

class PersonalBaseline {
  final String id;
  final String userId;
  final String metricName;
  final double baselineValue;
  final double? baselineMin;
  final double? baselineMax;
  final double? standardDeviation;
  final String unit;
  final int sampleCount;
  final int windowDays;
  final DateTime windowStart;
  final DateTime windowEnd;
  final bool isWeekendSpecific;
  final double confidenceScore;
  final BaselineStatus status;
  final int algorithmVersion;
  final DateTime calculatedAt;

  const PersonalBaseline({
    required this.id,
    required this.userId,
    required this.metricName,
    required this.baselineValue,
    this.baselineMin,
    this.baselineMax,
    this.standardDeviation,
    required this.unit,
    required this.sampleCount,
    required this.windowDays,
    required this.windowStart,
    required this.windowEnd,
    this.isWeekendSpecific = false,
    required this.confidenceScore,
    required this.status,
    this.algorithmVersion = 1,
    required this.calculatedAt,
  });

  /// Minimum observations required to establish a valid baseline.
  static const int minSamplesRequired = 5;
  static const int establishedSamplesRequired = 14;

  /// Calculate a personal baseline from a list of numeric observation values.
  /// If samples < minSamplesRequired, marks status as insufficientData.
  factory PersonalBaseline.compute({
    required String userId,
    required String metricName,
    required List<double> values,
    required String unit,
    required DateTime windowStart,
    required DateTime windowEnd,
    int windowDays = 14,
    bool isWeekendSpecific = false,
  }) {
    final now = DateTime.now().toUtc();
    final count = values.length;

    if (count < minSamplesRequired || values.isEmpty) {
      return PersonalBaseline(
        id: const Uuid().v4(),
        userId: userId,
        metricName: metricName,
        baselineValue: values.isEmpty ? 0.0 : values.first,
        unit: unit,
        sampleCount: count,
        windowDays: windowDays,
        windowStart: windowStart,
        windowEnd: windowEnd,
        isWeekendSpecific: isWeekendSpecific,
        confidenceScore: 0.10,
        status: BaselineStatus.insufficientData,
        calculatedAt: now,
      );
    }

    // Sort to compute robust median and percentiles
    final sorted = List<double>.from(values)..sort();
    final median = count % 2 == 1
        ? sorted[count ~/ 2]
        : (sorted[(count ~/ 2) - 1] + sorted[count ~/ 2]) / 2.0;

    // Mean & Standard Deviation
    final mean = values.reduce((a, b) => a + b) / count;
    double varianceSum = 0;
    for (final v in values) {
      varianceSum += (v - mean) * (v - mean);
    }
    final stdDev = (count > 1) ? (varianceSum / (count - 1)) : 0.0;

    // Range bounds: 10th and 90th percentiles for robust boundaries
    final p10Index = ((count - 1) * 0.10).round();
    final p90Index = ((count - 1) * 0.90).round();
    final baselineMin = sorted[p10Index];
    final baselineMax = sorted[p90Index];

    // Status & Confidence calculation
    final isEstablished = count >= establishedSamplesRequired;
    final status = isEstablished
        ? BaselineStatus.established
        : BaselineStatus.provisional;

    final sampleRatio = (count / establishedSamplesRequired).clamp(0.0, 1.0);
    final confidenceScore = (0.40 + (sampleRatio * 0.55)).clamp(0.0, 0.95);

    return PersonalBaseline(
      id: const Uuid().v4(),
      userId: userId,
      metricName: metricName,
      baselineValue: median, // Prefer robust median over mean
      baselineMin: baselineMin,
      baselineMax: baselineMax,
      standardDeviation: stdDev,
      unit: unit,
      sampleCount: count,
      windowDays: windowDays,
      windowStart: windowStart,
      windowEnd: windowEnd,
      isWeekendSpecific: isWeekendSpecific,
      confidenceScore: double.parse(confidenceScore.toStringAsFixed(2)),
      status: status,
      calculatedAt: now,
    );
  }

  factory PersonalBaseline.fromJson(Map<String, dynamic> json) {
    return PersonalBaseline(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? '',
      metricName: json['metric_name'] as String? ?? '',
      baselineValue: (json['baseline_value'] as num?)?.toDouble() ?? 0.0,
      baselineMin: (json['baseline_min'] as num?)?.toDouble(),
      baselineMax: (json['baseline_max'] as num?)?.toDouble(),
      standardDeviation: (json['standard_deviation'] as num?)?.toDouble(),
      unit: json['unit'] as String? ?? '',
      sampleCount: json['sample_count'] as int? ?? 0,
      windowDays: json['window_days'] as int? ?? 14,
      windowStart: DateTime.tryParse(json['window_start'] as String? ?? '') ??
          DateTime.now().toUtc(),
      windowEnd: DateTime.tryParse(json['window_end'] as String? ?? '') ??
          DateTime.now().toUtc(),
      isWeekendSpecific: json['is_weekend_specific'] as bool? ?? false,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.50,
      status: BaselineStatus.fromString(json['status'] as String? ?? ''),
      algorithmVersion: json['algorithm_version'] as int? ?? 1,
      calculatedAt: DateTime.tryParse(json['calculated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'metric_name': metricName,
      'baseline_value': baselineValue,
      if (baselineMin != null) 'baseline_min': baselineMin,
      if (baselineMax != null) 'baseline_max': baselineMax,
      if (standardDeviation != null) 'standard_deviation': standardDeviation,
      'unit': unit,
      'sample_count': sampleCount,
      'window_days': windowDays,
      'window_start': windowStart.toIso8601String(),
      'window_end': windowEnd.toIso8601String(),
      'is_weekend_specific': isWeekendSpecific,
      'confidence_score': confidenceScore,
      'status': status.value,
      'algorithm_version': algorithmVersion,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }
}
