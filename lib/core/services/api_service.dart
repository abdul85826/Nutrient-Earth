import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class BaseApiService {
  static const int timeoutSeconds = 15;

  Future<Map<String, dynamic>?> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: timeoutSeconds));
      return _processResponse(response);
    } on TimeoutException {
      print('❌ API Timeout: $url');
      return null;
    } catch (e) {
      print('🔥 API Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> post(String url, {Map<String, String>? headers, dynamic body}) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: timeoutSeconds));
      return _processResponse(response);
    } on TimeoutException {
      print('❌ API Timeout: $url');
      return null;
    } catch (e) {
      print('🔥 API Error: $e');
      return null;
    }
  }

  Map<String, dynamic>? _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      print('❌ API Response Error: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
