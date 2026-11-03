import 'health_data_types.dart';

/// Deduplication engine ensuring idempotent processing of incoming
/// health data points from Android Health Connect and Apple HealthKit.
class HealthDeduplicationEngine {
  const HealthDeduplicationEngine();

  /// Filters out records from [incoming] that already exist in [existingIds]
  /// or [existingFingerprints], as well as intra-batch duplicates.
  List<HealthRecord> deduplicateBatch({
    required List<HealthRecord> incoming,
    Set<String> existingExternalIds = const {},
    Set<String> existingFingerprints = const {},
  }) {
    final seenExternalIds = Set<String>.from(existingExternalIds);
    final seenFingerprints = Set<String>.from(existingFingerprints);
    final uniqueRecords = <HealthRecord>[];

    for (final record in incoming) {
      // 1. Check external provider record ID if present
      if (record.externalRecordId != null && record.externalRecordId!.isNotEmpty) {
        final extKey = '${record.sourcePlatform}:${record.externalRecordId}';
        if (seenExternalIds.contains(extKey)) {
          continue; // Duplicate by external ID
        }
        seenExternalIds.add(extKey);
      }

      // 2. Check deterministic content fingerprint
      final fingerprint = record.deterministicFingerprint;
      if (seenFingerprints.contains(fingerprint)) {
        continue; // Duplicate by biometric content
      }
      seenFingerprints.add(fingerprint);

      uniqueRecords.add(record);
    }

    return uniqueRecords;
  }

  /// Collapses high-frequency cumulative delta points (like incremental step bursts)
  /// within the same time window into cohesive daily totals if requested.
  Map<DateTime, double> aggregateDailyTotals({
    required List<HealthRecord> records,
    required HealthDataType targetType,
  }) {
    final dailyTotals = <DateTime, double>{};

    for (final record in records) {
      if (record.type != targetType) continue;

      final dayKey = DateTime.utc(
        record.recordedAt.year,
        record.recordedAt.month,
        record.recordedAt.day,
      );

      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0.0) + record.value;
    }

    return dailyTotals;
  }
}

