import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/core/network/environmental_service.dart';

void main() {
  group('EnvironmentalService Privacy Tests', () {
    test('truncateCoordinate rounds coordinate to 2 decimal places for user location privacy', () {
      const rawLat = 37.7749295;
      const rawLon = -122.4194155;

      final truncLat = EnvironmentalService.truncateCoordinate(rawLat);
      final truncLon = EnvironmentalService.truncateCoordinate(rawLon);

      expect(truncLat, equals(37.77));
      expect(truncLon, equals(-122.41));
    });

    test('EnvironmentalMetrics calculates AQI categories accurately', () {
      final goodMetrics = EnvironmentalMetrics(
        latitude: 37.77,
        longitude: -122.41,
        temperatureC: 20.0,
        relativeHumidity: 50.0,
        apparentTemperatureC: 20.0,
        uvIndex: 3.0,
        usAqi: 35,
        timestamp: DateTime.now(),
      );
      expect(goodMetrics.aqiCategory, equals('Good'));

      final modMetrics = EnvironmentalMetrics(
        latitude: 37.77,
        longitude: -122.41,
        temperatureC: 20.0,
        relativeHumidity: 50.0,
        apparentTemperatureC: 20.0,
        uvIndex: 3.0,
        usAqi: 85,
        timestamp: DateTime.now(),
      );
      expect(modMetrics.aqiCategory, equals('Moderate'));
    });
  });
}
