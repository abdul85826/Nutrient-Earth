// ==============================================================================
// Nutrient Earth — Direct PubChem Client (PUG REST API)
// Zero MCP Dependency: Native REST Client for chemical entity resolution,
// molecular physics parameters, IUPAC naming, and toxicological identifiers.
// ==============================================================================

import 'package:http/http.dart' as http;
import 'direct_source_client.dart';

class PubChemCompoundRecord {
  final int cid;
  final String? molecularFormula;
  final double? molecularWeight;
  final String? inchiKey;
  final String? iupacName;
  final String rawSha256;

  const PubChemCompoundRecord({
    required this.cid,
    this.molecularFormula,
    this.molecularWeight,
    this.inchiKey,
    this.iupacName,
    required this.rawSha256,
  });

  Map<String, dynamic> toJson() => {
        'cid': cid,
        'molecularFormula': molecularFormula,
        'molecularWeight': molecularWeight,
        'inchiKey': inchiKey,
        'iupacName': iupacName,
        'rawSha256': rawSha256,
      };
}

class DirectPubchemClient extends DirectSourceClient {
  DirectPubchemClient({http.Client? httpClient})
      : super(
          sourceId: 'NCBI_PUBCHEM',
          baseUrl: 'https://pubchem.ncbi.nlm.nih.gov/rest/pug/',
          maxRequestsPerSecond: 5.0,
          httpClient: httpClient,
        );

  @override
  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-ResearchEngine/1.0 (evidence@nutrientearth.org)',
      };

  /// Find Compound ID (CID) by common chemical or ingredient name
  Future<int?> searchCidByName(String name) async {
    final cleanName = Uri.encodeComponent(name.trim());
    try {
      final response = await executeGet('compound/name/$cleanName/cids/JSON');
      final json = response.parseJson() as Map<String, dynamic>;

      final idList = json['IdentifierList'] as Map<String, dynamic>?;
      final cids = (idList?['CID'] as List<dynamic>?) ?? [];
      if (cids.isNotEmpty) {
        return int.tryParse(cids.first.toString());
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch physicochemical properties for a CID
  Future<PubChemCompoundRecord?> getCompoundProperties(int cid) async {
    try {
      final properties = 'MolecularFormula,MolecularWeight,InChIKey,IUPACName';
      final response = await executeGet('compound/cid/$cid/property/$properties/JSON');
      final json = response.parseJson() as Map<String, dynamic>;

      final propTable = json['PropertyTable'] as Map<String, dynamic>?;
      final props = (propTable?['Properties'] as List<dynamic>?) ?? [];
      if (props.isEmpty) return null;

      final doc = props.first as Map<String, dynamic>;
      final formula = doc['MolecularFormula']?.toString();
      final weight = double.tryParse(doc['MolecularWeight']?.toString() ?? '');
      final inchiKey = doc['InChIKey']?.toString();
      final iupac = doc['IUPACName']?.toString();

      return PubChemCompoundRecord(
        cid: cid,
        molecularFormula: formula,
        molecularWeight: weight,
        inchiKey: inchiKey,
        iupacName: iupac,
        rawSha256: response.sha256Hash,
      );
    } catch (_) {
      return null;
    }
  }

  /// Convenience lookup: resolve chemical by name directly to compound properties
  Future<PubChemCompoundRecord?> resolveCompoundByName(String name) async {
    final cid = await searchCidByName(name);
    if (cid == null) return null;
    return getCompoundProperties(cid);
  }
}
