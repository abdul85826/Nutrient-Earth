// ==============================================================================
// Nutrient Earth — Direct Europe PMC Client (REST API)
// Zero MCP Dependency: Native REST Client with rate-limiting, JSON parsing,
// SHA-256 integrity hashing, citation count extraction, and retraction checks.
// ==============================================================================

import 'package:http/http.dart' as http;
import 'direct_source_client.dart';

class EuropePmcArticleRecord {
  final String? id;
  final String? source;
  final String? pmid;
  final String? pmcid;
  final String? doi;
  final String title;
  final String authorString;
  final String journalTitle;
  final String pubYear;
  final int citedByCount;
  final bool isOpenAccess;
  final bool hasRetraction;
  final String rawSha256;

  const EuropePmcArticleRecord({
    this.id,
    this.source,
    this.pmid,
    this.pmcid,
    this.doi,
    required this.title,
    required this.authorString,
    required this.journalTitle,
    required this.pubYear,
    this.citedByCount = 0,
    this.isOpenAccess = false,
    this.hasRetraction = false,
    required this.rawSha256,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'source': source,
        'pmid': pmid,
        'pmcid': pmcid,
        'doi': doi,
        'title': title,
        'authorString': authorString,
        'journalTitle': journalTitle,
        'pubYear': pubYear,
        'citedByCount': citedByCount,
        'isOpenAccess': isOpenAccess,
        'hasRetraction': hasRetraction,
        'rawSha256': rawSha256,
      };
}

class DirectEuropePmcClient extends DirectSourceClient {
  DirectEuropePmcClient({http.Client? httpClient})
      : super(
          sourceId: 'EUROPE_PMC',
          baseUrl: 'https://www.ebi.ac.uk/europepmc/webservices/rest/',
          maxRequestsPerSecond: 5.0,
          httpClient: httpClient,
        );

  @override
  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-ResearchEngine/1.0 (evidence@nutrientearth.org)',
      };

  /// Search Europe PMC scientific literature
  Future<List<EuropePmcArticleRecord>> search(
    String query, {
    int pageSize = 10,
    String resultType = 'core',
  }) async {
    final params = {
      'query': query,
      'format': 'json',
      'pageSize': pageSize.toString(),
      'resultType': resultType,
    };

    final response = await executeGet('search', queryParams: params);
    final json = response.parseJson() as Map<String, dynamic>;

    final resultList = json['resultList'] as Map<String, dynamic>?;
    if (resultList == null) return const [];

    final results = (resultList['result'] as List<dynamic>?) ?? [];
    return results.map((item) {
      final doc = Map<String, dynamic>.from(item as Map);
      final title = (doc['title'] as String?)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? 'Untitled';
      final authors = doc['authorString'] as String? ?? 'Unknown authors';
      final journal = (doc['journalInfo'] as Map<String, dynamic>?)?['journal']?['title']?.toString() ??
          (doc['journalTitle'] as String?) ??
          'Scientific Literature';
      final pubYear = doc['pubYear']?.toString() ?? '';
      final cited = int.tryParse(doc['citedByCount']?.toString() ?? '0') ?? 0;
      final isOpenAccess = doc['isOpenAccess'] == 'Y';
      final hasRetraction = doc['hasRetraction'] == 'Y' || (doc['pubType']?.toString().toLowerCase().contains('retraction') ?? false);

      return EuropePmcArticleRecord(
        id: doc['id']?.toString(),
        source: doc['source']?.toString(),
        pmid: doc['pmid']?.toString(),
        pmcid: doc['pmcid']?.toString(),
        doi: doc['doi']?.toString(),
        title: title,
        authorString: authors,
        journalTitle: journal,
        pubYear: pubYear,
        citedByCount: cited,
        isOpenAccess: isOpenAccess,
        hasRetraction: hasRetraction,
        rawSha256: response.sha256Hash,
      );
    }).toList();
  }

  /// Get article by external ID (e.g. PMID or DOI)
  Future<EuropePmcArticleRecord?> getArticleByPmid(String pmid) async {
    final list = await search('EXT_ID:$pmid', pageSize: 1);
    return list.isNotEmpty ? list.first : null;
  }
}
