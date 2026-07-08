
abstract class WearableProvider {
  String get providerName; // 'apple_health', 'oura', 'garmin', 'fitbit', 'whoop'
  
  /// Requests authentication/authorization from the user
  Future<bool> authenticate();

  /// Checks if the provider is currently connected and authorized
  Future<bool> isConnected();

  /// Fetches raw data from the provider for the specified time window
  Future<List<dynamic>> fetchRawData(DateTime start, DateTime end);
}

class AppleHealthContract implements WearableProvider {
  @override String get providerName => 'apple_health';
  @override Future<bool> authenticate() async => throw UnimplementedError('API integration blocked for Phase G');
  @override Future<bool> isConnected() async => false;
  @override Future<List<dynamic>> fetchRawData(DateTime start, DateTime end) async => [];
}

class OuraContract implements WearableProvider {
  @override String get providerName => 'oura';
  @override Future<bool> authenticate() async => throw UnimplementedError('API integration blocked for Phase G');
  @override Future<bool> isConnected() async => false;
  @override Future<List<dynamic>> fetchRawData(DateTime start, DateTime end) async => [];
}

class GarminContract implements WearableProvider {
  @override String get providerName => 'garmin';
  @override Future<bool> authenticate() async => throw UnimplementedError('API integration blocked for Phase G');
  @override Future<bool> isConnected() async => false;
  @override Future<List<dynamic>> fetchRawData(DateTime start, DateTime end) async => [];
}

class FitbitContract implements WearableProvider {
  @override String get providerName => 'fitbit';
  @override Future<bool> authenticate() async => throw UnimplementedError('API integration blocked for Phase G');
  @override Future<bool> isConnected() async => false;
  @override Future<List<dynamic>> fetchRawData(DateTime start, DateTime end) async => [];
}

class WhoopContract implements WearableProvider {
  @override String get providerName => 'whoop';
  @override Future<bool> authenticate() async => throw UnimplementedError('API integration blocked for Phase G');
  @override Future<bool> isConnected() async => false;
  @override Future<List<dynamic>> fetchRawData(DateTime start, DateTime end) async => [];
}
