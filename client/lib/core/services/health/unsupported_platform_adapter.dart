import '../../domain/health/health_data_types.dart';
import '../../domain/health/health_platform_adapter.dart';

/// Fallback adapter for desktop, web, or unsupported operating systems.
/// Ensures graceful degradation without runtime crashes.
class UnsupportedPlatformAdapter implements HealthPlatformAdapter {
  final String _reason;

  const UnsupportedPlatformAdapter({String reason = 'Unsupported Platform'}) : _reason = reason;

  @override
  String get platformName => 'unsupported_platform';

  @override
  Future<bool> isPlatformSupported() async => false;

  @override
  Future<bool> isHealthStoreAvailable() async => false;

  @override
  Future<bool> checkPermissions(List<HealthDataType> types) async => false;

  @override
  Future<bool> requestPermissions(List<HealthDataType> types) async => false;

  @override
  Future<List<HealthRecord>> readRecords({
    required List<HealthDataType> types,
    required DateTime startTime,
    required DateTime endTime,
    String? syncCursor,
  }) async {
    return const [];
  }

  @override
  Future<void> revokePermissions() async {}

  String get reason => _reason;
}
