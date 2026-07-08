import 'dart:io';

void main() {
  final file = File('lib/domain/models/biological_twin/biological_models.dart');
  var content = file.readAsStringSync();
  content = "import '../../core/utils/hash_utils.dart';\n$content";
  
  // For each class, replace Id id = Isar.autoIncrement; with Id get id => fastHash('\${userId}_\${metadata.timestamp.millisecondsSinceEpoch}');
  content = content.replaceAll(
    'Id id = Isar.autoIncrement;',
    "Id get id => fastHash('\${userId}_\${metadata.timestamp.millisecondsSinceEpoch}');"
  );
  
  // BiologicalState has 'stateId' instead of just userId, wait, BiologicalState has userId. 
  // Let's check BiologicalState: it has userId. So the above works.
  
  file.writeAsStringSync(content);
  print('biological_models.dart updated');
  
  final schemaFile = File('lib/infrastructure/local/isar_schemas.dart');
  var schemaContent = schemaFile.readAsStringSync();
  schemaContent = "import '../../core/utils/hash_utils.dart';\n$schemaContent";
  
  schemaContent = schemaContent.replaceAll(
    'class IsarIdentity {\n  Id id = Isar.autoIncrement;',
    'class IsarIdentity {\n  Id get id => fastHash(uuid);'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarBiologicalState {\n  Id id = Isar.autoIncrement;',
    'class IsarBiologicalState {\n  Id get id => fastHash(stateId);'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarBiologicalEvent {\n  Id id = Isar.autoIncrement;',
    'class IsarBiologicalEvent {\n  Id get id => fastHash(eventId);'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarRecommendation {\n  Id id = Isar.autoIncrement;',
    'class IsarRecommendation {\n  Id get id => fastHash(recommendationId);'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarWearableSnapshot {\n  Id id = Isar.autoIncrement;',
    'class IsarWearableSnapshot {\n  Id get id => fastHash(\'\${userId}_\${snapshotTime.millisecondsSinceEpoch}\');'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarSyncJob {\n  Id id = Isar.autoIncrement;',
    'class IsarSyncJob {\n  Id get id => fastHash(\'\${collectionName}_\${recordId}_\${queuedAt.millisecondsSinceEpoch}\');'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarConflict {\n  Id id = Isar.autoIncrement;',
    'class IsarConflict {\n  Id get id => fastHash(\'\${entityId}_\${detectedAt.millisecondsSinceEpoch}\');'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarTimelineFragment {\n  Id id = Isar.autoIncrement;',
    'class IsarTimelineFragment {\n  Id get id => fastHash(\'\${userId}_\${periodStart.millisecondsSinceEpoch}\');'
  );
  schemaContent = schemaContent.replaceAll(
    'class IsarUncertaintySnapshot {\n  Id id = Isar.autoIncrement;',
    'class IsarUncertaintySnapshot {\n  Id get id => fastHash(\'\${stateId}_\${capturedAt.millisecondsSinceEpoch}\');'
  );

  schemaFile.writeAsStringSync(schemaContent);
  print('isar_schemas.dart updated');
}
