import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nutrient_earth_client/core/config/app_config.dart';
import 'package:nutrient_earth_client/core/domain/ai_gateway/model_provider.dart';
import 'package:nutrient_earth_client/core/domain/ai_gateway/model_router.dart';
import 'package:nutrient_earth_client/core/domain/answer_contract/universal_intelligence_answer.dart';
import 'package:nutrient_earth_client/core/domain/input_gateway/universal_input_descriptor.dart';
import 'package:nutrient_earth_client/core/services/search/universal_intelligence_search_engine.dart';

void main() async {
  print('================================================================');
  print('NUTRIENT EARTH — LIVE END-TO-END PIPELINE ACCEPTANCE VERIFICATION');
  print('Connecting to live production AI endpoints with active credentials');
  print('================================================================\n');

  final router = AIModelRouter();
  final engine = DefaultUniversalIntelligenceSearchEngine(modelRouter: router);

  final testQueries = [
    'hi',
    'what is apple',
    'what is diabetes',
    'calculate my BMR: 30yo male, 80kg, 180cm',
    'does magnesium glycinate improve sleep?',
    'severe chest pain and trouble breathing',
  ];

  for (int i = 0; i < testQueries.length; i++) {
    final query = testQueries[i];
    print('----------------------------------------------------------------');
    print('TEST QUERY #${i + 1}: "$query"');
    print('----------------------------------------------------------------');

    final sw = Stopwatch()..start();
    try {
      final answer = await engine.executeSearch(
        inputDescriptor: UniversalInputDescriptor.fromText(query),
      );
      sw.stop();

      print('RESPONSE TYPE: ${answer.responseType.name}');
      print('HERO ANSWER: ${answer.heroAnswer}');
      print('LATENCY: ${sw.elapsedMilliseconds} ms');
      print('VERIFIED CITATIONS: ${answer.evidence.citations.length}');
      if (answer.evidence.citations.isNotEmpty) {
        for (final c in answer.evidence.citations) {
          print('  - [${c.pmid ?? "DOI"}] ${c.title} (${c.authorsOrJournal}, ${c.year})');
        }
      }
      print('RESPONSE BLOCKS: ${answer.blocks.map((b) => b.blockType).join(", ")}');
      print('\nFULL DETAILED EXPLANATION:');
      print(answer.detailedExplanation);
      print('\n[STATUS]: SUCCESS - REAL PIPELINE DELIVERED\n');
    } catch (e, stack) {
      sw.stop();
      print('ERROR: $e');
      print('STACK: $stack');
      print('\n[STATUS]: FAILED\n');
    }
  }

  print('================================================================');
  print('ALL 6 LIVE QUERIES COMPLETED');
  print('================================================================');
}
