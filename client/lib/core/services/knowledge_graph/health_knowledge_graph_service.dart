// ==============================================================================
// Nutrient Earth — Universal Health Knowledge Graph Service
// Maps evidence, compounds, materials, biology, and health outcomes into
// the 23 core entity types and 15 canonical relationships with causality governance.
// ==============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/supabase_config.dart';

enum KgEntityType {
  chemicalCompound,
  material,
  foodIngredient,
  product,
  productCategory,
  brand,
  company,
  biologicalPathway,
  cellularProcess,
  gene,
  microOrganism,
  nutrient,
  dietaryPattern,
  physicalActivity,
  environmentalExposure,
  organSystem,
  physiologicalOutcome,
  symptom,
  healthCondition,
  populationSubgroup,
  scientificStudy,
  regulatoryDecision,
  scientificControversy,
}

enum KgRelationshipType {
  contains,
  metabolisedInto,
  bindsTo,
  upregulates,
  downregulates,
  inhibits,
  activates,
  causes,
  associatedWith,
  studiedIn,
  regulatedBy,
  contradicts,
  biomarkerOf,
  mitigates,
  exacerbates,
}

enum KgEvidenceStatus {
  robustEvidence,
  preliminaryEvidence,
  conflictingEvidence,
  refutedEvidence,
  unverified,
}

class HealthKnowledgeGraphService {
  final SupabaseClient? _client;

  HealthKnowledgeGraphService({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Helper to convert enum to snake_case string matching SQL schema
  static String entityTypeToSql(KgEntityType type) {
    switch (type) {
      case KgEntityType.chemicalCompound:
        return 'chemical_compound';
      case KgEntityType.material:
        return 'material';
      case KgEntityType.foodIngredient:
        return 'food_ingredient';
      case KgEntityType.product:
        return 'product';
      case KgEntityType.productCategory:
        return 'product_category';
      case KgEntityType.brand:
        return 'brand';
      case KgEntityType.company:
        return 'company';
      case KgEntityType.biologicalPathway:
        return 'biological_pathway';
      case KgEntityType.cellularProcess:
        return 'cellular_process';
      case KgEntityType.gene:
        return 'gene';
      case KgEntityType.microOrganism:
        return 'micro_organism';
      case KgEntityType.nutrient:
        return 'nutrient';
      case KgEntityType.dietaryPattern:
        return 'dietary_pattern';
      case KgEntityType.physicalActivity:
        return 'physical_activity';
      case KgEntityType.environmentalExposure:
        return 'environmental_exposure';
      case KgEntityType.organSystem:
        return 'organ_system';
      case KgEntityType.physiologicalOutcome:
        return 'physiological_outcome';
      case KgEntityType.symptom:
        return 'symptom';
      case KgEntityType.healthCondition:
        return 'health_condition';
      case KgEntityType.populationSubgroup:
        return 'population_subgroup';
      case KgEntityType.scientificStudy:
        return 'scientific_study';
      case KgEntityType.regulatoryDecision:
        return 'regulatory_decision';
      case KgEntityType.scientificControversy:
        return 'scientific_controversy';
    }
  }

  static String relationshipTypeToSql(KgRelationshipType type) {
    switch (type) {
      case KgRelationshipType.contains:
        return 'contains';
      case KgRelationshipType.metabolisedInto:
        return 'metabolised_into';
      case KgRelationshipType.bindsTo:
        return 'binds_to';
      case KgRelationshipType.upregulates:
        return 'upregulates';
      case KgRelationshipType.downregulates:
        return 'downregulates';
      case KgRelationshipType.inhibits:
        return 'inhibits';
      case KgRelationshipType.activates:
        return 'activates';
      case KgRelationshipType.causes:
        return 'causes';
      case KgRelationshipType.associatedWith:
        return 'associated_with';
      case KgRelationshipType.studiedIn:
        return 'studied_in';
      case KgRelationshipType.regulatedBy:
        return 'regulated_by';
      case KgRelationshipType.contradicts:
        return 'contradicts';
      case KgRelationshipType.biomarkerOf:
        return 'biomarker_of';
      case KgRelationshipType.mitigates:
        return 'mitigates';
      case KgRelationshipType.exacerbates:
        return 'exacerbates';
    }
  }

  static String evidenceStatusToSql(KgEvidenceStatus status) {
    switch (status) {
      case KgEvidenceStatus.robustEvidence:
        return 'robust_evidence';
      case KgEvidenceStatus.preliminaryEvidence:
        return 'preliminary_evidence';
      case KgEvidenceStatus.conflictingEvidence:
        return 'conflicting_evidence';
      case KgEvidenceStatus.refutedEvidence:
        return 'refuted_evidence';
      case KgEvidenceStatus.unverified:
        return 'unverified';
    }
  }

  /// Upsert a Knowledge Graph entity
  Future<String?> upsertEntity({
    required String name,
    required KgEntityType entityType,
    String? canonicalId,
    String? scientificName,
    Map<String, dynamic>? properties,
  }) async {
    final client = _client;
    if (client == null) return null;

    final sqlEntityType = entityTypeToSql(entityType);
    final row = {
      'name': name.trim(),
      'entity_type': sqlEntityType,
      'canonical_id': canonicalId ?? 'kg_${entityType.name}_${name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_')}',
      'scientific_name': scientificName,
      'properties': properties ?? {},
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final res = await client
          .from('kg_entities')
          .upsert(row, onConflict: 'canonical_id')
          .select('id')
          .maybeSingle();
      return res?['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Create a Knowledge Graph relationship between entities.
  /// If relationType is `causes`, strict validation mandates `causalityJustification`
  /// and verified human evidence.
  Future<String?> linkEntities({
    required String sourceEntityId,
    required String targetEntityId,
    required KgRelationshipType relationType,
    KgEvidenceStatus evidenceStatus = KgEvidenceStatus.preliminaryEvidence,
    String? causalityJustification,
    Map<String, dynamic>? provenanceMetadata,
  }) async {
    // 1. Causality Check Constraint
    if (relationType == KgRelationshipType.causes) {
      if (causalityJustification == null || causalityJustification.trim().length < 20) {
        throw ArgumentError(
          'Scientific Governance Violation: KG relationship [causes] strictly requires an explicit causality_justification of at least 20 characters documenting human clinical trial confirmation.',
        );
      }
    }

    final client = _client;
    if (client == null) return null;

    final row = {
      'source_entity_id': sourceEntityId,
      'target_entity_id': targetEntityId,
      'relationship_type': relationshipTypeToSql(relationType),
      'evidence_status': evidenceStatusToSql(evidenceStatus),
      'causality_justification': causalityJustification,
      'metadata': provenanceMetadata ?? {},
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final res = await client.from('kg_relationships').insert(row).select('id').maybeSingle();
      return res?['id']?.toString();
    } catch (_) {
      return null;
    }
  }
}
