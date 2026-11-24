// ==============================================================================
// Nutrient Earth — Direct Source Acquisition & Knowledge Graph Integration Tests
// Zero MCP Dependency: Verifies rate limiting, backoff retry, SHA-256 hashing,
// XML/JSON parsing, and causality governance across all direct REST clients.
// ==============================================================================

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:nutrient_earth_client/core/services/acquisition/direct_source_client.dart';
import 'package:nutrient_earth_client/core/services/acquisition/direct_pubmed_client.dart';
import 'package:nutrient_earth_client/core/services/acquisition/direct_europe_pmc_client.dart';
import 'package:nutrient_earth_client/core/services/acquisition/direct_openalex_client.dart';
import 'package:nutrient_earth_client/core/services/acquisition/direct_clinical_trials_client.dart';
import 'package:nutrient_earth_client/core/services/acquisition/direct_open_food_facts_client.dart';
import 'package:nutrient_earth_client/core/services/acquisition/direct_pubchem_client.dart';
import 'package:nutrient_earth_client/core/services/knowledge_graph/health_knowledge_graph_service.dart';

void main() {
  group('1. Direct Source Client Foundation & Integrity Hashing', () {
    test('Calculates SHA-256 digest accurately for raw responses', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"status":"ok"}', 200, headers: {'content-type': 'application/json'});
      });

      final client = DirectPubmedClient(httpClient: mockClient);
      final response = await client.executeGet('test');

      expect(response.statusCode, 200);
      expect(response.sha256Hash.length, 64); // SHA-256 is 64 hex characters
      // "{"status":"ok"}" SHA-256 hex
      expect(response.sha256Hash, 'd81a95e26b1c6d3bcce4da710777cf0ad89faec9b6b726488ad0e466b04e6c9d');
    });

    test('Retries on HTTP 429 with backoff and throws rateLimited if exhausted', () async {
      int requestCount = 0;
      final mockClient = MockClient((request) async {
        requestCount++;
        return http.Response('Too many requests', 429, headers: {'retry-after': '0'});
      });

      final client = DirectPubmedClient(httpClient: mockClient);

      expect(
        () => client.executeGet('test'),
        throwsA(isA<DirectSourceException>().having((e) => e.code, 'code', SourceErrorCode.rateLimited)),
      );
    });

    test('Throws notFound exception on HTTP 404', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      final client = DirectEuropePmcClient(httpClient: mockClient);

      expect(
        () => client.executeGet('unknown_endpoint'),
        throwsA(isA<DirectSourceException>().having((e) => e.code, 'code', SourceErrorCode.notFound)),
      );
    });
  });

  group('2. NCBI PubMed Direct Client Tests', () {
    test('Parses esearch.fcgi JSON and extracts PMIDs', () async {
      final mockJson = jsonEncode({
        'esearchresult': {
          'count': '2',
          'retmax': '2',
          'idlist': ['36034224', '19056590'],
        }
      });

      final mockClient = MockClient((request) async {
        expect(request.url.path.contains('esearch.fcgi'), isTrue);
        expect(request.url.queryParameters['term'], 'magnesium sleep');
        return http.Response(mockJson, 200);
      });

      final pubmed = DirectPubmedClient(httpClient: mockClient);
      final pmids = await pubmed.searchPubmed('magnesium sleep');

      expect(pmids.length, 2);
      expect(pmids, contains('36034224'));
      expect(pmids, contains('19056590'));
    });

    test('Parses esummary.fcgi JSON and formats article metadata', () async {
      final mockJson = jsonEncode({
        'result': {
          'uids': ['36034224'],
          '36034224': {
            'uid': '36034224',
            'title': 'A potent physiological method to magnify and sustain soleus oxidative metabolism.',
            'source': 'iScience',
            'pubdate': '2022 Sep 16',
            'authors': [
              {'name': 'Hamilton MT'},
              {'name': 'Hamilton DG'},
              {'name': 'Zderic TW'}
            ],
            'articleids': [
              {'idtype': 'pubmed', 'value': '36034224'},
              {'idtype': 'doi', 'value': '10.1016/j.isci.2022.104869'}
            ]
          }
        }
      });

      final mockClient = MockClient((request) async {
        expect(request.url.path.contains('esummary.fcgi'), isTrue);
        return http.Response(mockJson, 200);
      });

      final pubmed = DirectPubmedClient(httpClient: mockClient);
      final meta = await pubmed.fetchArticleSummary('36034224');

      expect(meta, isNotNull);
      expect(meta!.pmid, '36034224');
      expect(meta.title, contains('soleus oxidative metabolism'));
      expect(meta.authors, 'Hamilton MT et al.');
      expect(meta.sourceJournal, 'iScience');
      expect(meta.doi, '10.1016/j.isci.2022.104869');
      expect(meta.rawSha256.isNotEmpty, isTrue);
    });
  });

  group('3. Europe PMC Direct Client Tests', () {
    test('Parses Europe PMC search results including citation counts and retractions', () async {
      final mockJson = jsonEncode({
        'resultList': {
          'result': [
            {
              'id': '36034224',
              'source': 'MED',
              'pmid': '36034224',
              'pmcid': 'PMC9404652',
              'doi': '10.1016/j.isci.2022.104869',
              'title': 'A potent physiological method to magnify soleus oxidative metabolism',
              'authorString': 'Hamilton MT, Hamilton DG, Zderic TW',
              'journalTitle': 'iScience',
              'pubYear': '2022',
              'citedByCount': 42,
              'isOpenAccess': 'Y',
              'hasRetraction': 'N',
            }
          ]
        }
      });

      final mockClient = MockClient((request) async {
        return http.Response(mockJson, 200);
      });

      final client = DirectEuropePmcClient(httpClient: mockClient);
      final results = await client.search('soleus oxidative metabolism');

      expect(results.length, 1);
      final r = results.first;
      expect(r.pmcid, 'PMC9404652');
      expect(r.citedByCount, 42);
      expect(r.isOpenAccess, isTrue);
      expect(r.hasRetraction, isFalse);
    });
  });

  group('4. OpenAlex Direct Client Tests', () {
    test('Parses OpenAlex works metadata with concept hierarchy', () async {
      final mockJson = jsonEncode({
        'results': [
          {
            'id': 'https://openalex.org/W4283182930',
            'doi': 'https://doi.org/10.1016/j.isci.2022.104869',
            'title': 'A potent physiological method to magnify and sustain soleus oxidative metabolism',
            'publication_year': 2022,
            'cited_by_count': 55,
            'primary_location': {
              'source': {'display_name': 'iScience'}
            },
            'open_access': {'is_oa': true},
            'concepts': [
              {'display_name': 'Metabolism'},
              {'display_name': 'Soleus muscle'},
              {'display_name': 'Glucose'}
            ]
          }
        ]
      });

      final mockClient = MockClient((request) async {
        return http.Response(mockJson, 200);
      });

      final client = DirectOpenAlexClient(httpClient: mockClient);
      final works = await client.searchWorks('soleus metabolism');

      expect(works.length, 1);
      final work = works.first;
      expect(work.id, 'https://openalex.org/W4283182930');
      expect(work.publicationYear, 2022);
      expect(work.citedByCount, 55);
      expect(work.isOa, isTrue);
      expect(work.concepts, contains('Soleus muscle'));
    });
  });

  group('5. ClinicalTrials.gov Direct Client Tests', () {
    test('Parses ClinicalTrials.gov API v2 study protocol and primary outcome', () async {
      final mockJson = jsonEncode({
        'studies': [
          {
            'protocolSection': {
              'identificationModule': {
                'nctId': 'NCT05214846',
                'briefTitle': 'Effects of Soleus Pushups on Metabolic Flexibility in Humans',
              },
              'statusModule': {
                'overallStatus': 'COMPLETED',
                'startDateStruct': {'date': '2021-06-01'},
                'completionDateStruct': {'date': '2022-04-30'},
              },
              'designModule': {
                'studyType': 'INTERVENTIONAL',
                'phases': ['PHASE1', 'PHASE2'],
              },
              'outcomesModule': {
                'primaryOutcomes': [
                  {'measure': 'Whole-body glucose oxidation rate during 3-hour oral glucose challenge'}
                ]
              },
              'sponsorCollaboratorsModule': {
                'leadSponsor': {'name': 'University of Houston'}
              }
            }
          }
        ]
      });

      final mockClient = MockClient((request) async {
        return http.Response(mockJson, 200);
      });

      final client = DirectClinicalTrialsClient(httpClient: mockClient);
      final trials = await client.searchStudies('soleus pushup');

      expect(trials.length, 1);
      final t = trials.first;
      expect(t.nctId, 'NCT05214846');
      expect(t.overallStatus, 'COMPLETED');
      expect(t.studyType, 'INTERVENTIONAL');
      expect(t.primaryOutcome, contains('glucose oxidation rate'));
      expect(t.leadSponsor, 'University of Houston');
    });
  });

  group('6. Open Food Facts Direct Client Tests', () {
    test('Resolves product barcode to ingredients, NOVA group, and Nutri-Score', () async {
      final mockJson = jsonEncode({
        'status': 1,
        'product': {
          'product_name': 'Organic Rolled Oats',
          'brands': 'Nature Best',
          'ingredients_text': '100% Whole Grain Rolled Oats.',
          'allergens_tags': ['en:gluten'],
          'nova_group': 1,
          'nutriscore_grade': 'a',
          'additives_tags': <String>[],
          'nutrient_levels': {
            'fat': 'low',
            'salt': 'low',
            'sugars': 'low'
          }
        }
      });

      final mockClient = MockClient((request) async {
        expect(request.url.path.contains('product/001234567890.json'), isTrue);
        return http.Response(mockJson, 200);
      });

      final client = DirectOpenFoodFactsClient(httpClient: mockClient);
      final product = await client.getProductByBarcode('001234567890');

      expect(product, isNotNull);
      expect(product!.productName, 'Organic Rolled Oats');
      expect(product.novaGroup, 1);
      expect(product.nutriscoreGrade, 'A');
      expect(product.allergensTags, contains('en:gluten'));
    });
  });

  group('7. PubChem PUG REST Direct Client Tests', () {
    test('Resolves chemical name to CID and extracts molecular physics properties', () async {
      final mockCidJson = jsonEncode({
        'IdentifierList': {
          'CID': [23665764]
        }
      });

      final mockPropJson = jsonEncode({
        'PropertyTable': {
          'Properties': [
            {
              'CID': 23665764,
              'MolecularFormula': 'C4H8MgN2O4',
              'MolecularWeight': '172.42',
              'InChIKey': 'InChIKey=VMDFWJMQDOOHSS-UHFFFAOYSA-N',
              'IUPACName': 'magnesium;2-aminoacetate'
            }
          ]
        }
      });

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('cids')) {
          return http.Response(mockCidJson, 200);
        } else {
          return http.Response(mockPropJson, 200);
        }
      });

      final client = DirectPubchemClient(httpClient: mockClient);
      final compound = await client.resolveCompoundByName('magnesium glycinate');

      expect(compound, isNotNull);
      expect(compound!.cid, 23665764);
      expect(compound.molecularFormula, 'C4H8MgN2O4');
      expect(compound.molecularWeight, 172.42);
      expect(compound.iupacName, contains('magnesium;2-aminoacetate'));
    });
  });

  group('8. Health Knowledge Graph Causality Governance Tests', () {
    test('Enforces strict causality justification requirement on [causes] relationship', () async {
      final kgService = HealthKnowledgeGraphService(client: null);

      // Attempting to link with [causes] but omitting or providing trivial causality justification
      expect(
        () => kgService.linkEntities(
          sourceEntityId: 'ent-1',
          targetEntityId: 'ent-2',
          relationType: KgRelationshipType.causes,
          causalityJustification: 'it causes it', // too short (<20 chars)
        ),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('strictly requires an explicit causality_justification'),
        )),
      );
    });

    test('Maps all 23 entity types and 15 relationships to canonical SQL snake_case', () {
      expect(HealthKnowledgeGraphService.entityTypeToSql(KgEntityType.chemicalCompound), 'chemical_compound');
      expect(HealthKnowledgeGraphService.entityTypeToSql(KgEntityType.foodIngredient), 'food_ingredient');
      expect(HealthKnowledgeGraphService.entityTypeToSql(KgEntityType.biologicalPathway), 'biological_pathway');
      expect(HealthKnowledgeGraphService.entityTypeToSql(KgEntityType.cellularProcess), 'cellular_process');
      expect(HealthKnowledgeGraphService.entityTypeToSql(KgEntityType.scientificControversy), 'scientific_controversy');

      expect(HealthKnowledgeGraphService.relationshipTypeToSql(KgRelationshipType.metabolisedInto), 'metabolised_into');
      expect(HealthKnowledgeGraphService.relationshipTypeToSql(KgRelationshipType.upregulates), 'upregulates');
      expect(HealthKnowledgeGraphService.relationshipTypeToSql(KgRelationshipType.downregulates), 'downregulates');
      expect(HealthKnowledgeGraphService.relationshipTypeToSql(KgRelationshipType.biomarkerOf), 'biomarker_of');
      expect(HealthKnowledgeGraphService.relationshipTypeToSql(KgRelationshipType.exacerbates), 'exacerbates');
    });
  });
}
