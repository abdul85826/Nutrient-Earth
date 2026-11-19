// ==============================================================================
// Nutrient Earth — Universal Content Ingestion Models
// Captures durable processing records across Text, Images, Barcodes, URLs,
// PDFs, Audio, Video, and Shared Content with SHA-256 integrity and provenance.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum UniversalContentType {
  textQuery,
  productImage,
  barcode,
  websiteUrl,
  pdfDocument,
  audioVoice,
  videoMedia,
  sharedContent;

  String get value => name;

  static UniversalContentType fromString(String val) {
    return UniversalContentType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase().replaceAll('_', ''),
      orElse: () => UniversalContentType.textQuery,
    );
  }
}

class ContentIngestionRecord {
  final String id;
  final String? userId;
  final UniversalContentType contentType;
  final String sourceReference; // URL, file path, barcode string, or SHA key
  final String detectedFormat; // 'image/jpeg', 'application/pdf', 'audio/mp4', 'text/html'
  final String originalLanguage;
  final String contentHashSha256;
  final String extractionStatus; // 'pending', 'extracted', 'failed', 'flagged_untrusted'
  final String extractionVersion;
  final Map<String, dynamic> provenanceMetadata;
  final DateTime createdAt;

  const ContentIngestionRecord({
    required this.id,
    this.userId,
    required this.contentType,
    required this.sourceReference,
    required this.detectedFormat,
    this.originalLanguage = 'en',
    required this.contentHashSha256,
    this.extractionStatus = 'extracted',
    this.extractionVersion = 'v1.0.0',
    this.provenanceMetadata = const {},
    required this.createdAt,
  });

  factory ContentIngestionRecord.create({
    String? userId,
    required UniversalContentType contentType,
    required String sourceReference,
    required String detectedFormat,
    String originalLanguage = 'en',
    required String contentHashSha256,
    String extractionVersion = 'v1.0.0',
    Map<String, dynamic> provenanceMetadata = const {},
  }) {
    return ContentIngestionRecord(
      id: const Uuid().v4(),
      userId: userId,
      contentType: contentType,
      sourceReference: sourceReference,
      detectedFormat: detectedFormat,
      originalLanguage: originalLanguage,
      contentHashSha256: contentHashSha256,
      extractionStatus: 'extracted',
      extractionVersion: extractionVersion,
      provenanceMetadata: provenanceMetadata,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'content_type': contentType.value,
        'source_reference': sourceReference,
        'detected_format': detectedFormat,
        'original_language': originalLanguage,
        'content_hash_sha256': contentHashSha256,
        'extraction_status': extractionStatus,
        'extraction_version': extractionVersion,
        'provenance_metadata': provenanceMetadata,
        'created_at': createdAt.toIso8601String(),
      };
}
