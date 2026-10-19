enum DataSourceType {
  measured, // Verified clinical lab or calibrated sensor device
  userReported, // Self-entered by the user
  aiEstimated, // Derived or modeled by AI algorithms
}

extension DataSourceTypeExtension on DataSourceType {
  String get displayName {
    switch (this) {
      case DataSourceType.measured:
        return 'Measured (Lab/Device)';
      case DataSourceType.userReported:
        return 'User-Reported';
      case DataSourceType.aiEstimated:
        return 'AI Estimate';
    }
  }

  String get description {
    switch (this) {
      case DataSourceType.measured:
        return 'Verified via calibrated diagnostic hardware or certified laboratory assay.';
      case DataSourceType.userReported:
        return 'Manually entered. Subject to recall variability.';
      case DataSourceType.aiEstimated:
        return 'Calculated via multi-variate statistical modeling. May carry higher variance.';
    }
  }
}

class HealthDataPoint {
  final DateTime timestamp;
  final double value;

  const HealthDataPoint({required this.timestamp, required this.value});

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'value': value,
  };

  factory HealthDataPoint.fromJson(Map<String, dynamic> json) =>
      HealthDataPoint(
        timestamp: DateTime.parse(json['timestamp'] as String),
        value: (json['value'] as num).toDouble(),
      );
}

class HealthMeasurement {
  final String id;
  final String metricName;
  final String category; // 'Metabolic', 'Cardiovascular', 'Recovery', 'Sleep'
  final double currentValue;
  final String unit;
  final double targetValue;
  final double? normalRangeMin;
  final double? normalRangeMax;
  final DataSourceType dataSource;
  final DateTime lastUpdated;
  final List<HealthDataPoint> history;
  final String note;

  const HealthMeasurement({
    required this.id,
    required this.metricName,
    required this.category,
    required this.currentValue,
    required this.unit,
    required this.targetValue,
    this.normalRangeMin,
    this.normalRangeMax,
    required this.dataSource,
    required this.lastUpdated,
    required this.history,
    this.note = '',
  });

  bool get isInNormalRange {
    if (normalRangeMin != null && currentValue < normalRangeMin!) return false;
    if (normalRangeMax != null && currentValue > normalRangeMax!) return false;
    return true;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'metric_name': metricName,
    'category': category,
    'current_value': currentValue,
    'unit': unit,
    'target_value': targetValue,
    'normal_range_min': normalRangeMin,
    'normal_range_max': normalRangeMax,
    'data_source': dataSource.name,
    'last_updated': lastUpdated.toIso8601String(),
    'history': history.map((e) => e.toJson()).toList(),
    'note': note,
  };

  factory HealthMeasurement.fromJson(Map<String, dynamic> json) =>
      HealthMeasurement(
        id: json['id'] as String,
        metricName: json['metric_name'] as String,
        category: json['category'] as String,
        currentValue: (json['current_value'] as num).toDouble(),
        unit: json['unit'] as String,
        targetValue: (json['target_value'] as num).toDouble(),
        normalRangeMin: json['normal_range_min'] != null
            ? (json['normal_range_min'] as num).toDouble()
            : null,
        normalRangeMax: json['normal_range_max'] != null
            ? (json['normal_range_max'] as num).toDouble()
            : null,
        dataSource: DataSourceType.values.firstWhere(
          (e) => e.name == json['data_source'],
          orElse: () => DataSourceType.userReported,
        ),
        lastUpdated: DateTime.parse(json['last_updated'] as String),
        history:
            (json['history'] as List<dynamic>?)
                ?.map(
                  (e) => HealthDataPoint.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        note: json['note'] as String? ?? '',
      );
}
