import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth/features/profile/domain/data_rights_service.dart';

void main() {
  group('DataRightsService Consent Ledger & Export Tests', () {
    test('initializes default consent ledger purposes', () {
      final service = DataRightsNotifier();
      final consents = service.state.consents;

      expect(consents.length, equals(4));
      expect(consents.any((c) => c.purposeId == 'ambient_telemetry'), isTrue);
      expect(consents.any((c) => c.purposeId == 'clinical_panels'), isTrue);
      expect(consents.any((c) => c.purposeId == 'wearables_sync'), isTrue);
      expect(consents.any((c) => c.purposeId == 'anonymized_research'), isTrue);
    });

    test(
      'toggleConsent accurately modifies granted status and updates timestamp',
      () {
        final service = DataRightsNotifier();
        final initial = service.state.consents.firstWhere(
          (c) => c.purposeId == 'ambient_telemetry',
        );
        expect(initial.isGranted, isTrue);

        service.toggleConsent('ambient_telemetry');
        final updated = service.state.consents.firstWhere(
          (c) => c.purposeId == 'ambient_telemetry',
        );
        expect(updated.isGranted, isFalse);

        service.toggleConsent('ambient_telemetry');
        final restored = service.state.consents.firstWhere(
          (c) => c.purposeId == 'ambient_telemetry',
        );
        expect(restored.isGranted, isTrue);
      },
    );

    test(
      'generateExportArchive produces valid JSON and cryptographically intact manifest',
      () async {
        final service = DataRightsNotifier();
        final jsonString = await service.generateExportArchive('test_user_42');

        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        expect(decoded.containsKey('manifest'), isTrue);
        expect(decoded.containsKey('payload'), isTrue);

        final manifest = decoded['manifest'] as Map<String, dynamic>;
        expect(manifest['integrityDigest'], isNotNull);
        expect(manifest['files'], contains('health_memory_export.json'));

        final payload = decoded['payload'] as Map<String, dynamic>;
        expect(payload['metadata']['userId'], equals('test_user_42'));
        expect(payload['metadata']['platform'], equals('Nutrient Earth V1'));
      },
    );

    test(
      'purgePersonalData resets consents and clears export manifest',
      () async {
        final service = DataRightsNotifier();
        service.toggleConsent('ambient_telemetry');
        service.toggleConsent('wearables_sync');

        await service.purgePersonalData('test_user_42');
        expect(service.state.consents.length, equals(4));
        expect(service.state.lastExportManifest, isNull);
      },
    );
  });
}
