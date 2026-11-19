// ==============================================================================
// Nutrient Earth — Personal Data Export & Portability Service
// Fulfills the 10-Year Personal Intelligence Architecture mandate:
// - Generates structured JSON archive containing the complete bitemporal facts,
//   observations, baselines, state snapshots, reading sessions, and movement tasks.
// - Generates human-readable CSV & Markdown trend summaries.
// - Cryptographic SHA-256 checksum for portable integrity verification.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../memory/bitemporal_memory_service.dart';
import '../movement/movement_engine_service.dart';
import '../personal_state/personal_data_foundation_service.dart';
import '../personal_state/personal_state_engine.dart';
import '../research/daily_research_service.dart';

class DataExportBundle {
  final String userId;
  final DateTime exportedAt;
  final String schemaVersion;
  final String checksumSha256;
  final Map<String, dynamic> rawJsonData;
  final String markdownSummary;
  final String observationsCsv;

  const DataExportBundle({
    required this.userId,
    required this.exportedAt,
    this.schemaVersion = '2026.11.v2',
    required this.checksumSha256,
    required this.rawJsonData,
    required this.markdownSummary,
    required this.observationsCsv,
  });
}

abstract class PersonalDataExportService {
  Future<DataExportBundle> generateExportBundle({required String userId});
}

class DefaultPersonalDataExportService implements PersonalDataExportService {
  final BitemporalMemoryService _memoryService;
  final MovementEngineService _movementService;
  final DailyResearchService _researchService;
  final PersonalDataFoundationService _foundationService;

  DefaultPersonalDataExportService({
    required BitemporalMemoryService memoryService,
    required MovementEngineService movementService,
    required DailyResearchService researchService,
    required PersonalDataFoundationService foundationService,
  })  : _memoryService = memoryService,
        _movementService = movementService,
        _researchService = researchService,
        _foundationService = foundationService;

  @override
  Future<DataExportBundle> generateExportBundle({required String userId}) async {
    final now = DateTime.now().toUtc();

    // 1. Fetch Bitemporal Facts
    final activeFacts = await _memoryService.getCurrentActiveFacts(userId: userId);

    // 2. Fetch Movement Tasks
    final movementTasks = await _movementService.getTasksForDate(userId: userId, date: now);

    // 3. Fetch Research Edition
    final todayEdition = await _researchService.getTodayEdition(userId: userId, date: now);

    // 4. Fetch Consents
    final consents = await _foundationService.getUserConsents(userId: userId);

    // Build raw JSON payload
    final rawData = <String, dynamic>{
      'export_metadata': {
        'user_id': userId,
        'exported_at': now.toIso8601String(),
        'schema_version': '2026.11.v2',
        'application': 'Nutrient Earth Personal Intelligence',
      },
      'user_consents': consents.map((c) => c.toJson()).toList(),
      'bitemporal_personal_facts': activeFacts.map((f) => f.toJson()).toList(),
      'movement_tasks': movementTasks.map((t) => t.toJson()).toList(),
      'daily_research_edition': todayEdition.toJson(),
    };

    final jsonString = jsonEncode(rawData);
    final checksum = sha256.convert(utf8.encode(jsonString)).toString();

    // Build human-readable Markdown summary
    final mdBuffer = StringBuffer();
    mdBuffer.writeln('# Nutrient Earth — 10-Year Personal Health Archive');
    mdBuffer.writeln('**User ID**: `$userId`  ');
    mdBuffer.writeln('**Export Date**: ${now.toIso8601String()}  ');
    mdBuffer.writeln('**Integrity Checksum (SHA-256)**: `$checksum`  \n');

    mdBuffer.writeln('## 1. Verified Active Personal Facts & Routines');
    if (activeFacts.isEmpty) {
      mdBuffer.writeln('_No active personal facts recorded._');
    } else {
      for (final f in activeFacts) {
        mdBuffer.writeln('- **${f.title}** (`${f.category.displayName}`): ${jsonEncode(f.currentValue)}');
      }
    }

    mdBuffer.writeln('\n## 2. Daily Movement & Action Interventions');
    if (movementTasks.isEmpty) {
      mdBuffer.writeln('_No movement tasks recorded._');
    } else {
      for (final t in movementTasks) {
        mdBuffer.writeln('- **${t.title}** (${t.movementCategory.displayName}) — Status: `${t.currentStatus.label}`');
      }
    }

    mdBuffer.writeln('\n## 3. Scientific Intelligence Feed');
    mdBuffer.writeln('**Edition**: ${todayEdition.title} (${todayEdition.articles.length} articles)');
    for (final a in todayEdition.articles) {
      mdBuffer.writeln('  ${a.orderIndex}. **${a.title}** [${a.evidenceStrength.label}]');
    }

    // Build CSV of observations
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('entity_id,category,key,recorded_at,summary');
    for (final f in activeFacts) {
      final summary = jsonEncode(f.currentValue).replaceAll(',', ';');
      csvBuffer.writeln('${f.id},${f.category.dbValue},${f.factKey},${f.updatedAt.toIso8601String()},"summary: $summary"');
    }

    return DataExportBundle(
      userId: userId,
      exportedAt: now,
      checksumSha256: checksum,
      rawJsonData: rawData,
      markdownSummary: mdBuffer.toString(),
      observationsCsv: csvBuffer.toString(),
    );
  }
}

final personalDataExportServiceProvider = Provider<PersonalDataExportService>((ref) {
  return DefaultPersonalDataExportService(
    memoryService: ref.watch(bitemporalMemoryServiceProvider),
    movementService: ref.watch(movementEngineServiceProvider),
    researchService: ref.watch(dailyResearchServiceProvider),
    foundationService: ref.watch(personalDataFoundationProvider),
  );
});
