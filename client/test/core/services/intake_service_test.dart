// ==============================================================================
// Nutrient Earth — Universal Intake Service Test Suite
// Verifies:
// 1. Handling of incoming native shared text and URL payloads.
// 2. Safe handling of shared file paths and URIs.
// 3. Graceful fallback when platform channel is unregistered or throws.
// ==============================================================================

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/services/intake_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channelName = 'com.nutrientearth.intake/share';

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), null);
  });

  group('Universal Intake Service', () {
    test('Returns null when no shared content is pending', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (MethodCall call) async {
        if (call.method == 'getInitialSharedContent') {
          return null;
        }
        return null;
      });

      final service = PlatformIntakeService();
      final result = await service.checkIncomingSharedContent();
      expect(result, isNull);
    });

    test('Parses incoming shared text into valid UniversalInputDescriptor with nativeShareSheet source', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (MethodCall call) async {
        if (call.method == 'getInitialSharedContent') {
          return {
            'type': 'text',
            'content': 'Should I take vitamin D3 with K2 for arterial health?',
          };
        }
        return null;
      });

      final service = PlatformIntakeService();
      final result = await service.checkIncomingSharedContent();
      expect(result, isNotNull);
      expect(result!.source, equals(InputSourceType.nativeShareSheet));
      expect(result.type, equals(UserInputType.text));
      expect(result.effectiveQuery, contains('vitamin D3 with K2'));
    });

    test('Parses incoming shared URL into valid UniversalInputDescriptor', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (MethodCall call) async {
        if (call.method == 'getInitialSharedContent') {
          return {
            'type': 'text',
            'content': 'https://pubmed.ncbi.nlm.nih.gov/30056849/',
          };
        }
        return null;
      });

      final service = PlatformIntakeService();
      final result = await service.checkIncomingSharedContent();
      expect(result, isNotNull);
      expect(result!.source, equals(InputSourceType.nativeShareSheet));
      expect(result.type, equals(UserInputType.webUrl));
    });

    test('Parses incoming shared file URI into valid descriptor', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (MethodCall call) async {
        if (call.method == 'getInitialSharedContent') {
          return {
            'type': 'file',
            'uri': 'content://media/external/images/media/421',
            'mimeType': 'image/jpeg',
          };
        }
        return null;
      });

      final service = PlatformIntakeService();
      final result = await service.checkIncomingSharedContent();
      expect(result, isNotNull);
      expect(result!.source, equals(InputSourceType.nativeShareSheet));
    });

    test('Handles channel exceptions gracefully without throwing', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel(channelName), (MethodCall call) async {
        throw PlatformException(code: 'UNAVAILABLE', message: 'Channel crashed');
      });

      final service = PlatformIntakeService();
      final result = await service.checkIncomingSharedContent();
      expect(result, isNull);
    });
  });
}

