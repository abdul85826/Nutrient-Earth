import 'health_data_types.dart';

/// Common abstraction for operating system health data providers.
/// Enables identical contract execution across Android Health Connect,
/// Apple HealthKit, and test harnesses.
abstract class HealthPlatformAdapter {
  /// The canonical platform identifier (e.g. 'android_health_connect', 'apple_healthkit').
  String get platformName;

  /// Check whether this platform is supported on the current device.
  Future<bool> isPlatformSupported();

  /// Check whether the platform health store (Health Connect / HealthKit) is installed and available.
  Future<bool> isHealthStoreAvailable();

  /// Check whether permissions are currently granted for the given data types.
  Future<bool> checkPermissions(List<HealthDataType> types);

  /// Request access permissions from the user for the given data types.
  Future<bool> requestPermissions(List<HealthDataType> types);

  /// Fetch health records across the requested time range or incremental cursor.
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  });

  /// Revoke or reset granted health permissions.
  Future<void> revokePermissions();
}
