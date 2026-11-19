// ==============================================================================
// Nutrient Earth — Forensic Traceability & Knowledge Lineage Tests
// Verifies:
// 1. OpenTelemetry-compatible distributed trace contexts and spans
// 2. Zero-trust baggage sanitization (stripping tokens, passwords, and PII)
// 3. Multi-hop Knowledge Lineage Graph (Nodes, Edges, Provenance Chains)
// 4. Upstream source tracking and downstream impact analysis
// ==============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:nutrient_earth_client/core/domain/lineage/knowledge_lineage_models.dart';
import 'package:nutrient_earth_client/core/domain/traceability/forensic_trace_models.dart';
import 'package:nutrient_earth_client/core/services/lineage/knowledge_lineage_service.dart';
import 'package:nutrient_earth_client/core/services/traceability/forensic_trace_service.dart';

void main() {
  group('Forensic Traceability Tests', () {
    late DefaultForensicTraceService traceService;

    setUp(() {
      traceService = DefaultForensicTraceService(supabase: null);
    });

    test('Starts OpenTelemetry-compatible trace and captures sub-operation spans', () async {
      final trace = traceService.startTrace(
        entryOperationType: 'recipe_evidence_inquiry',
        actorId: 'usr_sarah_trace_test',
        sessionId: 'sess_mobile_app_123',
      );

      expect(trace.traceId.isNotEmpty, isTrue);
      expect(trace.requestId.isNotEmpty, isTrue);
      expect(trace.entryOperationType, equals('recipe_evidence_inquiry'));

      // Start Span 1: Research Retrieval
      final span1 = traceService.startSpan(
        trace: trace,
        operationName: 'pubmed_retrieval',
        serviceComponent: 'research_specialist',
        attributes: {'query_tokens': 5, 'source': 'pubmed'},
      );

      await Future.delayed(const Duration(milliseconds: 10));
      await traceService.endSpan(span1, status: TraceSpanStatus.ok);

      // Start Span 2: Decision Generation (Child span)
      final span2 = traceService.startSpan(
        trace: trace,
        parentSpanId: span1.spanId,
        operationName: 'synthesize_cooking_recommendation',
        serviceComponent: 'food_science_specialist',
      );

      await traceService.endSpan(span2, status: TraceSpanStatus.ok);
      await traceService.endTrace(trace, status: 'succeeded');

      final spans = await traceService.getSpansForTrace(trace.traceId);
      expect(spans.length, equals(2));
      expect(spans[0].operationName, equals('pubmed_retrieval'));
      expect(spans[0].durationMs, isNotNull);
      expect(spans[1].parentSpanId, equals(spans[0].spanId));
    });

    test('Baggage Sanitizer strictly purges tokens, API keys, passwords, and emails', () {
      final rawBaggage = {
        'user_query': 'How to cook ragi for diabetes?',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.secret',
        'api_key': 'ai_gemini_prod_key_999999',
        'user_email': 'sarah.connor@example.com',
        'safe_tag': 'millet_nutrition',
      };

      final sanitized = TraceBaggageSanitizer.sanitizeAttributes(rawBaggage);

      // Credential keys must be completely removed
      expect(sanitized.containsKey('authorization'), isFalse);
      expect(sanitized.containsKey('api_key'), isFalse);

      // PII emails within values must be redacted
      expect(sanitized['user_email'], contains('[REDACTED_SENSITIVE]'));
      expect(sanitized['safe_tag'], equals('millet_nutrition'));
    });
  });

  group('Knowledge Lineage Graph Tests', () {
    late DefaultKnowledgeLineageService lineageService;

    setUp(() {
      lineageService = DefaultKnowledgeLineageService(supabase: null);
    });

    test('Builds multi-hop provenance chain and queries upstream sources and downstream impact', () async {
      // 1. User Input Node
      final inputNode = await lineageService.registerNode(
        nodeType: LineageNodeType.userInput,
        entityId: 'inp_101',
        entityTable: 'user_inputs',
        userId: 'usr_lineage_test',
        contentHashSha256: 'hash_user_question_ragi',
      );

      // 2. Personal Fact Node (Dietary preference)
      final factNode = await lineageService.registerNode(
        nodeType: LineageNodeType.extractedFact,
        entityId: 'fact_ragi_habit',
        entityTable: 'bitemporal_personal_facts',
        userId: 'usr_lineage_test',
        contentHashSha256: 'hash_fact_preference_ragi',
      );

      // 3. Evidence Document Node (PubMed paper on ragi glycemic response)
      final docNode = await lineageService.registerNode(
        nodeType: LineageNodeType.evidenceDocument,
        entityId: 'doc_pmid_18421851',
        entityTable: 'crawled_documents',
        contentHashSha256: 'hash_ragi_clinical_paper',
      );

      // 4. Decision Record Node
      final decisionNode = await lineageService.registerNode(
        nodeType: LineageNodeType.decisionRecord,
        entityId: 'dec_202',
        entityTable: 'decision_records',
        userId: 'usr_lineage_test',
        contentHashSha256: 'hash_decision_ragi_preparation',
      );

      // 5. Recommendation Task Node (Today screen card)
      final recNode = await lineageService.registerNode(
        nodeType: LineageNodeType.recommendationTask,
        entityId: 'rec_303',
        entityTable: 'movement_tasks',
        userId: 'usr_lineage_test',
        contentHashSha256: 'hash_task_ragi_breakfast',
      );

      // Link edges
      await lineageService.linkNodes(
        sourceNodeId: inputNode.id,
        targetNodeId: decisionNode.id,
        relationshipType: LineageRelationshipType.resultedIn,
      );
      await lineageService.linkNodes(
        sourceNodeId: factNode.id,
        targetNodeId: decisionNode.id,
        relationshipType: LineageRelationshipType.influencedBy,
      );
      await lineageService.linkNodes(
        sourceNodeId: docNode.id,
        targetNodeId: decisionNode.id,
        relationshipType: LineageRelationshipType.corroborates,
      );
      await lineageService.linkNodes(
        sourceNodeId: decisionNode.id,
        targetNodeId: recNode.id,
        relationshipType: LineageRelationshipType.resultedIn,
      );

      // Query 1: Which upstream sources influenced the recommendation?
      final upstreamOfDecision = await lineageService.getUpstreamSources(targetNodeId: decisionNode.id);
      expect(upstreamOfDecision.length, equals(3));
      expect(upstreamOfDecision.any((n) => n.nodeType == LineageNodeType.userInput), isTrue);
      expect(upstreamOfDecision.any((n) => n.nodeType == LineageNodeType.extractedFact), isTrue);
      expect(upstreamOfDecision.any((n) => n.nodeType == LineageNodeType.evidenceDocument), isTrue);

      // Query 2: If the personal fact is corrected, which downstream nodes are impacted?
      final impact = await lineageService.getDownstreamImpact(rootNodeId: factNode.id);
      expect(impact.length, equals(2));
      expect(impact.any((i) => i.entityId == 'dec_202'), isTrue);
      expect(impact.any((i) => i.entityId == 'rec_303'), isTrue);
    });
  });
}
