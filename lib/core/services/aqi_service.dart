import 'dart:convert';
import 'package:http/http.dart' as http;

class AqiData {
  final int aqi;
  final double uvi; // Now fetched from air quality API
  final String status; // Good, Moderate, Unhealthy, etc.
  final Map<String, double> pollutants; // pm25, pm10, etc.

  AqiData({
    required this.aqi,
    required this.uvi,
    required this.status,
    required this.pollutants,
  });

  factory AqiData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final aqiVal = (current['us_aqi'] as num?)?.toInt() ?? 0;
    
    return AqiData(
      aqi: aqiVal,
      uvi: (current['uv_index'] as num?)?.toDouble() ?? 0.0,
      status: _getStatus(aqiVal),
      pollutants: {
        'pm25': (current['pm2_5'] as num?)?.toDouble() ?? 0.0,
        'pm10': (current['pm10'] as num?)?.toDouble() ?? 0.0,
      },
    );
  }

  static String _getStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  factory AqiData.placeholder() {
    return AqiData(
      aqi: 42,
      uvi: 2.0,
      status: 'Good',
      pollutants: {'pm25': 12.0, 'pm10': 24.0},
    );
  }
}

class AqiService {
  static const String _baseUrl = 'https://air-quality-api.open-meteo.com/v1/air-quality';

  static Future<AqiData> fetchAqi(double lat, double lon) async {
    final raw = await fetchAqiRaw(lat, lon);
    if (raw != null) {
      return AqiData.fromJson(raw);
    }
    return AqiData.placeholder();
  }

  static Future<Map<String, dynamic>?> fetchAqiRaw(double lat, double lon) async {
    try {
      final url = '$_baseUrl?latitude=$lat&longitude=$lon&current=us_aqi,uv_index,pm10,pm2_5&timezone=auto';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ AqiService Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('🔥 AqiService Exception: $e');
      return null;
    }
  }
}
