import 'package:uuid/uuid.dart';

class UnifiedHealthMetric {
  final String metricId;
  final String type; // e.g. 'heart_rate', 'hrv', 'sleep_duration', 'respiration_rate', 'body_temperature', 'blood_oxygen', 'steps', 'calories'
  final dynamic value; // Can be int, double, or structured object for stages
  final String unit; // 'bpm', 'ms', 'minutes', 'celsius', 'percentage', 'count', 'kcal'
  
  final String source; // 'apple_health', 'oura', 'garmin', 'fitbit', 'whoop'
  final String deviceId; // e.g. 'OuraRingGen3_1234'
  final String providerId; // Wearable vendor user/account ID

  final DateTime timestamp;
  final double confidence; // 0.0 - 1.0 (Hardware confidence)
  final bool measuredVsInferred; // true = directly measured by sensor, false = inferred via algorithm

  UnifiedHealthMetric({
    String? metricId,
    required this.type,
    required this.value,
    required this.unit,
    required this.source,
    required this.deviceId,
    required this.providerId,
    required this.timestamp,
    required this.confidence,
    required this.measuredVsInferred,
  }) : metricId = metricId ?? const Uuid().v4();
}
