// ==============================================================================
// Nutrient Earth — Direct NCBI PubMed Client (E-utilities REST API)
// Zero MCP Dependency: Native REST Client with rate-limiting, JSON/XML parsing,
// SHA-256 integrity hashing, and citation extraction.
// ==============================================================================

import 'package:http/http.dart' as http;
import 'direct_source_client.dart';

class PubmedArticleMetadata {
  final String pmid;
  final String title;
  final String authors;
  final String sourceJournal;
  final String pubDate;
  final String? doi;
  final List<String> meshHeadings;
  final String? abstractText;
  final String rawSha256;

  const PubmedArticleMetadata({
    required this.pmid,
    required this.title,
    required this.authors,
    required this.sourceJournal,
    required this.pubDate,
    this.doi,
    this.meshHeadings = const [],
    this.abstractText,
    required this.rawSha256,
  });

  Map<String, dynamic> toJson() => {
        'pmid': pmid,
        'title': title,
        'authors': authors,
        'sourceJournal': sourceJournal,
        'pubDate': pubDate,
        'doi': doi,
        'meshHeadings': meshHeadings,
        'abstractText': abstractText,
        'rawSha256': rawSha256,
      };
}

class DirectPubmedClient extends DirectSourceClient {
  final String? apiKey;

  DirectPubmedClient({
    this.apiKey,
    http.Client? httpClient,
  }) : super(
          sourceId: 'NCBI_PUBMED',
          baseUrl: 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/',
          maxRequestsPerSecond: apiKey != null ? 10.0 : 3.0,
          httpClient: httpClient,
        );

  @override
  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-ResearchEngine/1.0 (evidence@nutrientearth.org)',
      };

  Map<String, String> _buildBaseParams() {
    final params = {
      'db': 'pubmed',
      'retmode': 'json',
      'tool': 'NutrientEarth',
      'email': 'evidence@nutrientearth.org',
    };
    if (apiKey != null) {
      params['api_key'] = apiKey!;
    }
    return params;
  }

  /// Search PubMed for a query string, returning list of PMIDs
  Future<List<String>> searchPubmed(
    String query, {
    int limit = 10,
    int offset = 0,
    String sort = 'relevance',
  }) async {
    final params = {
      ..._buildBaseParams(),
      'term': query,
      'retmax': limit.toString(),
      'retstart': offset.toString(),
      'sort': sort,
    };

    final response = await executeGet('esearch.fcgi', queryParams: params);
    final json = response.parseJson() as Map<String, dynamic>;

    final esearchResult = json['esearchresult'] as Map<String, dynamic>?;
    if (esearchResult == null) return const [];

    final idList = (esearchResult['idlist'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    return idList;
  }

  /// Fetch parsed article metadata for a specific PMID
  Future<PubmedArticleMetadata?> fetchArticleSummary(String pmid) async {
    final params = {
      ..._buildBaseParams(),
      'id': pmid,
    };

    final response = await executeGet('esummary.fcgi', queryParams: params);
    final json = response.parseJson() as Map<String, dynamic>;

    final result = json['result'] as Map<String, dynamic>?;
    if (result == null || !result.containsKey(pmid)) return null;

    final doc = result[pmid] as Map<String, dynamic>;
    final title = (doc['title'] as String?)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? 'Untitled Study';
    final journal = doc['source'] as String? ?? 'Peer-Reviewed Literature';
    final pubDate = doc['pubdate'] as String? ?? '';

    // Authors formatting
    final authorsList = (doc['authors'] as List<dynamic>?) ?? [];
    String authorsStr = 'Unknown authors';
    if (authorsList.isNotEmpty) {
      final first = authorsList.first as Map<String, dynamic>;
      final firstName = first['name']?.toString() ?? 'Author';
      if (authorsList.length == 1) {
        authorsStr = firstName;
      } else if (authorsList.length == 2) {
        final second = authorsList[1] as Map<String, dynamic>;
        authorsStr = '$firstName & ${second['name'] ?? ''}';
      } else {
        authorsStr = '$firstName et al.';
      }
    }

    // DOI extraction from articleids
    String? doi;
    final articleIds = (doc['articleids'] as List<dynamic>?) ?? [];
    for (final idObj in articleIds) {
      if (idObj is Map<String, dynamic> && idObj['idtype'] == 'doi') {
        doi = idObj['value']?.toString();
        break;
      }
    }

    return PubmedArticleMetadata(
      pmid: pmid,
      title: title,
      authors: authorsStr,
      sourceJournal: journal,
      pubDate: pubDate,
      doi: doi,
      rawSha256: response.sha256Hash,
    );
  }

  /// Bulk fetch metadata for up to 50 PMIDs
  Future<List<PubmedArticleMetadata>> fetchBulkArticleSummaries(List<String> pmids) async {
    if (pmids.isEmpty) return const [];
    final cleanList = pmids.take(50).toList();
    final params = {
      ..._buildBaseParams(),
      'id': cleanList.join(','),
    };

    final response = await executeGet('esummary.fcgi', queryParams: params);
    final json = response.parseJson() as Map<String, dynamic>;
    final result = json['result'] as Map<String, dynamic>?;
    if (result == null) return const [];

    final list = <PubmedArticleMetadata>[];
    for (final pmid in cleanList) {
      if (!result.containsKey(pmid)) continue;
      final doc = result[pmid] as Map<String, dynamic>;
      final title = (doc['title'] as String?)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? 'Untitled Study';
      final journal = doc['source'] as String? ?? 'Peer-Reviewed Literature';
      final pubDate = doc['pubdate'] as String? ?? '';

      final authorsList = (doc['authors'] as List<dynamic>?) ?? [];
      String authorsStr = 'Unknown authors';
      if (authorsList.isNotEmpty) {
        final first = authorsList.first as Map<String, dynamic>;
        final firstName = first['name']?.toString() ?? 'Author';
        authorsStr = authorsList.length > 1 ? '$firstName et al.' : firstName;
      }

      String? doi;
      final articleIds = (doc['articleids'] as List<dynamic>?) ?? [];
      for (final idObj in articleIds) {
        if (idObj is Map<String, dynamic> && idObj['idtype'] == 'doi') {
          doi = idObj['value']?.toString();
          break;
        }
      }

      list.add(PubmedArticleMetadata(
        pmid: pmid,
        title: title,
        authors: authorsStr,
        sourceJournal: journal,
        pubDate: pubDate,
        doi: doi,
        rawSha256: response.sha256Hash,
      ));
    }
    return list;
  }
}
