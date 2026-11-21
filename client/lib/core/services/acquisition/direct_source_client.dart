// ==============================================================================
// Nutrient Earth — Direct Source REST Client Foundation
// Strictly Zero MCP Dependency: Native HTTP Client with Token-Bucket Rate Limiting,
// Exponential Backoff with Jitter, SHA-256 Byte-Level Integrity, and Schema Validation.
// ==============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

enum SourceErrorCode {
  rateLimited,
  sourceUnavailable,
  parseFailure,
  networkTimeout,
  unauthorized,
  notFound,
  unknown,
}

class DirectSourceException implements Exception {
  final String sourceId;
  final SourceErrorCode code;
  final String message;
  final int? httpStatusCode;
  final String? responseBody;

  const DirectSourceException({
    required this.sourceId,
    required this.code,
    required this.message,
    this.httpStatusCode,
    this.responseBody,
  });

  @override
  String toString() =>
      'DirectSourceException [$sourceId]: ${code.name} (HTTP $httpStatusCode) - $message';
}

class DirectSourceResponse {
  final int statusCode;
  final String rawBody;
  final Map<String, String> headers;
  final String sha256Hash;
  final int latencyMs;
  final String requestUrl;
  final DateTime timestamp;

  const DirectSourceResponse({
    required this.statusCode,
    required this.rawBody,
    required this.headers,
    required this.sha256Hash,
    required this.latencyMs,
    required this.requestUrl,
    required this.timestamp,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  dynamic parseJson() {
    try {
      return jsonDecode(rawBody);
    } catch (e) {
      throw DirectSourceException(
        sourceId: requestUrl,
        code: SourceErrorCode.parseFailure,
        message: 'Failed to parse JSON response: $e',
        httpStatusCode: statusCode,
        responseBody: rawBody,
      );
    }
  }
}

/// Token Bucket Rate Limiter with sub-millisecond precision
class TokenBucketRateLimiter {
  final double capacity;
  final double refillRatePerSecond;
  double _tokens;
  DateTime _lastRefill;

  TokenBucketRateLimiter({
    required double maxRequestsPerSecond,
    double? burstCapacity,
  })  : capacity = burstCapacity ?? maxRequestsPerSecond,
        refillRatePerSecond = maxRequestsPerSecond,
        _tokens = burstCapacity ?? maxRequestsPerSecond,
        _lastRefill = DateTime.now();

  void _refill() {
    final now = DateTime.now();
    final elapsedSec = now.difference(_lastRefill).inMicroseconds / 1000000.0;
    _tokens = min(capacity, _tokens + elapsedSec * refillRatePerSecond);
    _lastRefill = now;
  }

  Future<void> acquire() async {
    while (true) {
      _refill();
      if (_tokens >= 1.0) {
        _tokens -= 1.0;
        return;
      }
      final deficit = 1.0 - _tokens;
      final waitMs = max(50, (deficit / refillRatePerSecond * 1000).ceil());
      await Future<void>.delayed(Duration(milliseconds: waitMs));
    }
  }
}

abstract class DirectSourceClient {
  final String sourceId;
  final String baseUrl;
  final TokenBucketRateLimiter rateLimiter;
  final http.Client _httpClient;
  final Duration connectTimeout;
  final Duration readTimeout;
  final int maxRetries;
  final Random _jitterRandom = Random();

  DirectSourceClient({
    required this.sourceId,
    required this.baseUrl,
    required double maxRequestsPerSecond,
    http.Client? httpClient,
    this.connectTimeout = const Duration(seconds: 5),
    this.readTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
  })  : rateLimiter = TokenBucketRateLimiter(maxRequestsPerSecond: maxRequestsPerSecond),
        _httpClient = httpClient ?? http.Client();

  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-ResearchEngine/1.0 (evidence@nutrientearth.org; Production)',
      };

  Future<DirectSourceResponse> executeGet(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return _executeWithRetry(() async {
      await rateLimiter.acquire();
      final mergedHeaders = {...defaultHeaders(), ...?headers};

      final stopwatch = Stopwatch()..start();
      final request = http.Request('GET', uri)..headers.addAll(mergedHeaders);

      final streamedResponse = await _httpClient.send(request).timeout(connectTimeout);
      final response = await http.Response.fromStream(streamedResponse).timeout(readTimeout);
      stopwatch.stop();

      final bodyBytes = response.bodyBytes;
      final sha256Digest = sha256.convert(bodyBytes).toString();

      return DirectSourceResponse(
        statusCode: response.statusCode,
        rawBody: utf8.decode(bodyBytes, allowMalformed: true),
        headers: response.headers,
        sha256Hash: sha256Digest,
        latencyMs: stopwatch.elapsedMilliseconds,
        requestUrl: uri.toString(),
        timestamp: DateTime.now().toUtc(),
      );
    }, uri.toString());
  }

  Future<DirectSourceResponse> executePost(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    String? body,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    return _executeWithRetry(() async {
      await rateLimiter.acquire();
      final mergedHeaders = {
        ...defaultHeaders(),
        'Content-Type': 'application/json',
        ...?headers,
      };

      final stopwatch = Stopwatch()..start();
      final request = http.Request('POST', uri)
        ..headers.addAll(mergedHeaders);
      if (body != null) {
        request.body = body;
      }

      final streamedResponse = await _httpClient.send(request).timeout(connectTimeout);
      final response = await http.Response.fromStream(streamedResponse).timeout(readTimeout);
      stopwatch.stop();

      final bodyBytes = response.bodyBytes;
      final sha256Digest = sha256.convert(bodyBytes).toString();

      return DirectSourceResponse(
        statusCode: response.statusCode,
        rawBody: utf8.decode(bodyBytes, allowMalformed: true),
        headers: response.headers,
        sha256Hash: sha256Digest,
        latencyMs: stopwatch.elapsedMilliseconds,
        requestUrl: uri.toString(),
        timestamp: DateTime.now().toUtc(),
      );
    }, uri.toString());
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    final fullPath = baseUrl.endsWith('/')
        ? '$baseUrl$normalizedEndpoint'
        : '$baseUrl/$normalizedEndpoint';

    final uri = Uri.parse(fullPath);
    if (queryParams == null || queryParams.isEmpty) {
      return uri;
    }

    final mergedQuery = Map<String, dynamic>.from(uri.queryParameters);
    mergedQuery.addAll(queryParams);
    return uri.replace(queryParameters: mergedQuery);
  }

  Future<DirectSourceResponse> _executeWithRetry(
    Future<DirectSourceResponse> Function() action,
    String targetUrl,
  ) async {
    int attempts = 0;
    while (true) {
      attempts++;
      try {
        final response = await action();

        if (response.statusCode == 429) {
          if (attempts >= maxRetries) {
            throw DirectSourceException(
              sourceId: sourceId,
              code: SourceErrorCode.rateLimited,
              message: 'Rate limit exceeded after $attempts attempts',
              httpStatusCode: 429,
              responseBody: response.rawBody,
            );
          }
          final retryAfterSec = int.tryParse(response.headers['retry-after'] ?? '2') ?? 2;
          final jitterMs = _jitterRandom.nextInt(500);
          await Future<void>.delayed(
            Duration(milliseconds: (retryAfterSec * 1000) + jitterMs),
          );
          continue;
        }

        if (response.statusCode >= 500 && response.statusCode <= 599) {
          if (attempts >= maxRetries) {
            throw DirectSourceException(
              sourceId: sourceId,
              code: SourceErrorCode.sourceUnavailable,
              message: 'Upstream server error HTTP ${response.statusCode} after $attempts attempts',
              httpStatusCode: response.statusCode,
              responseBody: response.rawBody,
            );
          }
          final backoffMs = (pow(2, attempts) * 500).toInt() + _jitterRandom.nextInt(300);
          await Future<void>.delayed(Duration(milliseconds: backoffMs));
          continue;
        }

        if (response.statusCode == 404) {
          throw DirectSourceException(
            sourceId: sourceId,
            code: SourceErrorCode.notFound,
            message: 'Resource not found at $targetUrl',
            httpStatusCode: 404,
            responseBody: response.rawBody,
          );
        }

        if (response.statusCode == 401 || response.statusCode == 403) {
          throw DirectSourceException(
            sourceId: sourceId,
            code: SourceErrorCode.unauthorized,
            message: 'Unauthorized access to $targetUrl',
            httpStatusCode: response.statusCode,
            responseBody: response.rawBody,
          );
        }

        return response;
      } on TimeoutException {
        if (attempts >= maxRetries) {
          throw DirectSourceException(
            sourceId: sourceId,
            code: SourceErrorCode.networkTimeout,
            message: 'Network request timed out after $attempts attempts',
          );
        }
        final backoffMs = (pow(2, attempts) * 500).toInt() + _jitterRandom.nextInt(200);
        await Future<void>.delayed(Duration(milliseconds: backoffMs));
      } catch (e) {
        if (e is DirectSourceException) rethrow;
        if (attempts >= maxRetries) {
          throw DirectSourceException(
            sourceId: sourceId,
            code: SourceErrorCode.unknown,
            message: 'Unexpected network error: $e',
          );
        }
        await Future<void>.delayed(Duration(milliseconds: 500 * attempts));
      }
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
