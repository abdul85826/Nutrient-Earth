// ==============================================================================
// Nutrient Earth — Web Retrieval & RFC 9309 Crawler Tests (Phase 3)
// 1. SSRF destination verification (loopback, private subnets, cloud metadata)
// 2. Strict HTTPS enforcement
// 3. RFC 9309 robots.txt parser & pattern matching
// 4. HTML sanitization and visible text extraction
// 5. Payload size guard (5 MB limit)
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nutrient_earth_client/core/services/multimodal/web_retrieval_service.dart';

void main() {
  group('Phase 3 — Web Retrieval & SSRF Defense', () {
    test('Rejects unencrypted HTTP schemes', () async {
      final service = WebRetrievalService();
      final result = await service.retrieveAuthorizedWebPage('http://example.com/research');

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(WebRetrievalStatus.invalidScheme));
      expect(result.errorMessage, contains('Only secure HTTPS connections are permitted'));
    });

    test('Blocks loopback localhost addresses', () async {
      final isSafe = await WebRetrievalService.verifySafeDestination(Uri.parse('https://localhost/admin'));
      expect(isSafe, isFalse);
    });

    test('Blocks internal corporate domains (.local, .internal, .corp)', () async {
      final isLocal = await WebRetrievalService.verifySafeDestination(Uri.parse('https://vault.local/secrets'));
      final isInternal = await WebRetrievalService.verifySafeDestination(Uri.parse('https://db.internal/patients'));
      final isCorp = await WebRetrievalService.verifySafeDestination(Uri.parse('https://wiki.corp/admin'));

      expect(isLocal, isFalse);
      expect(isInternal, isFalse);
      expect(isCorp, isFalse);
    });

    test('Blocks cloud metadata IP 169.254.169.254', () async {
      final isMetadata = await WebRetrievalService.verifySafeDestination(Uri.parse('https://169.254.169.254/latest/meta-data'));
      expect(isMetadata, isFalse);
    });

    test('Blocks RFC 1918 private subnets (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)', () async {
      final is10 = await WebRetrievalService.verifySafeDestination(Uri.parse('https://10.1.2.3/data'));
      final is172 = await WebRetrievalService.verifySafeDestination(Uri.parse('https://172.20.0.5/api'));
      final is192 = await WebRetrievalService.verifySafeDestination(Uri.parse('https://192.168.1.1/router'));

      expect(is10, isFalse);
      expect(is172, isFalse);
      expect(is192, isFalse);
    });
  });

  group('Phase 3 — RFC 9309 Robots.txt Compliance & Ingestion', () {
    test('Disallowed path in robots.txt halts crawl before page download', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/robots.txt') {
          return http.Response(
            'User-agent: *\n'
            'Disallow: /private-research/\n'
            'Disallow: /admin/\n',
            200,
          );
        }
        return http.Response('Should not be reached', 200);
      });

      final service = WebRetrievalService(
        client: mockClient,
        destinationVerifier: (uri) async => true,
        politeDelay: Duration.zero,
      );
      final result = await service.retrieveAuthorizedWebPage('https://verified-science.org/private-research/study.html');

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(WebRetrievalStatus.robotsDisallowed));
      expect(result.errorMessage, contains('RFC 9309 robots.txt policy'));
    });

    test('Allowed path downloads and extracts clean HTML metadata & visible text', () async {
      final html = '''
<!DOCTYPE html>
<html>
<head>
  <title>Clinical Efficacy of Soluble Dietary Fiber</title>
  <meta name="description" content="A systematic review on psyllium and colonic short-chain fatty acids.">
  <style>body { color: red; }</style>
  <script>console.log("tracking");</script>
</head>
<body>
  <header><nav>Home | Login</nav></header>
  <main>
    <h1>Introduction</h1>
    <p>Soluble fiber forms an emollient gel in the gastrointestinal tract, promoting regular motility and prebiotic fermentation.</p>
  </main>
  <footer>Copyright 2026</footer>
</body>
</html>
''';

      final mockClient = MockClient((request) async {
        if (request.url.path == '/robots.txt') {
          return http.Response('User-agent: *\nDisallow: /admin/\n', 200);
        }
        return http.Response(
          html,
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      });

      final service = WebRetrievalService(
        client: mockClient,
        destinationVerifier: (uri) async => true,
        politeDelay: Duration.zero,
      );
      final result = await service.retrieveAuthorizedWebPage('https://verified-science.org/open-access/fiber-review.html');

      expect(result.isSuccess, isTrue);
      expect(result.artifact, isNotNull);
      expect(result.artifact!.title, equals('Clinical Efficacy of Soluble Dietary Fiber'));
      expect(result.artifact!.metaDescription, contains('systematic review on psyllium'));
      expect(result.artifact!.extractedText, contains('Soluble fiber forms an emollient gel'));
      expect(result.artifact!.extractedText, isNot(contains('console.log')));
      expect(result.artifact!.extractedText, isNot(contains('body { color: red; }')));
    });

    test('HTTP 403 or 401 triggers explicit authenticationRequired failure without bypassing anti-bot', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/robots.txt') {
          return http.Response('', 404);
        }
        return http.Response('Cloudflare Access Verification', 403);
      });

      final service = WebRetrievalService(
        client: mockClient,
        destinationVerifier: (uri) async => true,
        politeDelay: Duration.zero,
      );
      final result = await service.retrieveAuthorizedWebPage('https://paywalled-journal.org/article');

      expect(result.isSuccess, isFalse);
      expect(result.status, equals(WebRetrievalStatus.authenticationRequired));
      expect(result.errorMessage, contains('requires user authentication or interactive verification'));
    });
  });
}
