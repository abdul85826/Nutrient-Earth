import '../entities/biology_entities.dart';

class BodySystemModel extends BodySystem {
  const BodySystemModel({
    required super.id,
    required super.name,
    super.description,
  });

  factory BodySystemModel.fromJson(Map<String, dynamic> json) {
    return BodySystemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class OrganModel extends Organ {
  const OrganModel({
    required super.id,
    required super.systemId,
    required super.displayName,
    required super.scientificName,
    required super.description,
    required super.position,
    required super.anatomy,
    required super.bloodSupply,
    required super.innervation,
    super.imageUrl,
    super.model3dRef,
    required super.futureMlFeatures,
  });

  factory OrganModel.fromJson(Map<String, dynamic> json) {
    final rawMl = json['future_ml_features'];
    List<String> mlFeatures = [];
    if (rawMl is List) {
      mlFeatures = rawMl.map((e) => e.toString()).toList();
    }
    return OrganModel(
      id: json['id'] as String,
      systemId: json['system_id'] as String,
      displayName: json['display_name'] as String,
      scientificName: json['scientific_name'] as String,
      description: json['description'] as String,
      position: json['position'] as String,
      anatomy: json['anatomy'] as String,
      bloodSupply: json['blood_supply'] as String,
      innervation: json['innervation'] as String,
      imageUrl: json['image_url'] as String?,
      model3dRef: json['model_3d_ref'] as String?,
      futureMlFeatures: mlFeatures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'system_id': systemId,
      'display_name': displayName,
      'scientific_name': scientificName,
      'description': description,
      'position': position,
      'anatomy': anatomy,
      'blood_supply': bloodSupply,
      'innervation': innervation,
      'image_url': imageUrl,
      'model_3d_ref': model3dRef,
      'future_ml_features': futureMlFeatures,
    };
  }
}

class OrganFunctionModel extends OrganFunction {
  const OrganFunctionModel({
    required super.id,
    required super.organId,
    required super.functionName,
    required super.description,
  });

  factory OrganFunctionModel.fromJson(Map<String, dynamic> json) {
    return OrganFunctionModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      functionName: json['function_name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'function_name': functionName,
      'description': description,
    };
  }
}

class OrganRelationshipModel extends OrganRelationship {
  const OrganRelationshipModel({
    required super.id,
    required super.sourceOrganId,
    required super.targetOrganId,
    required super.relationshipType,
    required super.description,
  });

  factory OrganRelationshipModel.fromJson(Map<String, dynamic> json) {
    return OrganRelationshipModel(
      id: json['id'] as String,
      sourceOrganId: json['source_organ_id'] as String,
      targetOrganId: json['target_organ_id'] as String,
      relationshipType: json['relationship_type'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source_organ_id': sourceOrganId,
      'target_organ_id': targetOrganId,
      'relationship_type': relationshipType,
      'description': description,
    };
  }
}

class OrganBiomarkerModel extends OrganBiomarker {
  const OrganBiomarkerModel({
    required super.id,
    required super.organId,
    required super.name,
    required super.description,
    required super.normalRange,
    required super.unit,
  });

  factory OrganBiomarkerModel.fromJson(Map<String, dynamic> json) {
    return OrganBiomarkerModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      normalRange: json['normal_range'] as String,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'name': name,
      'description': description,
      'normal_range': normalRange,
      'unit': unit,
    };
  }
}

class OrganSymptomModel extends OrganSymptom {
  const OrganSymptomModel({
    required super.id,
    required super.organId,
    required super.symptomName,
    required super.description,
    required super.severityLevel,
  });

  factory OrganSymptomModel.fromJson(Map<String, dynamic> json) {
    return OrganSymptomModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      symptomName: json['symptom_name'] as String,
      description: json['description'] as String,
      severityLevel: json['severity_level'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'symptom_name': symptomName,
      'description': description,
      'severity_level': severityLevel,
    };
  }
}

class OrganDiseaseModel extends OrganDisease {
  const OrganDiseaseModel({
    required super.id,
    required super.organId,
    required super.diseaseName,
    required super.description,
    required super.clinicalMarkers,
  });

  factory OrganDiseaseModel.fromJson(Map<String, dynamic> json) {
    final rawMarkers = json['clinical_markers'];
    List<String> markers = [];
    if (rawMarkers is List) {
      markers = rawMarkers.map((e) => e.toString()).toList();
    }
    return OrganDiseaseModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      diseaseName: json['disease_name'] as String,
      description: json['description'] as String,
      clinicalMarkers: markers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'disease_name': diseaseName,
      'description': description,
      'clinical_markers': clinicalMarkers,
    };
  }
}

class OrganNutrientModel extends OrganNutrient {
  const OrganNutrientModel({
    required super.id,
    required super.organId,
    required super.nutrientName,
    required super.description,
    super.recommendedDailyIntake,
  });

  factory OrganNutrientModel.fromJson(Map<String, dynamic> json) {
    return OrganNutrientModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      nutrientName: json['nutrient_name'] as String,
      description: json['description'] as String,
      recommendedDailyIntake: json['recommended_daily_intake'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'nutrient_name': nutrientName,
      'description': description,
      'recommended_daily_intake': recommendedDailyIntake,
    };
  }
}

class OrganHormoneModel extends OrganHormone {
  const OrganHormoneModel({
    required super.id,
    required super.organId,
    required super.hormoneName,
    required super.description,
    required super.physiologicalRole,
  });

  factory OrganHormoneModel.fromJson(Map<String, dynamic> json) {
    return OrganHormoneModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      hormoneName: json['hormone_name'] as String,
      description: json['description'] as String,
      physiologicalRole: json['physiological_role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'hormone_name': hormoneName,
      'description': description,
      'physiological_role': physiologicalRole,
    };
  }
}

class OrganMedicationModel extends OrganMedication {
  const OrganMedicationModel({
    required super.id,
    required super.organId,
    required super.medicationName,
    required super.description,
    required super.mechanismOfAction,
  });

  factory OrganMedicationModel.fromJson(Map<String, dynamic> json) {
    return OrganMedicationModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      medicationName: json['medication_name'] as String,
      description: json['description'] as String,
      mechanismOfAction: json['mechanism_of_action'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'medication_name': medicationName,
      'description': description,
      'mechanism_of_action': mechanismOfAction,
    };
  }
}

class OrganLabTestModel extends OrganLabTest {
  const OrganLabTestModel({
    required super.id,
    required super.organId,
    required super.testName,
    required super.description,
    required super.standardThresholds,
  });

  factory OrganLabTestModel.fromJson(Map<String, dynamic> json) {
    return OrganLabTestModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      testName: json['test_name'] as String,
      description: json['description'] as String,
      standardThresholds: json['standard_thresholds'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'test_name': testName,
      'description': description,
      'standard_thresholds': standardThresholds,
    };
  }
}

class OrganWearableModel extends OrganWearable {
  const OrganWearableModel({
    required super.id,
    required super.organId,
    required super.metricName,
    required super.description,
    required super.frequency,
  });

  factory OrganWearableModel.fromJson(Map<String, dynamic> json) {
    return OrganWearableModel(
      id: json['id'] as String,
      organId: json['organ_id'] as String,
      metricName: json['metric_name'] as String,
      description: json['description'] as String,
      frequency: json['frequency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'organ_id': organId,
      'metric_name': metricName,
      'description': description,
      'frequency': frequency,
    };
  }
}

class MedicalReferenceModel extends MedicalReference {
  const MedicalReferenceModel({
    required super.id,
    required super.title,
    required super.authors,
    required super.journal,
    required super.publicationYear,
    super.doi,
    super.url,
  });

  factory MedicalReferenceModel.fromJson(Map<String, dynamic> json) {
    return MedicalReferenceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      authors: json['authors'] as String,
      journal: json['journal'] as String,
      publicationYear: json['publication_year'] as int,
      doi: json['doi'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'journal': journal,
      'publication_year': publicationYear,
      'doi': doi,
      'url': url,
    };
  }
}
