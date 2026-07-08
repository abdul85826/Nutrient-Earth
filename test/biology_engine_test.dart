import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrient_earth/features/biology/entities/biology_entities.dart';
import 'package:nutrient_earth/features/biology/models/biology_models.dart';
import 'package:nutrient_earth/features/biology/repositories/biology_repository.dart';
import 'package:nutrient_earth/features/biology/providers/biology_providers.dart';

// A mock implementation of BiologyRepository to test provider dependency injection
class MockBiologyRepository implements BiologyRepository {
  @override
  Future<Organ> getOrgan(String id) async {
    return const Organ(
      id: 'a1111111-a111-a111-a111-a11111111111',
      systemId: 'sys_1',
      displayName: 'Heart',
      scientificName: 'Cor',
      description: 'Pumps blood',
      position: 'Thorax',
      anatomy: 'Chambers',
      bloodSupply: 'Coronary arteries',
      innervation: 'Vagus nerve',
      futureMlFeatures: ['hrv_prediction'],
    );
  }

  @override
  Future<List<Organ>> getAllOrgans() async {
    return [
      await getOrgan('1'),
    ];
  }

  @override
  Future<List<BodySystem>> getBodySystems() async {
    return [
      const BodySystem(id: 'sys_1', name: 'Cardiovascular System', description: 'Circulatory loops'),
    ];
  }

  @override
  Future<List<OrganBiomarker>> getOrganBiomarkers(String organId) async {
    return [
      const OrganBiomarker(
        id: 'bio_1',
        organId: '1',
        name: 'Troponin',
        description: 'Muscle damage marker',
        normalRange: '0.0 - 0.014',
        unit: 'ng/mL',
      ),
    ];
  }

  @override
  Future<List<OrganDisease>> getOrganDiseases(String organId) async {
    return [
      const OrganDisease(
        id: 'dis_1',
        organId: '1',
        diseaseName: 'Myocardial Infarction',
        description: 'Heart attack',
        clinicalMarkers: ['ST Elevation'],
      ),
    ];
  }

  @override
  Future<List<OrganSymptom>> getOrganSymptoms(String organId) async {
    return [
      const OrganSymptom(
        id: 'sym_1',
        organId: '1',
        symptomName: 'Angina',
        description: 'Chest pain',
        severityLevel: 4,
      ),
    ];
  }

  @override
  Future<List<OrganNutrient>> getOrganNutrients(String organId) async {
    return [
      const OrganNutrient(
        id: 'nut_1',
        organId: '1',
        nutrientName: 'CoQ10',
        description: 'Mitochondrial support',
        recommendedDailyIntake: '100mg',
      ),
    ];
  }

  @override
  Future<List<OrganLabTest>> getOrganLabTests(String organId) async {
    return [
      const OrganLabTest(
        id: 'lab_1',
        organId: '1',
        testName: 'ECG',
        description: 'Electrical trace',
        standardThresholds: 'Normal sinus rhythm',
      ),
    ];
  }

  @override
  Future<List<MedicalReference>> getOrganReferences(String organId) async {
    return [
      const MedicalReference(
        id: 'ref_1',
        title: 'Study of HRV',
        authors: 'Author A',
        journal: 'Heart Journal',
        publicationYear: 2026,
      ),
    ];
  }
}

void main() {
  group('Biology Engine Models & Serialization', () {
    test('BodySystemModel JSON serialization roundtrip', () {
      final json = {
        'id': 'sys_001',
        'name': 'Cardiovascular System',
        'description': 'Pumps blood and moves gases.',
      };

      final model = BodySystemModel.fromJson(json);
      expect(model.id, equals('sys_001'));
      expect(model.name, equals('Cardiovascular System'));
      expect(model.description, equals('Pumps blood and moves gases.'));

      final outJson = model.toJson();
      expect(outJson['id'], equals('sys_001'));
      expect(outJson['name'], equals('Cardiovascular System'));
    });

    test('OrganModel JSON serialization handles empty image & future_ml_features', () {
      final json = {
        'id': 'organ_001',
        'system_id': 'sys_001',
        'display_name': 'Heart',
        'scientific_name': 'Cor',
        'description': 'Myocardium engine.',
        'position': 'Chest',
        'anatomy': 'Left side',
        'blood_supply': 'Coronary arteries',
        'innervation': 'Vagus',
        'image_url': null,
        'model_3d_ref': 'heart.glb',
        'future_ml_features': ['arrhythmia_detection', 'stress_index'],
      };

      final model = OrganModel.fromJson(json);
      expect(model.displayName, equals('Heart'));
      expect(model.imageUrl, isNull);
      expect(model.model3dRef, equals('heart.glb'));
      expect(model.futureMlFeatures, contains('arrhythmia_detection'));

      final outJson = model.toJson();
      expect(outJson['display_name'], equals('Heart'));
      expect(outJson['future_ml_features'], isA<List>());
    });

    test('OrganDiseaseModel parses list arrays cleanly', () {
      final json = {
        'id': 'dis_001',
        'organ_id': 'organ_001',
        'disease_name': 'Heart Failure',
        'description': 'Reduced cardiac output.',
        'clinical_markers': ['BNP elevation', 'EF reduction'],
      };

      final model = OrganDiseaseModel.fromJson(json);
      expect(model.clinicalMarkers, contains('BNP elevation'));
      expect(model.clinicalMarkers.length, equals(2));
    });
  });

  group('Biology Engine Providers Integration', () {
    test('ProviderContainer resolve overriden mock repository and fetch resources', () async {
      final container = ProviderContainer(
        overrides: [
          biologyRepositoryProvider.overrideWithValue(MockBiologyRepository()),
        ],
      );

      final repo = container.read(biologyRepositoryProvider);
      expect(repo, isA<MockBiologyRepository>());

      // Verify Body Systems provider
      final systems = await container.read(bodySystemsProvider.future);
      expect(systems.first.name, equals('Cardiovascular System'));

      // Verify All Organs provider
      final organs = await container.read(allOrgansProvider.future);
      expect(organs.first.scientificName, equals('Cor'));

      // Verify Organ Biomarkers provider
      final biomarkers = await container.read(organBiomarkersProvider('a1111111-a111-a111-a111-a11111111111').future);
      expect(biomarkers.first.name, equals('Troponin'));
    });
  });
}
