import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temp;
  final double feelsLike;
  final int humidity;
  final double uvi; // Now handled primarily via AQI service or combined. For now we will set default 0.0 or pass from AQI
  final String condition;
  final String description;
  final DateTime? sunrise;
  final DateTime? sunset;

  WeatherData({
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.uvi,
    required this.condition,
    required this.description,
    this.sunrise,
    this.sunset,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final daily = json['daily'] as Map<String, dynamic>? ?? {};
    final code = current['weather_code'] as int? ?? 0;
    
    DateTime? parsedSunrise;
    DateTime? parsedSunset;
    
    if (daily['sunrise'] != null && (daily['sunrise'] as List).isNotEmpty) {
      parsedSunrise = DateTime.tryParse(daily['sunrise'][0].toString());
    }
    if (daily['sunset'] != null && (daily['sunset'] as List).isNotEmpty) {
      parsedSunset = DateTime.tryParse(daily['sunset'][0].toString());
    }
    
    return WeatherData(
      temp: (current['temperature_2m'] as num?)?.toDouble() ?? 22.0,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble() ?? 23.0,
      humidity: (current['relative_humidity_2m'] as num?)?.toInt() ?? 45,
      uvi: 0.0, // UV Index will be fetched via Air Quality API for more accuracy
      condition: _mapWmoCodeToCondition(code),
      description: _mapWmoCodeToDescription(code),
      sunrise: parsedSunrise,
      sunset: parsedSunset,
    );
  }

  factory WeatherData.placeholder() {
    return WeatherData(
      temp: 22.0,
      feelsLike: 23.0,
      humidity: 45,
      uvi: 2.0,
      condition: 'Clear',
      description: 'clear sky',
      sunrise: DateTime.now().copyWith(hour: 6, minute: 0),
      sunset: DateTime.now().copyWith(hour: 20, minute: 0),
    );
  }

  static String _mapWmoCodeToCondition(int code) {
    if (code == 0) return 'Clear';
    if (code <= 3) return 'Clouds';
    if (code <= 48) return 'Fog';
    if (code <= 55) return 'Drizzle';
    if (code <= 65) return 'Rain';
    if (code <= 77) return 'Snow';
    if (code <= 82) return 'Rain';
    if (code <= 86) return 'Snow';
    if (code <= 99) return 'Thunderstorm';
    return 'Clear';
  }

  static String _mapWmoCodeToDescription(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code == 45) return 'Fog';
    if (code == 51) return 'Light drizzle';
    if (code == 61) return 'Slight rain';
    if (code == 71) return 'Slight snow fall';
    if (code >= 95) return 'Thunderstorm';
    return 'Cloudy';
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  static Future<WeatherData> fetchWeather(double lat, double lon) async {
    final raw = await fetchWeatherRaw(lat, lon);
    if (raw != null) {
      return WeatherData.fromJson(raw);
    }
    return WeatherData.placeholder();
  }

  static Future<Map<String, dynamic>?> fetchWeatherRaw(double lat, double lon) async {
    try {
      final url = '$_baseUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code&daily=sunrise,sunset&timezone=auto';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ WeatherService Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 WeatherService Exception: $e');
      return null;
    }
  }
}
