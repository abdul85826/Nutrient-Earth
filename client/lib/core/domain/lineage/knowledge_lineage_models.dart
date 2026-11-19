// ==============================================================================
// Nutrient Earth — Knowledge Lineage Graph Models
// Explicit provenance graph connecting inputs, facts, evidence, decisions,
// recommendations, and outcomes. Supports many-to-many lineage & impact analysis.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum LineageNodeType {
  userInput,
  extractedFact,
  personalMemoryVersion,
  retrievedContext,
  evidenceDocument,
  scientificClaim,
  evidenceAssessment,
  decisionRecord,
  recommendationTask,
  outcomeTelemetry;

  String get value => name;

  static LineageNodeType fromString(String val) {
    return LineageNodeType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => LineageNodeType.userInput,
    );
  }
}

enum LineageRelationshipType {
  extractedFrom,
  versionedAs,
  retrievedFor,
  corroborates,
  contradicts,
  influencedBy,
  resultedIn,
  supersededBy;

  String get value => name;

  static LineageRelationshipType fromString(String val) {
    return LineageRelationshipType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => LineageRelationshipType.influencedBy,
    );
  }
}

class KnowledgeLineageNode {
  final String id;
  final LineageNodeType nodeType;
  final String entityId;
  final String entityTable;
  final String? userId;
  final String contentHashSha256;
  final String transformationVersion;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const KnowledgeLineageNode({
    required this.id,
    required this.nodeType,
    required this.entityId,
    required this.entityTable,
    this.userId,
    required this.contentHashSha256,
    this.transformationVersion = '1.0',
    this.metadata = const {},
    required this.createdAt,
  });

  factory KnowledgeLineageNode.create({
    required LineageNodeType nodeType,
    required String entityId,
    required String entityTable,
    String? userId,
    required String contentHashSha256,
    String transformationVersion = '1.0',
    Map<String, dynamic> metadata = const {},
  }) {
    return KnowledgeLineageNode(
      id: const Uuid().v4(),
      nodeType: nodeType,
      entityId: entityId,
      entityTable: entityTable,
      userId: userId,
      contentHashSha256: contentHashSha256,
      transformationVersion: transformationVersion,
      metadata: metadata,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'node_type': nodeType.value,
      'entity_id': entityId,
      'entity_table': entityTable,
      'user_id': userId,
      'content_hash_sha256': contentHashSha256,
      'transformation_version': transformationVersion,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class KnowledgeLineageEdge {
  final String id;
  final String sourceNodeId;
  final String targetNodeId;
  final LineageRelationshipType relationshipType;
  final String? transformationApplied;
  final double confidenceWeight;
  final DateTime createdAt;

  const KnowledgeLineageEdge({
    required this.id,
    required this.sourceNodeId,
    required this.targetNodeId,
    required this.relationshipType,
    this.transformationApplied,
    this.confidenceWeight = 1.0,
    required this.createdAt,
  });

  factory KnowledgeLineageEdge.create({
    required String sourceNodeId,
    required String targetNodeId,
    required LineageRelationshipType relationshipType,
    String? transformationApplied,
    double confidenceWeight = 1.0,
  }) {
    return KnowledgeLineageEdge(
      id: const Uuid().v4(),
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      relationshipType: relationshipType,
      transformationApplied: transformationApplied,
      confidenceWeight: confidenceWeight,
      createdAt: DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_node_id': sourceNodeId,
      'target_node_id': targetNodeId,
      'relationship_type': relationshipType.value,
      'transformation_applied': transformationApplied,
      'confidence_weight': confidenceWeight,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class LineageImpactItem {
  final int depth;
  final String nodeId;
  final LineageNodeType nodeType;
  final String entityId;
  final String entityTable;
  final LineageRelationshipType relationshipType;

  const LineageImpactItem({
    required this.depth,
    required this.nodeId,
    required this.nodeType,
    required this.entityId,
    required this.entityTable,
    required this.relationshipType,
  });
}
