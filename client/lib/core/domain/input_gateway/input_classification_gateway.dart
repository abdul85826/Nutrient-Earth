// ==============================================================================
// Nutrient Earth — Input Classification & Security Gateway
// Deterministic classifier and security validator for multimodal inputs.
// Enforces MIME detection, file size limits, SSRF protection, and platform routing.
// ==============================================================================

import 'dart:typed_data';
import 'package:uuid/uuid.dart';

import 'universal_input_descriptor.dart';

class InputClassificationGateway {
  static const int maxTextLength = 2000;
  static const int maxImageSizeBytes = 25 * 1024 * 1024; // 25 MB
  static const int maxPdfSizeBytes = 30 * 1024 * 1024;   // 30 MB
  static const int maxVideoSizeBytes = 100 * 1024 * 1024; // 100 MB
  static const int maxAudioSizeBytes = 25 * 1024 * 1024; // 25 MB

  static const _uuid = Uuid();

  const InputClassificationGateway();

  /// Static convenience helper to classify raw input into a UniversalInputDescriptor.
  static UniversalInputDescriptor classifyRawInput({
    required String rawInput,
    InputSourceType sourceType = InputSourceType.userText,
  }) {
    final result = const InputClassificationGateway().processTextOrUrl(rawInput, source: sourceType);
    if (result.isSuccess) {
      return result.validatedDescriptor!;
    }
    return UniversalInputDescriptor(
      id: _uuid.v4(),
      type: UserInputType.text,
      source: sourceType,
      rawContent: rawInput,
      sanitizedContent: rawInput,
      createdAt: DateTime.now(),
    );
  }

  /// Validates a URL against strict scheme and SSRF constraints.
  static InputValidationResult validateUrl(String urlString) {
    return const InputClassificationGateway()._validateAndClassifyUrl(
      urlString,
      source: InputSourceType.clipboardUrl,
    );
  }

  /// Classifies and validates a text or pasted URL query.
  InputValidationResult processTextOrUrl(
    String input, {
    InputSourceType source = InputSourceType.userText,
  }) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const InputValidationResult.invalid(
        status: InputValidationStatus.emptyPayload,
        errorMessage: 'Input cannot be empty.',
      );
    }

    // 1. Check if the input is a URL
    if (_isPotentialUrl(trimmed)) {
      return _validateAndClassifyUrl(trimmed, source: source);
    }

    // 2. Check if the input is a pure numeric barcode (UPC-A, EAN-8, EAN-13, ITF-14)
    if (_isBarcode(trimmed)) {
      final descriptor = UniversalInputDescriptor(
        id: _uuid.v4(),
        type: UserInputType.barcode,
        source: source == InputSourceType.userText ? InputSourceType.barcodeScanner : source,
        rawContent: trimmed,
        barcodeValue: trimmed,
        sanitizedContent: trimmed,
        createdAt: DateTime.now(),
      );
      return InputValidationResult.valid(descriptor);
    }

    // 3. Regular text query
    if (trimmed.length > maxTextLength) {
      return InputValidationResult.invalid(
        status: InputValidationStatus.oversizedFile,
        errorMessage: 'Query exceeds maximum length of $maxTextLength characters.',
      );
    }

    final sanitized = _sanitizeText(trimmed);

    final descriptor = UniversalInputDescriptor(
      id: _uuid.v4(),
      type: UserInputType.text,
      source: source,
      rawContent: trimmed,
      sanitizedContent: sanitized,
      createdAt: DateTime.now(),
    );

    return InputValidationResult.valid(descriptor);
  }

  /// Classifies and validates a binary file upload (Image, PDF, or Video).
  InputValidationResult processFile({
    required String filePath,
    required Uint8List fileBytes,
    String? explicitMimeType,
    InputSourceType source = InputSourceType.filePicker,
    String? userPrompt,
  }) {
    if (fileBytes.isEmpty) {
      return const InputValidationResult.invalid(
        status: InputValidationStatus.emptyPayload,
        errorMessage: 'Uploaded file is empty (0 bytes).',
      );
    }

    final detectedMime = _detectMimeType(fileBytes, explicitMimeType, filePath);
    final size = fileBytes.length;

    // A. Image file validation
    if (_isImageMime(detectedMime)) {
      if (size > maxImageSizeBytes) {
        return InputValidationResult.invalid(
          status: InputValidationStatus.oversizedFile,
          errorMessage: 'Image size (${_formatBytes(size)}) exceeds limit of 25 MB.',
        );
      }

      final descriptor = UniversalInputDescriptor(
        id: _uuid.v4(),
        type: UserInputType.image,
        source: source,
        rawContent: userPrompt ?? 'Image Analysis',
        sanitizedContent: userPrompt != null ? _sanitizeText(userPrompt) : 'Image Analysis',
        filePath: filePath,
        fileBytes: fileBytes,
        mimeType: detectedMime,
        fileSizeBytes: size,
        createdAt: DateTime.now(),
      );
      return InputValidationResult.valid(descriptor);
    }

    // B. PDF document validation
    if (detectedMime == 'application/pdf') {
      if (size > maxPdfSizeBytes) {
        return InputValidationResult.invalid(
          status: InputValidationStatus.oversizedFile,
          errorMessage: 'Document size (${_formatBytes(size)}) exceeds limit of 30 MB.',
        );
      }

      final descriptor = UniversalInputDescriptor(
        id: _uuid.v4(),
        type: UserInputType.documentPdf,
        source: source,
        rawContent: userPrompt ?? 'PDF Document Analysis',
        sanitizedContent: userPrompt != null ? _sanitizeText(userPrompt) : 'PDF Document Analysis',
        filePath: filePath,
        fileBytes: fileBytes,
        mimeType: detectedMime,
        fileSizeBytes: size,
        createdAt: DateTime.now(),
      );
      return InputValidationResult.valid(descriptor);
    }

    // C. Uploaded video file validation
    if (_isVideoMime(detectedMime)) {
      if (size > maxVideoSizeBytes) {
        return InputValidationResult.invalid(
          status: InputValidationStatus.oversizedFile,
          errorMessage: 'Video size (${_formatBytes(size)}) exceeds maximum limit of 100 MB.',
        );
      }

      final descriptor = UniversalInputDescriptor(
        id: _uuid.v4(),
        type: UserInputType.videoUpload,
        source: source,
        rawContent: userPrompt ?? 'Video Understanding',
        sanitizedContent: userPrompt != null ? _sanitizeText(userPrompt) : 'Video Understanding',
        filePath: filePath,
        fileBytes: fileBytes,
        mimeType: detectedMime,
        fileSizeBytes: size,
        createdAt: DateTime.now(),
      );
      return InputValidationResult.valid(descriptor);
    }

    // D. Audio file validation
    if (_isAudioMime(detectedMime)) {
      if (size > maxAudioSizeBytes) {
        return InputValidationResult.invalid(
          status: InputValidationStatus.oversizedFile,
          errorMessage: 'Audio file size (${_formatBytes(size)}) exceeds maximum limit of 25 MB.',
        );
      }

      final descriptor = UniversalInputDescriptor(
        id: _uuid.v4(),
        type: UserInputType.audio,
        source: source == InputSourceType.microphone ? InputSourceType.microphone : InputSourceType.audioFile,
        rawContent: userPrompt ?? 'Audio Transcription & Evidence Synthesis',
        sanitizedContent: userPrompt != null ? _sanitizeText(userPrompt) : 'Audio Transcription & Evidence Synthesis',
        filePath: filePath,
        fileBytes: fileBytes,
        mimeType: detectedMime,
        fileSizeBytes: size,
        createdAt: DateTime.now(),
      );
      return InputValidationResult.valid(descriptor);
    }

    return InputValidationResult.invalid(
      status: InputValidationStatus.unsupportedMimeType,
      errorMessage: 'Unsupported file format ($detectedMime). Allowed: JPEG, PNG, WebP, PDF, MP4, WebM, MP3, WAV, M4A, OGG.',
    );
  }

  // ---------------------------------------------------------------------------
  // URL Classification & SSRF Defense
  // ---------------------------------------------------------------------------

  bool _isPotentialUrl(String text) {
    if (text.contains(' ') || text.contains('\n')) return false;
    final lower = text.toLowerCase();
    return lower.startsWith('http://') ||
        lower.startsWith('https://') ||
        lower.startsWith('www.') ||
        lower.contains('youtube.com/') ||
        lower.contains('youtu.be/') ||
        lower.contains('instagram.com/') ||
        lower.contains('tiktok.com/');
  }

  InputValidationResult _validateAndClassifyUrl(
    String urlString, {
    required InputSourceType source,
  }) {
    var normalized = urlString.trim();
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }

    Uri uri;
    try {
      uri = Uri.parse(normalized);
    } catch (_) {
      return const InputValidationResult.invalid(
        status: InputValidationStatus.invalidUrlScheme,
        errorMessage: 'Malformed URL structure.',
      );
    }

    // SSRF Rule 1: HTTPS scheme only
    if (uri.scheme != 'https') {
      return const InputValidationResult.invalid(
        status: InputValidationStatus.invalidUrlScheme,
        errorMessage: 'Security violation: Only encrypted HTTPS URLs are permitted.',
      );
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty) {
      return const InputValidationResult.invalid(
        status: InputValidationStatus.invalidUrlScheme,
        errorMessage: 'Invalid URL: Hostname missing.',
      );
    }

    // SSRF Rule 2: Reject loopback, private ranges, link-local, and cloud metadata
    if (_isBlockedHost(host)) {
      return InputValidationResult.invalid(
        status: InputValidationStatus.ssrfBlocked,
        errorMessage: 'Security restriction: Access to internal, private, or metadata network addresses ($host) is strictly prohibited.',
      );
    }

    // Social Media Platforms vs General Web
    final socialPlatform = _identifySocialPlatform(host);
    final isSocialVideo = socialPlatform != null &&
        (socialPlatform == 'youtube' || socialPlatform == 'instagram' || socialPlatform == 'tiktok');

    final descriptor = UniversalInputDescriptor(
      id: _uuid.v4(),
      type: isSocialVideo ? UserInputType.socialVideoUrl : UserInputType.webUrl,
      source: source == InputSourceType.userText ? InputSourceType.clipboardUrl : source,
      rawContent: normalized,
      targetUrl: normalized,
      socialPlatform: socialPlatform,
      sanitizedContent: normalized,
      createdAt: DateTime.now(),
    );

    return InputValidationResult.valid(descriptor);
  }

  bool _isBlockedHost(String host) {
    if (host == 'localhost' || host.endsWith('.local') || host.endsWith('.internal')) {
      return true;
    }

    // IPv4 checks
    final ipv4Regex = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    final match = ipv4Regex.firstMatch(host);
    if (match != null) {
      final octet1 = int.tryParse(match.group(1)!) ?? 0;
      final octet2 = int.tryParse(match.group(2)!) ?? 0;

      // Loopback 127.0.0.0/8
      if (octet1 == 127) return true;
      // Private 10.0.0.0/8
      if (octet1 == 10) return true;
      // Private 172.16.0.0 - 172.31.255.255
      if (octet1 == 172 && octet2 >= 16 && octet2 <= 31) return true;
      // Private 192.168.0.0/16
      if (octet1 == 192 && octet2 == 168) return true;
      // Link-local / Cloud Metadata 169.254.0.0/16
      if (octet1 == 169 && octet2 == 254) return true;
      // Zero network
      if (octet1 == 0) return true;
    }

    // IPv6 loopback
    if (host == '::1' || host == '[::1]') return true;

    return false;
  }

  String? _identifySocialPlatform(String host) {
    if (host.contains('youtube.com') || host.contains('youtu.be')) return 'youtube';
    if (host.contains('instagram.com')) return 'instagram';
    if (host.contains('tiktok.com')) return 'tiktok';
    if (host.contains('reddit.com')) return 'reddit';
    if (host.contains('twitter.com') || host.contains('x.com')) return 'x';
    return null;
  }

  bool _isBarcode(String text) {
    final digitsOnly = RegExp(r'^\d+$');
    if (!digitsOnly.hasMatch(text)) return false;
    // Standard barcode lengths: UPC-E (8), UPC-A (12), EAN-13 (13), ITF-14 (14)
    return text.length == 8 || text.length == 12 || text.length == 13 || text.length == 14;
  }

  // ---------------------------------------------------------------------------
  // MIME Detection via Magic Bytes
  // ---------------------------------------------------------------------------

  String _detectMimeType(Uint8List bytes, String? fallbackMime, String filePath) {
    if (bytes.length >= 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    if (bytes.length >= 4 &&
        bytes[0] == 0x25 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x44 &&
        bytes[3] == 0x46) {
      return 'application/pdf';
    }

    // MP4 signature: 'ftyp' at offset 4..8
    if (bytes.length >= 12 &&
        bytes[4] == 0x66 &&
        bytes[5] == 0x74 &&
        bytes[6] == 0x79 &&
        bytes[7] == 0x70) {
      return 'video/mp4';
    }

    // WebM signature: 0x1A 0x45 0xDF 0xA3
    if (bytes.length >= 4 &&
        bytes[0] == 0x1A &&
        bytes[1] == 0x45 &&
        bytes[2] == 0xDF &&
        bytes[3] == 0xA3) {
      return 'video/webm';
    }

    if (fallbackMime != null && fallbackMime.isNotEmpty) {
      return fallbackMime.toLowerCase();
    }

    final lowerPath = filePath.toLowerCase();
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) return 'image/jpeg';
    if (lowerPath.endsWith('.png')) return 'image/png';
    if (lowerPath.endsWith('.webp')) return 'image/webp';
    if (lowerPath.endsWith('.pdf')) return 'application/pdf';
    if (lowerPath.endsWith('.mp4')) return 'video/mp4';
    if (lowerPath.endsWith('.webm')) return 'video/webm';
    if (lowerPath.endsWith('.mp3')) return 'audio/mpeg';
    if (lowerPath.endsWith('.wav')) return 'audio/wav';
    if (lowerPath.endsWith('.m4a')) return 'audio/m4a';
    if (lowerPath.endsWith('.ogg')) return 'audio/ogg';
    if (lowerPath.endsWith('.aac')) return 'audio/aac';

    return 'application/octet-stream';
  }

  bool _isImageMime(String mime) {
    return mime == 'image/jpeg' || mime == 'image/png' || mime == 'image/webp';
  }

  bool _isVideoMime(String mime) {
    return mime == 'video/mp4' || mime == 'video/webm' || mime == 'video/quicktime';
  }

  bool _isAudioMime(String mime) {
    return mime == 'audio/mpeg' ||
        mime == 'audio/mp3' ||
        mime == 'audio/wav' ||
        mime == 'audio/m4a' ||
        mime == 'audio/aac' ||
        mime == 'audio/ogg' ||
        mime == 'audio/x-m4a';
  }

  String _sanitizeText(String input) {
    var sanitized = input;
    final adversarialPatterns = [
      RegExp(r'ignore\s+(all\s+)?(previous|prior)\s+instructions?', caseSensitive: false),
      RegExp(r'system\s*prompt', caseSensitive: false),
      RegExp(r'override\s+(all\s+)?rules?', caseSensitive: false),
      RegExp(r'<\/?(?:system|instruction|admin|prompt)[^>]*>', caseSensitive: false),
    ];
    for (final pattern in adversarialPatterns) {
      sanitized = sanitized.replaceAll(pattern, '[sanitized]');
    }
    return sanitized;
  }

  String _formatBytes(int bytes) {
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}
