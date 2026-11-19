// ==============================================================================
// Nutrient Earth — Universal Content Ingestion Service
// Ingests Text, Images, Barcodes, URLs, PDFs, Audio, Video, and Shared Content.
// Generates durable audit records with SHA-256 content hashes, MIME types, and provenance.
// ==============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/ingestion/universal_ingestion_models.dart';

abstract class UniversalContentIngestionService {
  Future<ContentIngestionRecord> ingestContent({
    String? userId,
    required UniversalContentType contentType,
    required String sourceReference,
    required String detectedFormat,
    String originalLanguage = 'en',
    Uint8List? rawBytes,
    String? textPayload,
    Map<String, dynamic> provenanceMetadata = const {},
  });

  Future<ContentIngestionRecord?> getIngestionRecord(String id);

  String computeContentHash(Uint8List bytes);
}

class DefaultUniversalContentIngestionService implements UniversalContentIngestionService {
  final SupabaseClient? _supabase;

  // In-memory registry for deterministic test execution and offline capability
  final Map<String, ContentIngestionRecord> _ingestionStore = {};

  DefaultUniversalContentIngestionService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  String computeContentHash(Uint8List bytes) {
    return sha256.convert(bytes).toString();
  }

  @override
  Future<ContentIngestionRecord> ingestContent({
    String? userId,
    required UniversalContentType contentType,
    required String sourceReference,
    required String detectedFormat,
    String originalLanguage = 'en',
    Uint8List? rawBytes,
    String? textPayload,
    Map<String, dynamic> provenanceMetadata = const {},
  }) async {
    // 1. Calculate cryptographic integrity hash
    String hash;
    if (rawBytes != null && rawBytes.isNotEmpty) {
      hash = computeContentHash(rawBytes);
    } else if (textPayload != null && textPayload.isNotEmpty) {
      hash = computeContentHash(Uint8List.fromList(utf8.encode(textPayload)));
    } else {
      hash = computeContentHash(Uint8List.fromList(utf8.encode(sourceReference)));
    }

    // 2. Build durable record
    final record = ContentIngestionRecord.create(
      userId: userId,
      contentType: contentType,
      sourceReference: sourceReference,
      detectedFormat: detectedFormat,
      originalLanguage: originalLanguage,
      contentHashSha256: hash,
      extractionVersion: 'v1.0.0',
      provenanceMetadata: {
        ...provenanceMetadata,
        'byte_length': rawBytes?.length ?? textPayload?.length ?? 0,
        'client_ingest_time': DateTime.now().toUtc().toIso8601String(),
      },
    );

    _ingestionStore[record.id] = record;

    if (_supabase != null) {
      try {
        await _supabase!.from('content_ingestion_records').insert(record.toJson());
      } catch (e) {
        debugPrint('[UniversalContentIngestionService] Supabase insert error: $e');
      }
    }

    return record;
  }

  @override
  Future<ContentIngestionRecord?> getIngestionRecord(String id) async {
    if (_ingestionStore.containsKey(id)) {
      return _ingestionStore[id];
    }

    if (_supabase != null) {
      try {
        final data = await _supabase!
            .from('content_ingestion_records')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null) {
          final record = ContentIngestionRecord(
            id: data['id'] as String,
            userId: data['user_id'] as String?,
            contentType: UniversalContentType.fromString(data['content_type'] as String),
            sourceReference: data['source_reference'] as String,
            detectedFormat: data['detected_format'] as String,
            originalLanguage: data['original_language'] as String? ?? 'en',
            contentHashSha256: data['content_hash_sha256'] as String,
            extractionStatus: data['extraction_status'] as String? ?? 'extracted',
            extractionVersion: data['extraction_version'] as String? ?? 'v1.0.0',
            provenanceMetadata: Map<String, dynamic>.from(data['provenance_metadata'] ?? {}),
            createdAt: DateTime.parse(data['created_at'] as String),
          );
          _ingestionStore[record.id] = record;
          return record;
        }
      } catch (e) {
        debugPrint('[UniversalContentIngestionService] Supabase get error: $e');
      }
    }

    return null;
  }
}

final universalContentIngestionServiceProvider = Provider<UniversalContentIngestionService>((ref) {
  return DefaultUniversalContentIngestionService();
});
