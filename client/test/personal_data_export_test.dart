// ==============================================================================
// Nutrient Earth — Personal Data Export & Portability Tests
// Verifies:
// 1. Generation of comprehensive JSON data bundle
// 2. Cryptographic SHA-256 tamper-evident checksum
// 3. Markdown and CSV export generation
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:nutrient_earth_client/core/domain/memory/bitemporal_memory_models.dart';
import 'package:nutrient_earth_client/core/services/export/personal_data_export_service.dart';
import 'package:nutrient_earth_client/core/services/memory/bitemporal_memory_service.dart';
import 'package:nutrient_earth_client/core/services/movement/movement_engine_service.dart';
import 'package:nutrient_earth_client/core/services/personal_state/personal_data_foundation_service.dart';
import 'package:nutrient_earth_client/core/services/research/daily_research_service.dart';

void main() {
  group('Personal Data Export & Portability Tests', () {
    late DefaultPersonalDataExportService exportService;
    late SupabaseBitemporalMemoryService memoryService;
    late SupabaseMovementEngineService movementService;
    late SupabaseDailyResearchService researchService;
    late SupabasePersonalDataFoundationService foundationService;

    const testUserId = 'usr_test_data_export';

    setUp(() {
      memoryService = SupabaseBitemporalMemoryService(supabase: null);
      movementService = SupabaseMovementEngineService(supabase: null);
      researchService = SupabaseDailyResearchService(supabase: null);
      foundationService = SupabasePersonalDataFoundationService(supabase: null);

      exportService = DefaultPersonalDataExportService(
        memoryService: memoryService,
        movementService: movementService,
        researchService: researchService,
        foundationService: foundationService,
      );
    });

    test('Generates complete data export bundle with valid SHA-256 checksum', () async {
      // 1. Seed sample data
      await memoryService.recordFact(
        userId: testUserId,
        category: FactCategory.routine,
        factKey: 'sleep.target_hours',
        title: 'Target Sleep Duration',
        factValue: {'hours': 8.0},
        validFrom: DateTime.utc(2024, 1, 1),
      );

      // 2. Generate export bundle
      final bundle = await exportService.generateExportBundle(userId: testUserId);

      expect(bundle.userId, equals(testUserId));
      expect(bundle.schemaVersion, equals('2026.11.v2'));
      expect(bundle.checksumSha256, hasLength(64)); // Valid SHA-256 hex string

      // Verify JSON payload contents
      expect(bundle.rawJsonData['export_metadata'], isNotNull);
      expect(bundle.rawJsonData['bitemporal_personal_facts'], isList);
      expect(bundle.rawJsonData['movement_tasks'], isList);
      expect(bundle.rawJsonData['daily_research_edition'], isNotNull);

      // Verify Markdown summary
      expect(bundle.markdownSummary, contains('Nutrient Earth — 10-Year Personal Health Archive'));
      expect(bundle.markdownSummary, contains('Target Sleep Duration'));
      expect(bundle.markdownSummary, contains(bundle.checksumSha256));

      // Verify CSV observations
      expect(bundle.observationsCsv, contains('entity_id,category,key,recorded_at,summary'));
      expect(bundle.observationsCsv, contains('sleep.target_hours'));
    });
  });
}
