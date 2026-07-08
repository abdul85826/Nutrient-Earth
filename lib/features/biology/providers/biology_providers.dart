import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/biology_entities.dart';
import '../repositories/biology_repository.dart';

final biologyRepositoryProvider = Provider<BiologyRepository>((ref) {
  return SupabaseBiologyRepository(Supabase.instance.client);
});

final bodySystemsProvider = FutureProvider<List<BodySystem>>((ref) async {
  return ref.watch(biologyRepositoryProvider).getBodySystems();
});

final allOrgansProvider = FutureProvider<List<Organ>>((ref) async {
  return ref.watch(biologyRepositoryProvider).getAllOrgans();
});

final organProvider = FutureProvider.family<Organ, String>((ref, id) async {
  return ref.watch(biologyRepositoryProvider).getOrgan(id);
});

final organBiomarkersProvider = FutureProvider.family<List<OrganBiomarker>, String>((ref, organId) async {
  return ref.watch(biologyRepositoryProvider).getOrganBiomarkers(organId);
});

final organDiseasesProvider = FutureProvider.family<List<OrganDisease>, String>((ref, organId) async {
  return ref.watch(biologyRepositoryProvider).getOrganDiseases(organId);
});

final organSymptomsProvider = FutureProvider.family<List<OrganSymptom>, String>((ref, organId) async {
  return ref.watch(biologyRepositoryProvider).getOrganSymptoms(organId);
});

final organNutrientsProvider = FutureProvider.family<List<OrganNutrient>, String>((ref, organId) async {
  return ref.watch(biologyRepositoryProvider).getOrganNutrients(organId);
});

final organLabTestsProvider = FutureProvider.family<List<OrganLabTest>, String>((ref, organId) async {
  return ref.watch(biologyRepositoryProvider).getOrganLabTests(organId);
});

final organReferencesProvider = FutureProvider.family<List<MedicalReference>, String>((ref, organId) async {
  return ref.watch(biologyRepositoryProvider).getOrganReferences(organId);
});
