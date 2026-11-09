// ==============================================================================
// Nutrient Earth — Universal Intake Service
// Platform channel integration for Android & iOS native share-sheet intake.
// Enforces:
// 1. Safe parsing of incoming text, URLs, and shared media files.
// 2. Strict size limits and MIME classification through InputClassificationGateway.
// 3. User review gate before saving or executing any consequential action.
// ==============================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/input_gateway/input_classification_gateway.dart';
import '../domain/input_gateway/universal_input_descriptor.dart';

abstract class IntakeService {
  Future<UniversalInputDescriptor?> checkIncomingSharedContent();
}

class PlatformIntakeService implements IntakeService {
  static const MethodChannel _channel = MethodChannel('com.nutrientearth.intake/share');

  final MethodChannel channel;
  final InputClassificationGateway gateway;

  PlatformIntakeService({
    MethodChannel? channel,
    InputClassificationGateway? gateway,
  })  : channel = channel ?? _channel,
        gateway = gateway ?? const InputClassificationGateway();

  @override
  Future<UniversalInputDescriptor?> checkIncomingSharedContent() async {
    if (kIsWeb) return null;

    try {
      final dynamic raw = await channel.invokeMethod('getInitialSharedContent');
      if (raw == null || raw is! Map) return null;

      final map = Map<String, dynamic>.from(raw);
      final type = map['type'] as String?;

      if (type == 'text') {
        final text = map['content'] as String?;
        if (text == null || text.trim().isEmpty) return null;

        final result = gateway.processTextOrUrl(
          text.trim(),
          source: InputSourceType.nativeShareSheet,
        );
        return result.isValid ? result.validatedDescriptor : null;
      }

      if (type == 'file') {
        final uri = map['uri'] as String?;
        final mimeType = map['mimeType'] as String?;
        if (uri == null || uri.trim().isEmpty) return null;

        Uint8List? fileBytes;
        String cleanPath = uri;

        if (cleanPath.startsWith('file://')) {
          cleanPath = cleanPath.replaceFirst('file://', '');
        }

        try {
          final file = File(cleanPath);
          if (await file.exists()) {
            final length = await file.length();
            // Guard against unbounded file sizes (> 100 MB)
            if (length <= InputClassificationGateway.maxVideoSizeBytes) {
              fileBytes = await file.readAsBytes();
            }
          }
        } catch (e) {
          debugPrint('Notice: Direct file read for URI $uri bypassed: $e');
        }

        if (fileBytes != null && fileBytes.isNotEmpty) {
          final result = gateway.processFile(
            filePath: cleanPath,
            fileBytes: fileBytes,
            explicitMimeType: mimeType,
            source: InputSourceType.nativeShareSheet,
            userPrompt: 'Shared file for clinical evidence verification',
          );
          return result.isValid ? result.validatedDescriptor : null;
        }

        // Fallback for platform-managed URIs (e.g. content:// without direct filesystem access)
        return InputClassificationGateway.classifyRawInput(
          rawInput: uri,
          sourceType: InputSourceType.nativeShareSheet,
        );
      }

      if (type == 'multipleFiles') {
        final uris = map['uris'] as List<dynamic>?;
        if (uris == null || uris.isEmpty) return null;

        final firstUri = uris.first.toString();
        return InputClassificationGateway.classifyRawInput(
          rawInput: firstUri,
          sourceType: InputSourceType.nativeShareSheet,
        );
      }
    } on MissingPluginException {
      // Platform channel not registered on this platform or test environment
      return null;
    } catch (e) {
      debugPrint('IntakeService error reading shared content: $e');
      return null;
    }

    return null;
  }
}

final intakeServiceProvider = Provider<IntakeService>((ref) {
  return PlatformIntakeService();
});
