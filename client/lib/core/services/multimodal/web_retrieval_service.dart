// ==============================================================================
// Nutrient Earth — Web Retrieval & RFC 9309 Compliant Crawler Service
// Comprehensive web ingestion pipeline with:
// 1. Strict pre-fetch DNS resolver & SSRF destination filtering (IPv4/IPv6 private ranges & cloud metadata).
// 2. RFC 9309 robots.txt compliance & polite domain rate limiting.
// 3. Ethical extraction (Zero anti-bot bypass, zero fingerprint spoofing, zero CAPTCHA circumvention).
// 4. Safe plain-text extraction from legitimate, publicly authorized web pages.
// ==============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:io' show InternetAddress, InternetAddressType;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

enum WebRetrievalStatus {
  success,
  invalidScheme,
  ssrfBlocked,
  robotsDisallowed,
  authenticationRequired,
  payloadOversized,
  networkError,
  unsupportedContentType,
}

class WebPageArtifact {
  final String url;
  final String title;
  final String metaDescription;
  final String extractedText;
  final int contentLengthBytes;
  final DateTime retrievedAt;
  final String host;
  final bool isRobotsCompliant;

  const WebPageArtifact({
    required this.url,
    required this.title,
    required this.metaDescription,
    required this.extractedText,
    required this.contentLengthBytes,
    required this.retrievedAt,
    required this.host,
    this.isRobotsCompliant = true,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'title': title,
        'metaDescription': metaDescription,
        'extractedText': extractedText,
        'contentLengthBytes': contentLengthBytes,
        'retrievedAt': retrievedAt.toIso8601String(),
        'host': host,
        'isRobotsCompliant': isRobotsCompliant,
      };
}

class WebRetrievalResult {
  final WebRetrievalStatus status;
  final String? errorMessage;
  final WebPageArtifact? artifact;

  bool get isSuccess => status == WebRetrievalStatus.success && artifact != null;

  const WebRetrievalResult._({
    required this.status,
    this.errorMessage,
    this.artifact,
  });

  factory WebRetrievalResult.success(WebPageArtifact artifact) =>
      WebRetrievalResult._(status: WebRetrievalStatus.success, artifact: artifact);

  factory WebRetrievalResult.failure({
    required WebRetrievalStatus status,
    required String errorMessage,
  }) =>
      WebRetrievalResult._(status: status, errorMessage: errorMessage);
}

class WebRetrievalService {
  final http.Client _client;
  final Future<bool> Function(Uri uri)? _destinationVerifier;
  final Duration _politeDelay;
  static final Map<String, DateTime> _lastRequestTimes = {};
  static final Map<String, List<String>> _robotsDisallowsCache = {};

  static const int maxPageSizeBytes = 5 * 1024 * 1024; // 5 MB max download
  static const int maxExtractedTextChars = 15000;
  static const Duration defaultPoliteDelay = Duration(seconds: 2);
  static const String userAgent = 'NutrientEarthBot/1.0 (+https://nutrientearth.com/bot; research@nutrientearth.com)';

  WebRetrievalService({
    http.Client? client,
    Future<bool> Function(Uri uri)? destinationVerifier,
    Duration politeDelay = defaultPoliteDelay,
  })  : _client = client ?? http.Client(),
        _destinationVerifier = destinationVerifier,
        _politeDelay = politeDelay;

  /// Primary entry point: Validates SSRF, evaluates robots.txt, respects rate limits, and extracts clean content.
  Future<WebRetrievalResult> retrieveAuthorizedWebPage(String targetUrl) async {
    Uri uri;
    try {
      uri = Uri.parse(targetUrl.trim());
    } catch (_) {
      return WebRetrievalResult.failure(
        status: WebRetrievalStatus.invalidScheme,
        errorMessage: 'Invalid URL format.',
      );
    }

    // 1. Strict HTTPS requirement
    if (uri.scheme != 'https') {
      return WebRetrievalResult.failure(
        status: WebRetrievalStatus.invalidScheme,
        errorMessage: 'Security Policy: Only secure HTTPS connections are permitted.',
      );
    }

    // 2. Pre-fetch DNS SSRF Defense
    final isSafeDestination = _destinationVerifier != null
        ? await _destinationVerifier(uri)
        : await verifySafeDestination(uri);
    if (!isSafeDestination) {
      return WebRetrievalResult.failure(
        status: WebRetrievalStatus.ssrfBlocked,
        errorMessage: 'SSRF Protection: Access to private networks, loopback addresses, or cloud metadata endpoints is blocked.',
      );
    }

    // 3. RFC 9309 Robots.txt Verification
    final isAllowedByRobots = await checkRobotsTxtAllowed(uri);
    if (!isAllowedByRobots) {
      return WebRetrievalResult.failure(
        status: WebRetrievalStatus.robotsDisallowed,
        errorMessage: 'Access Restricted: Crawling of this path is disallowed by the website operator under RFC 9309 robots.txt policy.',
      );
    }

    // 4. Polite Rate Limiting (Minimum 2 seconds between hits to same domain)
    await _enforcePoliteRateLimit(uri.host);

    // 5. Fetch Content
    try {
      final response = await _client.get(
        uri,
        headers: {
          'User-Agent': userAgent,
          'Accept': 'text/html,application/xhtml+xml,application/json;q=0.9,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.9',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 401 || response.statusCode == 403) {
        return WebRetrievalResult.failure(
          status: WebRetrievalStatus.authenticationRequired,
          errorMessage: 'Access Denied (HTTP ${response.statusCode}): This resource requires user authentication or interactive verification.',
        );
      }

      if (response.statusCode != 200) {
        return WebRetrievalResult.failure(
          status: WebRetrievalStatus.networkError,
          errorMessage: 'Web request failed with HTTP ${response.statusCode}.',
        );
      }

      if (response.bodyBytes.length > maxPageSizeBytes) {
        return WebRetrievalResult.failure(
          status: WebRetrievalStatus.payloadOversized,
          errorMessage: 'Payload size exceeds the 5 MB security limit.',
        );
      }

      final contentType = response.headers['content-type']?.toLowerCase() ?? '';
      if (!contentType.contains('text/html') &&
          !contentType.contains('text/plain') &&
          !contentType.contains('application/json') &&
          !contentType.contains('application/xhtml+xml')) {
        return WebRetrievalResult.failure(
          status: WebRetrievalStatus.unsupportedContentType,
          errorMessage: 'Unsupported MIME type ($contentType). Expected HTML, XML, or JSON.',
        );
      }

      final body = utf8.decode(response.bodyBytes, allowMalformed: true);
      final title = _extractHtmlTitle(body);
      final metaDescription = _extractMetaDescription(body);
      final visibleText = _extractVisibleText(body);

      final artifact = WebPageArtifact(
        url: uri.toString(),
        host: uri.host,
        title: title.isNotEmpty ? title : uri.host,
        metaDescription: metaDescription,
        extractedText: visibleText,
        contentLengthBytes: response.bodyBytes.length,
        retrievedAt: DateTime.now(),
        isRobotsCompliant: true,
      );

      return WebRetrievalResult.success(artifact);
    } catch (e) {
      return WebRetrievalResult.failure(
        status: WebRetrievalStatus.networkError,
        errorMessage: 'Network connection failure: $e',
      );
    }
  }

  /// Evaluates pre-fetch DNS resolution to block private/internal/cloud-metadata networks.
  static Future<bool> verifySafeDestination(Uri uri) async {
    final host = uri.host.toLowerCase().trim();
    if (host.isEmpty) return false;

    // Check blocked string patterns
    if (host == 'localhost' ||
        host.endsWith('.local') ||
        host.endsWith('.internal') ||
        host.endsWith('.corp') ||
        host.endsWith('.lan') ||
        host.endsWith('.home')) {
      return false;
    }

    // On Web (browser environment), DNS lookup is not directly accessible via dart:io,
    // but the browser sandbox enforces CORS and origin isolation. We still check hostname patterns.
    if (kIsWeb) {
      return !_isPrivateIpString(host);
    }

    // On Native / Desktop / Server: resolve DNS records before touching the socket
    try {
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isEmpty) return false;

      for (final addr in addresses) {
        if (_isBlockedIpAddress(addr)) {
          return false;
        }
      }
      return true;
    } catch (_) {
      // If DNS resolution fails, block the request
      return false;
    }
  }

  static bool _isBlockedIpAddress(InternetAddress addr) {
    if (addr.isLoopback || addr.isLinkLocal || addr.isMulticast) {
      return true;
    }

    if (addr.type == InternetAddressType.IPv4) {
      final raw = addr.rawAddress;
      final o1 = raw[0];
      final o2 = raw[1];

      // 0.0.0.0/8
      if (o1 == 0) return true;
      // 10.0.0.0/8 (RFC 1918)
      if (o1 == 10) return true;
      // 100.64.0.0/10 (Carrier-Grade NAT)
      if (o1 == 100 && (o2 >= 64 && o2 <= 127)) return true;
      // 127.0.0.0/8 (Loopback)
      if (o1 == 127) return true;
      // 169.254.0.0/16 (Link-local / AWS / GCP / Azure metadata 169.254.169.254)
      if (o1 == 169 && o2 == 254) return true;
      // 172.16.0.0/12 (RFC 1918)
      if (o1 == 172 && (o2 >= 16 && o2 <= 31)) return true;
      // 192.0.2.0/24 (TEST-NET-1)
      if (o1 == 192 && o2 == 0 && raw[2] == 2) return true;
      // 192.168.0.0/16 (RFC 1918)
      if (o1 == 192 && o2 == 168) return true;
      // 198.51.100.0/24 (TEST-NET-2)
      if (o1 == 198 && o2 == 51 && raw[2] == 100) return true;
      // 203.0.113.0/24 (TEST-NET-3)
      if (o1 == 203 && o2 == 0 && raw[2] == 113) return true;
      // 224.0.0.0/4 (Multicast)
      if (o1 >= 224) return true;
    } else if (addr.type == InternetAddressType.IPv6) {
      final raw = addr.rawAddress;
      // ::1 (Loopback)
      if (addr.address == '::1' || addr.address == '0:0:0:0:0:0:0:1') return true;
      // fc00::/7 (Unique Local Address)
      if ((raw[0] & 0xfe) == 0xfc) return true;
      // fe80::/10 (Link-Local)
      if (raw[0] == 0xfe && (raw[1] & 0xc0) == 0x80) return true;
    }

    return false;
  }

  static bool _isPrivateIpString(String host) {
    final ipv4Regex = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    final match = ipv4Regex.firstMatch(host);
    if (match != null) {
      final o1 = int.tryParse(match.group(1)!) ?? 0;
      final o2 = int.tryParse(match.group(2)!) ?? 0;
      if (o1 == 0 || o1 == 10 || o1 == 127) return true;
      if (o1 == 100 && (o2 >= 64 && o2 <= 127)) return true;
      if (o1 == 169 && o2 == 254) return true;
      if (o1 == 172 && (o2 >= 16 && o2 <= 31)) return true;
      if (o1 == 192 && o2 == 168) return true;
      if (o1 >= 224) return true;
    }
    if (host == '::1' || host == '[::1]') return true;
    return false;
  }

  /// Parses and checks the target path against RFC 9309 robots.txt rules.
  Future<bool> checkRobotsTxtAllowed(Uri targetUri) async {
    final origin = '${targetUri.scheme}://${targetUri.host}';
    final path = targetUri.path.isEmpty ? '/' : targetUri.path;

    List<String>? disallowedPatterns = _robotsDisallowsCache[origin];
    if (disallowedPatterns == null) {
      disallowedPatterns = await _fetchRobotsDisallowRules(origin);
      _robotsDisallowsCache[origin] = disallowedPatterns;
    }

    for (final pattern in disallowedPatterns) {
      if (_matchesRobotsPattern(path, pattern)) {
        return false; // Access forbidden by robots.txt
      }
    }
    return true;
  }

  Future<List<String>> _fetchRobotsDisallowRules(String origin) async {
    final robotsUrl = Uri.parse('$origin/robots.txt');
    try {
      final res = await _client.get(
        robotsUrl,
        headers: {'User-Agent': userAgent},
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode != 200) {
        return const []; // If no robots.txt exists, default to allowed
      }

      final lines = const LineSplitter().convert(res.body);
      final disallows = <String>[];
      bool isRelevantSection = false;

      for (var line in lines) {
        line = line.trim();
        if (line.startsWith('#') || line.isEmpty) continue;

        final colonIndex = line.indexOf(':');
        if (colonIndex == -1) continue;

        final key = line.substring(0, colonIndex).trim().toLowerCase();
        final val = line.substring(colonIndex + 1).trim();

        if (key == 'user-agent') {
          final ua = val.toLowerCase();
          if (ua == '*' || ua.contains('nutrientearthbot')) {
            isRelevantSection = true;
          } else {
            isRelevantSection = false;
          }
        } else if (isRelevantSection && key == 'disallow') {
          if (val.isNotEmpty) {
            disallows.add(val);
          }
        }
      }
      return disallows;
    } catch (_) {
      return const [];
    }
  }

  bool _matchesRobotsPattern(String path, String pattern) {
    if (pattern == '/') return true;
    if (pattern.endsWith('*')) {
      final prefix = pattern.substring(0, pattern.length - 1);
      return path.startsWith(prefix);
    }
    return path.startsWith(pattern);
  }

  Future<void> _enforcePoliteRateLimit(String host) async {
    if (_politeDelay == Duration.zero) return;
    final lastTime = _lastRequestTimes[host];
    final now = DateTime.now();
    if (lastTime != null) {
      final elapsed = now.difference(lastTime);
      if (elapsed < _politeDelay) {
        final waitDuration = _politeDelay - elapsed;
        await Future<void>.delayed(waitDuration);
      }
    }
    _lastRequestTimes[host] = DateTime.now();
  }

  static String _extractHtmlTitle(String html) {
    final match = RegExp(r'<title[^>]*>(.*?)</title>', caseSensitive: false, dotAll: true).firstMatch(html);
    if (match != null) {
      return _cleanHtmlText(match.group(1) ?? '');
    }
    return '';
  }

  static String _extractMetaDescription(String html) {
    final match = RegExp(r'<meta[^>]*name=["\x27]description["\x27][^>]*content=["\x27](.*?)["\x27]', caseSensitive: false)
        .firstMatch(html);
    if (match != null) {
      return _cleanHtmlText(match.group(1) ?? '');
    }
    return '';
  }

  static String _extractVisibleText(String html) {
    // 1. Strip script, style, svg, and nav elements
    var cleaned = html.replaceAll(RegExp(r'<(?:script|style|svg|noscript|header|footer|nav)[^>]*>[\s\S]*?<\/(?:script|style|svg|noscript|header|footer|nav)>', caseSensitive: false), ' ');
    // 2. Strip remaining HTML tags
    cleaned = cleaned.replaceAll(RegExp(r'<[^>]+>'), ' ');
    // 3. Decode entities and normalize whitespace
    cleaned = _cleanHtmlText(cleaned);

    if (cleaned.length > maxExtractedTextChars) {
      cleaned = cleaned.substring(0, maxExtractedTextChars);
    }
    return cleaned;
  }

  static String _cleanHtmlText(String text) {
    var s = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
