// ==============================================================================
// Nutrient Earth — Direct OpenAlex Client (REST API)
// Zero MCP Dependency: Native REST Client for open scientific knowledge graph,
// works metadata, citation graph metrics, and open-access verification.
// ==============================================================================

import 'package:http/http.dart' as http;
import 'direct_source_client.dart';

class OpenAlexWorkRecord {
  final String id;
  final String? doi;
  final String title;
  final int publicationYear;
  final int citedByCount;
  final String? primaryLocationSource;
  final bool isOa;
  final List<String> concepts;
  final String rawSha256;

  const OpenAlexWorkRecord({
    required this.id,
    this.doi,
    required this.title,
    required this.publicationYear,
    this.citedByCount = 0,
    this.primaryLocationSource,
    this.isOa = false,
    this.concepts = const [],
    required this.rawSha256,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'doi': doi,
        'title': title,
        'publicationYear': publicationYear,
        'citedByCount': citedByCount,
        'primaryLocationSource': primaryLocationSource,
        'isOa': isOa,
        'concepts': concepts,
        'rawSha256': rawSha256,
      };
}

class DirectOpenAlexClient extends DirectSourceClient {
  final String mailto;

  DirectOpenAlexClient({
    this.mailto = 'evidence@nutrientearth.org',
    http.Client? httpClient,
  }) : super(
          sourceId: 'OPENALEX',
          baseUrl: 'https://api.openalex.org/',
          maxRequestsPerSecond: 10.0,
          httpClient: httpClient,
        );

  @override
  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-ResearchEngine/1.0 (mailto:$mailto)',
      };

  /// Search OpenAlex works
  Future<List<OpenAlexWorkRecord>> searchWorks(
    String query, {
    int perPage = 10,
    int page = 1,
  }) async {
    final params = {
      'search': query,
      'per-page': perPage.toString(),
      'page': page.toString(),
      'mailto': mailto,
    };

    final response = await executeGet('works', queryParams: params);
    final json = response.parseJson() as Map<String, dynamic>;

    final results = (json['results'] as List<dynamic>?) ?? [];
    return results.map((item) {
      final doc = Map<String, dynamic>.from(item as Map);
      final id = doc['id']?.toString() ?? '';
      final doi = doc['doi']?.toString();
      final title = doc['title']?.toString() ?? 'Untitled Work';
      final year = int.tryParse(doc['publication_year']?.toString() ?? '0') ?? 0;
      final citations = int.tryParse(doc['cited_by_count']?.toString() ?? '0') ?? 0;

      final primaryLoc = doc['primary_location'] as Map<String, dynamic>?;
      final sourceName = primaryLoc?['source']?['display_name']?.toString();

      final openAccess = doc['open_access'] as Map<String, dynamic>?;
      final isOa = openAccess?['is_oa'] == true;

      final conceptsList = (doc['concepts'] as List<dynamic>?)
              ?.map((c) => (c as Map)['display_name']?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [];

      return OpenAlexWorkRecord(
        id: id,
        doi: doi,
        title: title,
        publicationYear: year,
        citedByCount: citations,
        primaryLocationSource: sourceName,
        isOa: isOa,
        concepts: conceptsList,
        rawSha256: response.sha256Hash,
      );
    }).toList();
  }

  /// Get work by DOI
  Future<OpenAlexWorkRecord?> getWorkByDoi(String doi) async {
    final cleanDoi = doi.startsWith('http') ? doi : 'https://doi.org/$doi';
    try {
      final response = await executeGet('works/$cleanDoi');
      final doc = response.parseJson() as Map<String, dynamic>;

      final id = doc['id']?.toString() ?? '';
      final title = doc['title']?.toString() ?? 'Untitled Work';
      final year = int.tryParse(doc['publication_year']?.toString() ?? '0') ?? 0;
      final citations = int.tryParse(doc['cited_by_count']?.toString() ?? '0') ?? 0;

      final primaryLoc = doc['primary_location'] as Map<String, dynamic>?;
      final sourceName = primaryLoc?['source']?['display_name']?.toString();

      final openAccess = doc['open_access'] as Map<String, dynamic>?;
      final isOa = openAccess?['is_oa'] == true;

      return OpenAlexWorkRecord(
        id: id,
        doi: doi,
        title: title,
        publicationYear: year,
        citedByCount: citations,
        primaryLocationSource: sourceName,
        isOa: isOa,
        rawSha256: response.sha256Hash,
      );
    } catch (_) {
      return null;
    }
  }
}
