// ==============================================================================
// Nutrient Earth — Direct ClinicalTrials.gov Client (API v2 REST)
// Zero MCP Dependency: Native REST Client for human clinical trial registries,
// study design appraisal, phase verification, and primary endpoint analysis.
// ==============================================================================

import 'package:http/http.dart' as http;
import 'direct_source_client.dart';

class ClinicalTrialRecord {
  final String nctId;
  final String briefTitle;
  final String? officialTitle;
  final String overallStatus;
  final String studyType;
  final List<String> phases;
  final String? primaryOutcome;
  final String? leadSponsor;
  final String? startDate;
  final String? completionDate;
  final String rawSha256;

  const ClinicalTrialRecord({
    required this.nctId,
    required this.briefTitle,
    this.officialTitle,
    required this.overallStatus,
    required this.studyType,
    this.phases = const [],
    this.primaryOutcome,
    this.leadSponsor,
    this.startDate,
    this.completionDate,
    required this.rawSha256,
  });

  Map<String, dynamic> toJson() => {
        'nctId': nctId,
        'briefTitle': briefTitle,
        'officialTitle': officialTitle,
        'overallStatus': overallStatus,
        'studyType': studyType,
        'phases': phases,
        'primaryOutcome': primaryOutcome,
        'leadSponsor': leadSponsor,
        'startDate': startDate,
        'completionDate': completionDate,
        'rawSha256': rawSha256,
      };
}

class DirectClinicalTrialsClient extends DirectSourceClient {
  DirectClinicalTrialsClient({http.Client? httpClient})
      : super(
          sourceId: 'CLINICAL_TRIALS_GOV',
          baseUrl: 'https://clinicaltrials.gov/api/v2/',
          maxRequestsPerSecond: 5.0,
          httpClient: httpClient,
        );

  @override
  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-ResearchEngine/1.0 (evidence@nutrientearth.org)',
      };

  /// Search clinical trials by query term
  Future<List<ClinicalTrialRecord>> searchStudies(
    String query, {
    int pageSize = 10,
  }) async {
    final params = {
      'query.term': query,
      'pageSize': pageSize.toString(),
    };

    final response = await executeGet('studies', queryParams: params);
    final json = response.parseJson() as Map<String, dynamic>;

    final studies = (json['studies'] as List<dynamic>?) ?? [];
    return studies.map((item) {
      final doc = Map<String, dynamic>.from(item as Map);
      final protocol = doc['protocolSection'] as Map<String, dynamic>? ?? {};

      final idModule = protocol['identificationModule'] as Map<String, dynamic>? ?? {};
      final nctId = idModule['nctId']?.toString() ?? '';
      final briefTitle = idModule['briefTitle']?.toString() ?? 'Untitled Study';
      final officialTitle = idModule['officialTitle']?.toString();

      final statusModule = protocol['statusModule'] as Map<String, dynamic>? ?? {};
      final overallStatus = statusModule['overallStatus']?.toString() ?? 'UNKNOWN';
      final startDate = statusModule['startDateStruct']?['date']?.toString();
      final completionDate = statusModule['completionDateStruct']?['date']?.toString();

      final designModule = protocol['designModule'] as Map<String, dynamic>? ?? {};
      final studyType = designModule['studyType']?.toString() ?? 'INTERVENTIONAL';
      final phases = (designModule['phases'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          const [];

      final outcomesModule = protocol['outcomesModule'] as Map<String, dynamic>? ?? {};
      final primaryOutcomes = (outcomesModule['primaryOutcomes'] as List<dynamic>?) ?? [];
      final primaryOutcome = primaryOutcomes.isNotEmpty
          ? (primaryOutcomes.first as Map<String, dynamic>)['measure']?.toString()
          : null;

      final sponsorModule = protocol['sponsorCollaboratorsModule'] as Map<String, dynamic>? ?? {};
      final leadSponsor = sponsorModule['leadSponsor']?['name']?.toString();

      return ClinicalTrialRecord(
        nctId: nctId,
        briefTitle: briefTitle,
        officialTitle: officialTitle,
        overallStatus: overallStatus,
        studyType: studyType,
        phases: phases,
        primaryOutcome: primaryOutcome,
        leadSponsor: leadSponsor,
        startDate: startDate,
        completionDate: completionDate,
        rawSha256: response.sha256Hash,
      );
    }).toList();
  }

  /// Fetch trial by NCT identifier
  Future<ClinicalTrialRecord?> getStudy(String nctId) async {
    try {
      final response = await executeGet('studies/$nctId');
      final doc = response.parseJson() as Map<String, dynamic>;
      final protocol = doc['protocolSection'] as Map<String, dynamic>? ?? {};

      final idModule = protocol['identificationModule'] as Map<String, dynamic>? ?? {};
      final briefTitle = idModule['briefTitle']?.toString() ?? 'Untitled Study';
      final officialTitle = idModule['officialTitle']?.toString();

      final statusModule = protocol['statusModule'] as Map<String, dynamic>? ?? {};
      final overallStatus = statusModule['overallStatus']?.toString() ?? 'UNKNOWN';

      final designModule = protocol['designModule'] as Map<String, dynamic>? ?? {};
      final studyType = designModule['studyType']?.toString() ?? 'INTERVENTIONAL';
      final phases = (designModule['phases'] as List<dynamic>?)
              ?.map((p) => p.toString())
              .toList() ??
          const [];

      return ClinicalTrialRecord(
        nctId: nctId,
        briefTitle: briefTitle,
        officialTitle: officialTitle,
        overallStatus: overallStatus,
        studyType: studyType,
        phases: phases,
        rawSha256: response.sha256Hash,
      );
    } catch (_) {
      return null;
    }
  }
}
