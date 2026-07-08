/// Network Layer Contracts and HTTP Infrastructure for Nutrient Earth BIOS.
///
/// Purpose: Provide a provider-swappable HTTP client abstraction that all
/// external API adapters use, enforcing timeouts, retry, and auth injection.
///
/// Responsibilities:
/// - Abstract HTTP method calls behind a swappable interface
/// - Enforce system-wide timeout policies
/// - Support auth header injection (Bearer tokens)
/// - Support request/response logging for observability
///
/// Dependencies: core/constants/biological_constants.dart
///
/// Future expansion:
/// - Request signing for clinical API providers
/// - Circuit breaker pattern implementation
/// - mTLS for wearable stream ingestion
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/biological_constants.dart';
import '../errors/failures.dart';

/// Abstract HTTP client contract — enables test mocking and provider swapping.
abstract class NetworkClient {
  Future<NetworkResponse> get(String url, {Map<String, String>? headers});
  Future<NetworkResponse> post(String url, {Map<String, String>? headers, Map<String, dynamic>? body});
  Future<NetworkResponse> put(String url, {Map<String, String>? headers, Map<String, dynamic>? body});
  Future<NetworkResponse> delete(String url, {Map<String, String>? headers});
}

/// Standard network response wrapper.
class NetworkResponse {
  final int statusCode;
  final Map<String, dynamic>? data;
  final String? rawBody;
  final bool isSuccess;
  final String? errorMessage;
  final Duration latency;

  const NetworkResponse({
    required this.statusCode,
    required this.isSuccess,
    required this.latency,
    this.data,
    this.rawBody,
    this.errorMessage,
  });

  factory NetworkResponse.success(int statusCode, String body, Duration latency) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      return NetworkResponse(
        statusCode: statusCode,
        isSuccess: true,
        data: data,
        rawBody: body,
        latency: latency,
      );
    } catch (_) {
      return NetworkResponse(
        statusCode: statusCode,
        isSuccess: true,
        rawBody: body,
        latency: latency,
      );
    }
  }

  factory NetworkResponse.failure(int statusCode, String message, Duration latency) =>
      NetworkResponse(
        statusCode: statusCode,
        isSuccess: false,
        errorMessage: message,
        latency: latency,
      );
}

/// Production HTTP client implementation using dart:http.
class HttpNetworkClient implements NetworkClient {
  final http.Client _client;
  final Map<String, String> _defaultHeaders;

  HttpNetworkClient({
    http.Client? client,
    Map<String, String>? defaultHeaders,
  })  : _client = client ?? http.Client(),
        _defaultHeaders = defaultHeaders ?? {};

  @override
  Future<NetworkResponse> get(String url, {Map<String, String>? headers}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client
          .get(Uri.parse(url), headers: {..._defaultHeaders, ...?headers})
          .timeout(SystemConfig.apiRequestTimeout);
      stopwatch.stop();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return NetworkResponse.success(response.statusCode, response.body, stopwatch.elapsed);
      }
      return NetworkResponse.failure(response.statusCode, response.body, stopwatch.elapsed);
    } on Exception catch (e) {
      stopwatch.stop();
      throw NetworkTimeout('GET $url failed: ${e.toString()}');
    }
  }

  @override
  Future<NetworkResponse> post(String url,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ..._defaultHeaders,
              ...?headers,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(SystemConfig.apiRequestTimeout);
      stopwatch.stop();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return NetworkResponse.success(response.statusCode, response.body, stopwatch.elapsed);
      }
      return NetworkResponse.failure(response.statusCode, response.body, stopwatch.elapsed);
    } on Exception catch (e) {
      stopwatch.stop();
      throw NetworkTimeout('POST $url failed: ${e.toString()}');
    }
  }

  @override
  Future<NetworkResponse> put(String url,
      {Map<String, String>? headers, Map<String, dynamic>? body}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              ..._defaultHeaders,
              ...?headers,
            },
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(SystemConfig.apiRequestTimeout);
      stopwatch.stop();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return NetworkResponse.success(response.statusCode, response.body, stopwatch.elapsed);
      }
      return NetworkResponse.failure(response.statusCode, response.body, stopwatch.elapsed);
    } on Exception catch (e) {
      stopwatch.stop();
      throw NetworkTimeout('PUT $url failed: ${e.toString()}');
    }
  }

  @override
  Future<NetworkResponse> delete(String url, {Map<String, String>? headers}) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client
          .delete(Uri.parse(url), headers: {..._defaultHeaders, ...?headers})
          .timeout(SystemConfig.apiRequestTimeout);
      stopwatch.stop();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return NetworkResponse.success(response.statusCode, response.body, stopwatch.elapsed);
      }
      return NetworkResponse.failure(response.statusCode, response.body, stopwatch.elapsed);
    } on Exception catch (e) {
      stopwatch.stop();
      throw NetworkTimeout('DELETE $url failed: ${e.toString()}');
    }
  }
}
