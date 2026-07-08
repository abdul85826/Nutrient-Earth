class BodySystem {
  final String id;
  final String name;
  final String? description;

  const BodySystem({
    required this.id,
    required this.name,
    this.description,
  });
}

class Organ {
  final String id;
  final String systemId;
  final String displayName;
  final String scientificName;
  final String description;
  final String position;
  final String anatomy;
  final String bloodSupply;
  final String innervation;
  final String? imageUrl;
  final String? model3dRef;
  final List<String> futureMlFeatures;

  const Organ({
    required this.id,
    required this.systemId,
    required this.displayName,
    required this.scientificName,
    required this.description,
    required this.position,
    required this.anatomy,
    required this.bloodSupply,
    required this.innervation,
    this.imageUrl,
    this.model3dRef,
    required this.futureMlFeatures,
  });
}

class OrganFunction {
  final String id;
  final String organId;
  final String functionName;
  final String description;

  const OrganFunction({
    required this.id,
    required this.organId,
    required this.functionName,
    required this.description,
  });
}

class OrganRelationship {
  final String id;
  final String sourceOrganId;
  final String targetOrganId;
  final String relationshipType;
  final String description;

  const OrganRelationship({
    required this.id,
    required this.sourceOrganId,
    required this.targetOrganId,
    required this.relationshipType,
    required this.description,
  });
}

class OrganBiomarker {
  final String id;
  final String organId;
  final String name;
  final String description;
  final String normalRange;
  final String unit;

  const OrganBiomarker({
    required this.id,
    required this.organId,
    required this.name,
    required this.description,
    required this.normalRange,
    required this.unit,
  });
}

class OrganSymptom {
  final String id;
  final String organId;
  final String symptomName;
  final String description;
  final int severityLevel;

  const OrganSymptom({
    required this.id,
    required this.organId,
    required this.symptomName,
    required this.description,
    required this.severityLevel,
  });
}

class OrganDisease {
  final String id;
  final String organId;
  final String diseaseName;
  final String description;
  final List<String> clinicalMarkers;

  const OrganDisease({
    required this.id,
    required this.organId,
    required this.diseaseName,
    required this.description,
    required this.clinicalMarkers,
  });
}

class OrganNutrient {
  final String id;
  final String organId;
  final String nutrientName;
  final String description;
  final String? recommendedDailyIntake;

  const OrganNutrient({
    required this.id,
    required this.organId,
    required this.nutrientName,
    required this.description,
    this.recommendedDailyIntake,
  });
}

class OrganHormone {
  final String id;
  final String organId;
  final String hormoneName;
  final String description;
  final String physiologicalRole;

  const OrganHormone({
    required this.id,
    required this.organId,
    required this.hormoneName,
    required this.description,
    required this.physiologicalRole,
  });
}

class OrganMedication {
  final String id;
  final String organId;
  final String medicationName;
  final String description;
  final String mechanismOfAction;

  const OrganMedication({
    required this.id,
    required this.organId,
    required this.medicationName,
    required this.description,
    required this.mechanismOfAction,
  });
}

class OrganLabTest {
  final String id;
  final String organId;
  final String testName;
  final String description;
  final String standardThresholds;

  const OrganLabTest({
    required this.id,
    required this.organId,
    required this.testName,
    required this.description,
    required this.standardThresholds,
  });
}

class OrganWearable {
  final String id;
  final String organId;
  final String metricName;
  final String description;
  final String frequency;

  const OrganWearable({
    required this.id,
    required this.organId,
    required this.metricName,
    required this.description,
    required this.frequency,
  });
}

class MedicalReference {
  final String id;
  final String title;
  final String authors;
  final String journal;
  final int publicationYear;
  final String? doi;
  final String? url;

  const MedicalReference({
    required this.id,
    required this.title,
    required this.authors,
    required this.journal,
    required this.publicationYear,
    this.doi,
    this.url,
  });
}
