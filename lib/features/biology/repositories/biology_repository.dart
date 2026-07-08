import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/biology_entities.dart';
import '../models/biology_models.dart';

abstract class BiologyRepository {
  Future<Organ> getOrgan(String id);
  Future<List<Organ>> getAllOrgans();
  Future<List<BodySystem>> getBodySystems();
  Future<List<OrganBiomarker>> getOrganBiomarkers(String organId);
  Future<List<OrganDisease>> getOrganDiseases(String organId);
  Future<List<OrganSymptom>> getOrganSymptoms(String organId);
  Future<List<OrganNutrient>> getOrganNutrients(String organId);
  Future<List<OrganLabTest>> getOrganLabTests(String organId);
  Future<List<MedicalReference>> getOrganReferences(String organId);
}

class SupabaseBiologyRepository implements BiologyRepository {
  final SupabaseClient _client;

  SupabaseBiologyRepository(this._client);

  @override
  Future<Organ> getOrgan(String id) async {
    final response = await _client
        .from('organs')
        .select()
        .eq('id', id)
        .single();
    return OrganModel.fromJson(response);
  }

  @override
  Future<List<Organ>> getAllOrgans() async {
    final response = await _client.from('organs').select();
    return response.map((json) => OrganModel.fromJson(json)).toList();
  }

  @override
  Future<List<BodySystem>> getBodySystems() async {
    final response = await _client.from('body_systems').select();
    return response.map((json) => BodySystemModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrganBiomarker>> getOrganBiomarkers(String organId) async {
    final response = await _client
        .from('organ_biomarkers')
        .select()
        .eq('organ_id', organId);
    return response.map((json) => OrganBiomarkerModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrganDisease>> getOrganDiseases(String organId) async {
    final response = await _client
        .from('organ_diseases')
        .select()
        .eq('organ_id', organId);
    return response.map((json) => OrganDiseaseModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrganSymptom>> getOrganSymptoms(String organId) async {
    final response = await _client
        .from('organ_symptoms')
        .select()
        .eq('organ_id', organId);
    return response.map((json) => OrganSymptomModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrganNutrient>> getOrganNutrients(String organId) async {
    final response = await _client
        .from('organ_nutrients')
        .select()
        .eq('organ_id', organId);
    return response.map((json) => OrganNutrientModel.fromJson(json)).toList();
  }

  @override
  Future<List<OrganLabTest>> getOrganLabTests(String organId) async {
    final response = await _client
        .from('organ_lab_tests')
        .select()
        .eq('organ_id', organId);
    return response.map((json) => OrganLabTestModel.fromJson(json)).toList();
  }

  @override
  Future<List<MedicalReference>> getOrganReferences(String organId) async {
    // Queries via the junction table organ_references
    final junctionResponse = await _client
        .from('organ_references')
        .select('reference_id')
        .eq('organ_id', organId);

    if (junctionResponse.isEmpty) return [];

    final referenceIds = junctionResponse.map((row) => row['reference_id'] as String).toList();

    final response = await _client
        .from('medical_references')
        .select()
        .inFilter('id', referenceIds);

    return response.map((json) => MedicalReferenceModel.fromJson(json)).toList();
  }
}
