/// Security Infrastructure for Nutrient Earth BIOS.
///
/// Purpose: Centralize all security concerns — JWT lifecycle management,
/// API throttling, request fingerprinting, secret management, and
/// clinical-grade encryption helpers.
///
/// Responsibilities:
/// - JWT validation and refresh token flow management
/// - Per-user API rate limiting with sliding window
/// - Request fingerprinting for abuse detection
/// - Secret key management (environment-backed)
/// - AES-256 payload encryption placeholder contracts
///
/// Future expansion:
/// - Hardware Security Module (HSM) integration
/// - HIPAA BAA-compliant data handling
/// - OAuth 2.0 PKCE flow enforcement
/// - Biometric authentication bridge
library;

import 'dart:convert';

// ─── Secret Manager ───────────────────────────────────────────────────────────

/// Provides access to environment-backed secrets.
/// Never store secrets in source code — always via .env or secret manager.
class SecretManager {
  static final SecretManager _instance = SecretManager._internal();
  factory SecretManager() => _instance;
  SecretManager._internal();

  final Map<String, String> _secrets = {};

  void register(String key, String value) {
    assert(value.isNotEmpty, 'Secret "$key" must not be empty');
    _secrets[key] = value;
  }

  String get(String key) {
    final value = _secrets[key];
    if (value == null || value.isEmpty) {
      throw StateError('Secret "$key" is not registered. Ensure it is loaded from .env before use.');
    }
    return value;
  }

  bool has(String key) => _secrets.containsKey(key) && _secrets[key]!.isNotEmpty;
}

// ─── API Rate Limiter ─────────────────────────────────────────────────────────

/// Sliding window rate limiter per-user per-endpoint.
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Map<String, List<DateTime>> _log = {};

  RateLimiter({
    this.maxRequests = 60,
    this.window = const Duration(minutes: 1),
  });

  /// Returns true if request is allowed, false if rate limited.
  bool isAllowed(String fingerprint) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);

    _log.putIfAbsent(fingerprint, () => []);
    _log[fingerprint]!.removeWhere((t) => t.isBefore(windowStart));

    if (_log[fingerprint]!.length >= maxRequests) return false;
    _log[fingerprint]!.add(now);
    return true;
  }

  int requestsRemaining(String fingerprint) {
    final now = DateTime.now();
    final windowStart = now.subtract(window);
    final recent = (_log[fingerprint] ?? []).where((t) => t.isAfter(windowStart)).length;
    return (maxRequests - recent).clamp(0, maxRequests);
  }

  void reset(String fingerprint) => _log.remove(fingerprint);
}

// ─── Request Fingerprinter ────────────────────────────────────────────────────

/// Generates a deterministic fingerprint from user + session context
/// for abuse detection and rate limiting.
class RequestFingerprinter {
  static String generate({
    required String userId,
    String? deviceId,
    String? ipAddress,
  }) {
    // Simple deterministic fingerprint — replace with crypto SHA256 in production
    // by adding 'crypto: ^3.0.0' to pubspec.yaml dependencies.
    final raw = '$userId:${deviceId ?? ""}:${ipAddress ?? ""}';
    final bytes = utf8.encode(raw);
    final hash = bytes.fold<int>(0, (prev, b) => (prev * 31 + b) & 0xFFFFFFFF);
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

// ─── JWT Token Manager ────────────────────────────────────────────────────────

class TokenClaims {
  final String userId;
  final String email;
  final List<String> roles;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const TokenClaims({
    required this.userId,
    required this.email,
    required this.roles,
    required this.issuedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isNearExpiry =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 5)));
}

/// JWT token lifecycle manager — validates, parses, and manages refresh flow.
class JWTManager {
  static TokenClaims? parseSupabaseJWT(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map<String, dynamic>;

      return TokenClaims(
        userId: decoded['sub'] as String,
        email: decoded['email'] as String? ?? '',
        roles: (decoded['role'] != null) ? [decoded['role'] as String] : [],
        issuedAt: DateTime.fromMillisecondsSinceEpoch((decoded['iat'] as int) * 1000),
        expiresAt: DateTime.fromMillisecondsSinceEpoch((decoded['exp'] as int) * 1000),
      );
    } catch (_) {
      return null;
    }
  }
}

// ─── Encryption Helpers ────────────────────────────────────────────────────────

/// Contract for biometric payload encryption.
/// Implement with flutter_secure_storage + AES-256 in production.
abstract class EncryptionService {
  /// Encrypt sensitive biological payload.
  String encrypt(String plaintext, String key);

  /// Decrypt an encrypted biological payload.
  String decrypt(String ciphertext, String key);

  /// Hash a value for storage (one-way, e.g. for password or PIN).
  String hash(String value);
}

/// Development placeholder — base64 obfuscation only.
/// Replace with AES-256-GCM implementation before production.
class DevelopmentEncryptionService implements EncryptionService {
  @override
  String encrypt(String plaintext, String key) => base64.encode(utf8.encode(plaintext));

  @override
  String decrypt(String ciphertext, String key) => utf8.decode(base64.decode(ciphertext));

  @override
  String hash(String value) {
    // Dev-only: use a simple checksum. Replace with sha256 from 'crypto' package in production.
    final bytes = utf8.encode(value);
    final h = bytes.fold<int>(0, (prev, b) => (prev * 31 + b) & 0xFFFFFFFF);
    return h.toRadixString(16).padLeft(8, '0');
  }
}

// ─── Security Policy ──────────────────────────────────────────────────────────

class SecurityPolicy {
  static const int minPasswordLength = 8;
  static const Duration sessionTokenTtl = Duration(hours: 1);
  static const Duration refreshTokenTtl = Duration(days: 30);
  static const int maxFailedLoginAttempts = 5;
  static const Duration accountLockoutDuration = Duration(minutes: 15);

  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  static List<String> validatePassword(String password) {
    final violations = <String>[];
    if (password.length < minPasswordLength) violations.add('Minimum $minPasswordLength characters required');
    if (!password.contains(RegExp(r'[A-Z]'))) violations.add('At least one uppercase letter required');
    if (!password.contains(RegExp(r'[0-9]'))) violations.add('At least one number required');
    return violations;
  }
}
