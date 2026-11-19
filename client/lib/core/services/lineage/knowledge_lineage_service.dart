// ==============================================================================
// Nutrient Earth — Knowledge Lineage Graph Service
// Traverses provenance relationships between:
// Original Input -> Extracted Info -> Personal Fact -> Memory Version ->
// Retrieved Context -> Evidence Document -> Scientific Claim -> Decision -> Recommendation
// Supports multi-hop impact analysis and dependency recomputation tracking.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/supabase_config.dart';
import '../../domain/lineage/knowledge_lineage_models.dart';

abstract class KnowledgeLineageService {
  Future<KnowledgeLineageNode> registerNode({
    required LineageNodeType nodeType,
    required String entityId,
    required String entityTable,
    String? userId,
    required String contentHashSha256,
    String transformationVersion = '1.0',
    Map<String, dynamic> metadata = const {},
  });

  Future<KnowledgeLineageEdge> linkNodes({
    required String sourceNodeId,
    required String targetNodeId,
    required LineageRelationshipType relationshipType,
    String? transformationApplied,
    double confidenceWeight = 1.0,
  });

  Future<List<LineageImpactItem>> getDownstreamImpact({
    required String rootNodeId,
    int maxDepth = 5,
  });

  Future<List<KnowledgeLineageNode>> getUpstreamSources({
    required String targetNodeId,
  });

  Future<List<KnowledgeLineageNode>> findInfluencesOfRecommendation(String recommendationId);

  Future<List<KnowledgeLineageNode>> findDependentArtifactsOfFact(String factId);
}

class DefaultKnowledgeLineageService implements KnowledgeLineageService {
  final SupabaseClient? _supabase;

  // In-memory graph nodes and edges for deterministic unit testing and offline caching
  final Map<String, KnowledgeLineageNode> _nodes = {};
  final List<KnowledgeLineageEdge> _edges = [];

  DefaultKnowledgeLineageService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<KnowledgeLineageNode> registerNode({
    required LineageNodeType nodeType,
    required String entityId,
    required String entityTable,
    String? userId,
    required String contentHashSha256,
    String transformationVersion = '1.0',
    Map<String, dynamic> metadata = const {},
  }) async {
    // Check local cache
    final existing = _nodes.values.cast<KnowledgeLineageNode?>().firstWhere(
      (n) => n?.nodeType == nodeType && n?.entityId == entityId,
      orElse: () => null,
    );
    if (existing != null) {
      return existing;
    }

    final node = KnowledgeLineageNode.create(
      nodeType: nodeType,
      entityId: entityId,
      entityTable: entityTable,
      userId: userId,
      contentHashSha256: contentHashSha256,
      transformationVersion: transformationVersion,
      metadata: metadata,
    );

    _nodes[node.id] = node;

    if (_supabase != null) {
      try {
        await _supabase!.from('knowledge_lineage_nodes').upsert(node.toJson());
      } catch (e) {
        debugPrint('[KnowledgeLineageService] Supabase upsert node error: $e');
      }
    }

    return node;
  }

  @override
  Future<KnowledgeLineageEdge> linkNodes({
    required String sourceNodeId,
    required String targetNodeId,
    required LineageRelationshipType relationshipType,
    String? transformationApplied,
    double confidenceWeight = 1.0,
  }) async {
    // Check if edge already exists
    final existing = _edges.cast<KnowledgeLineageEdge?>().firstWhere(
      (e) =>
          e?.sourceNodeId == sourceNodeId &&
          e?.targetNodeId == targetNodeId &&
          e?.relationshipType == relationshipType,
      orElse: () => null,
    );
    if (existing != null) {
      return existing;
    }

    final edge = KnowledgeLineageEdge.create(
      sourceNodeId: sourceNodeId,
      targetNodeId: targetNodeId,
      relationshipType: relationshipType,
      transformationApplied: transformationApplied,
      confidenceWeight: confidenceWeight,
    );

    _edges.add(edge);

    if (_supabase != null) {
      try {
        await _supabase!.from('knowledge_lineage_edges').upsert(edge.toJson());
      } catch (e) {
        debugPrint('[KnowledgeLineageService] Supabase upsert edge error: $e');
      }
    }

    return edge;
  }

  @override
  Future<List<LineageImpactItem>> getDownstreamImpact({
    required String rootNodeId,
    int maxDepth = 5,
  }) async {
    // In-memory BFS/DFS graph traversal
    final results = <LineageImpactItem>[];
    final visited = <String>{rootNodeId};
    var currentQueue = [rootNodeId];
    int depth = 1;

    while (currentQueue.isNotEmpty && depth <= maxDepth) {
      final nextQueue = <String>[];
      for (final parentId in currentQueue) {
        final outgoingEdges = _edges.where((e) => e.sourceNodeId == parentId);
        for (final edge in outgoingEdges) {
          final targetId = edge.targetNodeId;
          if (!visited.contains(targetId)) {
            visited.add(targetId);
            nextQueue.add(targetId);

            final targetNode = _nodes[targetId];
            if (targetNode != null) {
              results.add(LineageImpactItem(
                depth: depth,
                nodeId: targetNode.id,
                nodeType: targetNode.nodeType,
                entityId: targetNode.entityId,
                entityTable: targetNode.entityTable,
                relationshipType: edge.relationshipType,
              ));
            }
          }
        }
      }
      currentQueue = nextQueue;
      depth++;
    }

    if (_supabase != null && results.isEmpty) {
      try {
        final res = await _supabase!.rpc('get_downstream_impact', params: {
          'p_root_node_id': rootNodeId,
          'p_max_depth': maxDepth,
        });
        if (res is List) {
          return res.map((r) => LineageImpactItem(
            depth: r['depth'] as int,
            nodeId: r['node_id'] as String,
            nodeType: LineageNodeType.fromString(r['node_type'] as String),
            entityId: r['entity_id'] as String,
            entityTable: r['entity_table'] as String,
            relationshipType: LineageRelationshipType.fromString(r['relationship_type'] as String),
          )).toList();
        }
      } catch (e) {
        debugPrint('[KnowledgeLineageService] Supabase get_downstream_impact RPC error: $e');
      }
    }

    return results;
  }

  @override
  Future<List<KnowledgeLineageNode>> getUpstreamSources({
    required String targetNodeId,
  }) async {
    final incomingEdges = _edges.where((e) => e.targetNodeId == targetNodeId);
    final sources = <KnowledgeLineageNode>[];
    for (final edge in incomingEdges) {
      final node = _nodes[edge.sourceNodeId];
      if (node != null) {
        sources.add(node);
      }
    }
    return sources;
  }

  @override
  Future<List<KnowledgeLineageNode>> findInfluencesOfRecommendation(String recommendationId) async {
    // Locate the recommendation node
    final recNode = _nodes.values.cast<KnowledgeLineageNode?>().firstWhere(
      (n) => n?.entityId == recommendationId && n?.nodeType == LineageNodeType.recommendationTask,
      orElse: () => null,
    );
    if (recNode == null) return const [];

    return getUpstreamSources(targetNodeId: recNode.id);
  }

  @override
  Future<List<KnowledgeLineageNode>> findDependentArtifactsOfFact(String factId) async {
    final factNode = _nodes.values.cast<KnowledgeLineageNode?>().firstWhere(
      (n) => n?.entityId == factId,
      orElse: () => null,
    );
    if (factNode == null) return const [];

    final impact = await getDownstreamImpact(rootNodeId: factNode.id);
    final dependentNodes = <KnowledgeLineageNode>[];
    for (final item in impact) {
      final node = _nodes[item.nodeId];
      if (node != null) {
        dependentNodes.add(node);
      }
    }
    return dependentNodes;
  }
}

final knowledgeLineageServiceProvider = Provider<KnowledgeLineageService>((ref) {
  return DefaultKnowledgeLineageService();
});
