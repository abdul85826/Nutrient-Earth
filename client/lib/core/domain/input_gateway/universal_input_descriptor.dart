// ==============================================================================
// Nutrient Earth — Universal Input Descriptor & Classification Contracts
// Core domain representations for multimodal inputs: Text, Image, Video Upload,
// Social URL, Document, Product, Barcode, and Health Data.
// ==============================================================================

import 'dart:typed_data';

/// Canonical input categories for Nutrient Earth.
enum UserInputType {
  text,
  image,
  videoUpload,
  socialVideoUrl,
  webUrl,
  documentPdf,
  productQuery,
  barcode,
  healthData,
  audio;

  String get displayName {
    switch (this) {
      case UserInputType.text:
        return 'Natural Language Inquiry';
      case UserInputType.image:
        return 'Product or Meal Image';
      case UserInputType.videoUpload:
        return 'Uploaded Video File';
      case UserInputType.socialVideoUrl:
        return 'Social Media Video Link';
      case UserInputType.webUrl:
        return 'Web Publication Link';
      case UserInputType.documentPdf:
        return 'Scientific Document / PDF';
      case UserInputType.productQuery:
        return 'Product Name Inquiry';
      case UserInputType.barcode:
        return 'Product Barcode';
      case UserInputType.healthData:
        return 'Connected Device Health Data';
      case UserInputType.audio:
        return 'Audio & Voice Inquiry';
    }
  }
}

/// The capture origin of the user input.
enum InputSourceType {
  userText,
  cameraCapture,
  galleryUpload,
  filePicker,
  clipboardUrl,
  barcodeScanner,
  sensorSync,
  microphone,
  audioFile,
  nativeShareSheet;
}

/// Validation outcomes for the security gateway.
enum InputValidationStatus {
  valid,
  emptyPayload,
  oversizedFile,
  unsupportedMimeType,
  invalidUrlScheme,
  ssrfBlocked,
  malformedBarcode,
  securityViolation;

  bool get isValid => this == InputValidationStatus.valid;
}

/// Detailed validation and sanitization result.
class InputValidationResult {
  final InputValidationStatus status;
  final String? errorMessage;
  final UniversalInputDescriptor? validatedDescriptor;

  const InputValidationResult.valid(this.validatedDescriptor)
      : status = InputValidationStatus.valid,
        errorMessage = null;

  const InputValidationResult.invalid({
    required this.status,
    required this.errorMessage,
  }) : validatedDescriptor = null;

  bool get isSuccess => status.isValid && validatedDescriptor != null;
  bool get isValid => isSuccess;
}

/// An immutable, validated multimodal input descriptor.
class UniversalInputDescriptor {
  final String id;
  final UserInputType type;
  final InputSourceType source;
  final String rawContent;
  final String? sanitizedContent;
  final String? filePath;
  final Uint8List? fileBytes;
  final String? mimeType;
  final int? fileSizeBytes;
  final String? targetUrl;
  final String? socialPlatform; // 'youtube', 'instagram', 'tiktok', etc.
  final String? barcodeValue;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const UniversalInputDescriptor({
    required this.id,
    required this.type,
    required this.source,
    required this.rawContent,
    this.sanitizedContent,
    this.filePath,
    this.fileBytes,
    this.mimeType,
    this.fileSizeBytes,
    this.targetUrl,
    this.socialPlatform,
    this.barcodeValue,
    this.metadata = const {},
    required this.createdAt,
  });

  /// Convenience factory to create a text query descriptor
  factory UniversalInputDescriptor.fromText(
    String text, {
    String? id,
    InputSourceType source = InputSourceType.userText,
  }) {
    return UniversalInputDescriptor(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: UserInputType.text,
      source: source,
      rawContent: text,
      sanitizedContent: text.trim(),
      createdAt: DateTime.now(),
    );
  }

  /// Convenience factory to create a barcode descriptor
  factory UniversalInputDescriptor.fromBarcode(
    String barcode, {
    String? id,
    InputSourceType source = InputSourceType.barcodeScanner,
  }) {
    return UniversalInputDescriptor(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: UserInputType.barcode,
      source: source,
      rawContent: barcode,
      barcodeValue: barcode,
      sanitizedContent: barcode.trim(),
      createdAt: DateTime.now(),
    );
  }

  /// The effective text query to be passed to orchestrators or search engines.
  String get effectiveQuery => sanitizedContent ?? rawContent;

  /// Alias getters for API compatibility.
  UserInputType get inputType => type;
  String get rawPayload => rawContent;

  /// Whether this input is an image.
  bool get isImage => type == UserInputType.image;

  /// Whether this input requires specialized heavy binary processing (video or vision).
  bool get isHeavyMedia =>
      type == UserInputType.videoUpload || type == UserInputType.image || type == UserInputType.documentPdf;

  /// Whether this input is a URL requiring network fetching.
  bool get isRemoteUrl => type == UserInputType.socialVideoUrl || type == UserInputType.webUrl;

  UniversalInputDescriptor copyWith({
    String? id,
    UserInputType? type,
    InputSourceType? source,
    String? rawContent,
    String? sanitizedContent,
    String? filePath,
    Uint8List? fileBytes,
    String? mimeType,
    int? fileSizeBytes,
    String? targetUrl,
    String? socialPlatform,
    String? barcodeValue,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return UniversalInputDescriptor(
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      rawContent: rawContent ?? this.rawContent,
      sanitizedContent: sanitizedContent ?? this.sanitizedContent,
      filePath: filePath ?? this.filePath,
      fileBytes: fileBytes ?? this.fileBytes,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      targetUrl: targetUrl ?? this.targetUrl,
      socialPlatform: socialPlatform ?? this.socialPlatform,
      barcodeValue: barcodeValue ?? this.barcodeValue,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'source': source.name,
        'rawContent': rawContent,
        'sanitizedContent': sanitizedContent,
        'filePath': filePath,
        'mimeType': mimeType,
        'fileSizeBytes': fileSizeBytes,
        'targetUrl': targetUrl,
        'socialPlatform': socialPlatform,
        'barcodeValue': barcodeValue,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
      };
}
