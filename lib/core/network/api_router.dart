import 'dart:convert';
import '../errors/failures.dart';

/// Representation of an outgoing API network request.
class BiologicalRequest {
  final String path;
  final String method; // GET, POST, PUT, DELETE
  final Map<String, String> headers;
  final Map<String, dynamic> body;

  const BiologicalRequest({
    required this.path,
    required this.method,
    this.headers = const {},
    this.body = const {},
  });
}

/// Representation of a parsed API network response.
class BiologicalResponse {
  final int statusCode;
  final String body;

  const BiologicalResponse({required this.statusCode, required this.body});

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> parseBody() => jsonDecode(body) as Map<String, dynamic>;
}

/// Dynamic swappable Network client wrapper matching REST specifications.
abstract class NetworkGateway {
  Future<BiologicalResponse> dispatch(BiologicalRequest request);
}

/// Safe defensive router gateway parsing outgoing payloads.
class BiologicalAPIRouter {
  final NetworkGateway gateway;

  const BiologicalAPIRouter({required this.gateway});

  /// Ingest environmental streams from OpenAQ.
  Future<Map<String, dynamic>> fetchAQIMetrics(double lat, double lng) async {
    final req = BiologicalRequest(
      path: '/v1/environmental/aqi?lat=$lat&lng=$lng',
      method: 'GET',
    );

    final res = await gateway.dispatch(req);

    if (!res.isSuccessful) {
      throw NetworkTimeout('Environmental API returned unsuccessful status code: ${res.statusCode}');
    }

    return res.parseBody();
  }

  /// Sync digital twin metrics back to global database.
  Future<void> syncBiometricTwinState(String userId, Map<String, dynamic> twinStatePayload) async {
    final req = BiologicalRequest(
      path: '/v1/biological/twin-sync',
      method: 'POST',
      body: {
        'user_id': userId,
        'state_data': twinStatePayload,
      },
    );

    final res = await gateway.dispatch(req);

    if (!res.isSuccessful) {
      throw const ServerFailure('Unable to synchronize Digital Twin with primary storage layer.');
    }
  }
}
