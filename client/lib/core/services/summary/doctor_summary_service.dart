// ==============================================================================
// Nutrient Earth — Doctor-Ready Health Summary Service
// Synthesizes a 9-section user-reviewed clinical consultation dossier.
// Distinguishes observed data, confirmed conditions, and missing information.
// Zero automatic external transmission — requires explicit user review & export.
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/memory/personal_health_memory_models.dart';
import '../memory/personal_health_memory_service.dart';
import '../profile_repository.dart';

class DoctorConsultationSummary {
  final String id;
  final String patientDisplayName;
  final int? age;
  final String? biologicalSex;
  final DateTime generatedAt;
  final List<String> chiefConcernsAndGoals;
  final List<HealthMemoryRecord> symptomTimeline;
  final List<HealthMemoryRecord> confirmedConditions;
  final List<HealthMemoryRecord> activeMedicationsAndSupplements;
  final List<HealthMemoryRecord> knownAllergies;
  final List<HealthMemoryRecord> recentBiomarkersAndLabs;
  final Map<String, String> lifestyleAndBiometrics;
  final List<String> questionsForClinician;
  final List<String> missingAndUncertainData;
  final String clinicalDisclaimer;

  const DoctorConsultationSummary({
    required this.id,
    required this.patientDisplayName,
    this.age,
    this.biologicalSex,
    required this.generatedAt,
    this.chiefConcernsAndGoals = const [],
    this.symptomTimeline = const [],
    this.confirmedConditions = const [],
    this.activeMedicationsAndSupplements = const [],
    this.knownAllergies = const [],
    this.recentBiomarkersAndLabs = const [],
    this.lifestyleAndBiometrics = const {},
    this.questionsForClinician = const [],
    this.missingAndUncertainData = const [],
    this.clinicalDisclaimer =
        'Nutrient Earth patient-curated briefing for healthcare consultation. Does not constitute an independent clinical diagnosis.',
  });

  String toFormattedClinicalText() {
    final buffer = StringBuffer();
    buffer.writeln('================================================================');
    buffer.writeln('NUTRIENT EARTH — PATIENT-PREPARED CLINICAL BRIEFING');
    buffer.writeln('Generated on: ${generatedAt.toIso8601String().split('T').first}');
    buffer.writeln('Patient: $patientDisplayName | Age: ${age ?? "Unspecified"} | Biological Sex: ${biologicalSex ?? "Unspecified"}');
    buffer.writeln('================================================================\n');

    buffer.writeln('1. CHIEF CONCERNS & WELLNESS GOALS:');
    if (chiefConcernsAndGoals.isEmpty) {
      buffer.writeln('   - General health review and preventative lifestyle consultation.');
    } else {
      for (final goal in chiefConcernsAndGoals) {
        buffer.writeln('   - $goal');
      }
    }
    buffer.writeln('');

    buffer.writeln('2. SYMPTOM TIMELINE & REPORTED ISSUES:');
    if (symptomTimeline.isEmpty) {
      buffer.writeln('   - No active acute symptoms reported by patient.');
    } else {
      for (final s in symptomTimeline) {
        final date = s.observedDate != null ? ' (${s.observedDate!.toIso8601String().split('T').first})' : '';
        buffer.writeln('   - ${s.entityName}${s.recordValue != null ? ": ${s.recordValue!}" : ""}$date [${s.provenanceSource.label}]');
      }
    }
    buffer.writeln('');

    buffer.writeln('3. CONFIRMED MEDICAL HISTORY & CONDITIONS:');
    if (confirmedConditions.isEmpty) {
      buffer.writeln('   - No confirmed chronic conditions declared in verified memory.');
    } else {
      for (final c in confirmedConditions) {
        buffer.writeln('   - ${c.entityName} [Verified: ${c.verificationStatus.displayName}]');
      }
    }
    buffer.writeln('');

    buffer.writeln('4. ACTIVE MEDICATIONS & SUPPLEMENTS:');
    if (activeMedicationsAndSupplements.isEmpty) {
      buffer.writeln('   - No active medications or dietary supplements listed.');
    } else {
      for (final m in activeMedicationsAndSupplements) {
        final dose = m.recordValue != null ? ' (${m.recordValue} ${m.recordUnit ?? ""})' : '';
        buffer.writeln('   - [${m.recordType.displayName}] ${m.entityName}$dose');
      }
    }
    buffer.writeln('');

    buffer.writeln('5. ALLERGIES & ADVERSE REACTIONS:');
    if (knownAllergies.isEmpty) {
      buffer.writeln('   - No documented adverse allergies.');
    } else {
      for (final a in knownAllergies) {
        buffer.writeln('   - ${a.entityName}${a.recordValue != null ? ": ${a.recordValue!}" : ""}');
      }
    }
    buffer.writeln('');

    buffer.writeln('6. RECENT BIOMARKERS & LAB RESULTS:');
    if (recentBiomarkersAndLabs.isEmpty) {
      buffer.writeln('   - No recent clinical laboratory records uploaded.');
    } else {
      for (final lab in recentBiomarkersAndLabs) {
        final flag = lab.isAbnormal == true ? ' [OUTSIDE NORMAL RANGE]' : '';
        buffer.writeln('   - ${lab.entityName}: ${lab.recordValue ?? "--"} ${lab.recordUnit ?? ""} (Ref: ${lab.referenceRange ?? "N/A"})$flag');
      }
    }
    buffer.writeln('');

    buffer.writeln('7. LIFESTYLE & BIOMETRICS:');
    lifestyleAndBiometrics.forEach((key, val) {
      buffer.writeln('   - $key: $val');
    });
    buffer.writeln('');

    buffer.writeln('8. QUESTIONS PREPARED FOR CLINICIAN:');
    if (questionsForClinician.isEmpty) {
      buffer.writeln('   - Are my current dietary supplements synergistic with my bloodwork?');
      buffer.writeln('   - Should any specific biomarker be monitored at my next visit?');
    } else {
      for (final q in questionsForClinician) {
        buffer.writeln('   - $q');
      }
    }
    buffer.writeln('');

    buffer.writeln('9. DISCLOSURE OF UNCERTAIN / MISSING INFORMATION:');
    if (missingAndUncertainData.isEmpty) {
      buffer.writeln('   - Patient record contains verified baseline metrics.');
    } else {
      for (final item in missingAndUncertainData) {
        buffer.writeln('   - Note: $item');
      }
    }
    buffer.writeln('\n----------------------------------------------------------------');
    buffer.writeln('CONFIDENTIALITY NOTICE: $clinicalDisclaimer');
    buffer.writeln('----------------------------------------------------------------');

    return buffer.toString();
  }
}

class DoctorSummaryService {
  final ProfileRepository _profileRepo;
  final PersonalHealthMemoryService _memoryService;

  const DoctorSummaryService({
    required ProfileRepository profileRepo,
    required PersonalHealthMemoryService memoryService,
  })  : _profileRepo = profileRepo,
        _memoryService = memoryService;

  Future<DoctorConsultationSummary> compileConsultationSummary({
    String? explicitUserId,
    List<String> customQuestions = const [],
  }) async {
    final profile = await _profileRepo.getCurrentUserProfile(explicitUserId: explicitUserId);
    final userId = profile?.userId ?? explicitUserId ?? 'usr_local_anon';

    // Fetch memory records
    final records = await _memoryService.getHealthRecords(userId: userId);

    final symptoms = records.where((r) => r.recordType == HealthRecordType.symptom).toList();
    final conditions = records
        .where((r) => r.recordType == HealthRecordType.condition && r.verificationStatus.isConfirmed)
        .toList();
    final medsAndSupplements = records
        .where((r) => r.recordType == HealthRecordType.medication || r.recordType == HealthRecordType.supplement)
        .toList();
    final allergies = records.where((r) => r.recordType == HealthRecordType.allergy).toList();
    final labs = records.where((r) => r.recordType == HealthRecordType.labResult).toList();

    // Map profile known conditions, supplements, and allergies if not yet in memory
    if (profile != null) {
      for (final cond in profile.knownConditions) {
        if (!conditions.any((c) => c.entityName.toLowerCase() == cond.toLowerCase())) {
          conditions.add(HealthMemoryRecord(
            id: 'prof_cond_${cond.hashCode}',
            userId: userId,
            recordType: HealthRecordType.condition,
            provenanceSource: MemoryProvenanceSource.userReported,
            entityName: cond,
            recordedDate: DateTime.now(),
            verificationStatus: MemoryVerificationStatus.userConfirmed,
          ));
        }
      }
      for (final supp in profile.activeSupplements) {
        if (!medsAndSupplements.any((m) => m.entityName.toLowerCase() == supp.toLowerCase())) {
          medsAndSupplements.add(HealthMemoryRecord(
            id: 'prof_supp_${supp.hashCode}',
            userId: userId,
            recordType: HealthRecordType.supplement,
            provenanceSource: MemoryProvenanceSource.userReported,
            entityName: supp,
            recordedDate: DateTime.now(),
            verificationStatus: MemoryVerificationStatus.userConfirmed,
          ));
        }
      }
      for (final allergy in profile.allergies) {
        if (!allergies.any((a) => a.entityName.toLowerCase() == allergy.toLowerCase())) {
          allergies.add(HealthMemoryRecord(
            id: 'prof_allergy_${allergy.hashCode}',
            userId: userId,
            recordType: HealthRecordType.allergy,
            provenanceSource: MemoryProvenanceSource.userReported,
            entityName: allergy,
            recordedDate: DateTime.now(),
            verificationStatus: MemoryVerificationStatus.userConfirmed,
          ));
        }
      }
    }

    final lifestyle = <String, String>{
      'Activity Cadence': profile?.activityLevel.toUpperCase() ?? 'MODERATE',
      'Dietary Baseline': profile?.dietaryPreference.toUpperCase() ?? 'OMNIVORE',
      'Sleep Architecture': profile?.sleepQuality.replaceAll('_', ' ').toUpperCase() ?? 'NORMAL',
    };
    if (profile?.heightCm != null) lifestyle['Height'] = '${profile!.heightCm} cm';
    if (profile?.weightKg != null) lifestyle['Weight'] = '${profile!.weightKg} kg';

    final missing = <String>[];
    if (labs.isEmpty) missing.add('No recent laboratory blood panel on file.');
    if (profile?.heightCm == null || profile?.weightKg == null) {
      missing.add('Height or weight not measured recently.');
    }

    final questions = List<String>.from(customQuestions);
    if (questions.isEmpty) {
      if (labs.any((l) => l.isAbnormal == true)) {
        final abnormalNames = labs.where((l) => l.isAbnormal == true).map((l) => l.entityName).join(', ');
        questions.add('What follow-up workup or lifestyle adjustments do you recommend for abnormal biomarker ($abnormalNames)?');
      }
      if (medsAndSupplements.isNotEmpty) {
        questions.add('Are there any contraindications between my active supplements and any recommended interventions?');
      }
      if (questions.isEmpty) {
        questions.add('What preventative screening intervals do you recommend based on my current age and baseline health profile?');
      }
    }

    return DoctorConsultationSummary(
      id: 'doc_summ_${DateTime.now().millisecondsSinceEpoch}',
      patientDisplayName: profile?.displayName ?? 'Patient',
      age: profile?.age,
      biologicalSex: profile?.biologicalSex,
      generatedAt: DateTime.now(),
      chiefConcernsAndGoals: profile?.primaryGoals ?? ['Preventative Health', 'Nutrition Review'],
      symptomTimeline: symptoms,
      confirmedConditions: conditions,
      activeMedicationsAndSupplements: medsAndSupplements,
      knownAllergies: allergies,
      recentBiomarkersAndLabs: labs,
      lifestyleAndBiometrics: lifestyle,
      questionsForClinician: questions,
      missingAndUncertainData: missing,
    );
  }
}

final doctorSummaryServiceProvider = Provider<DoctorSummaryService>((ref) {
  return DoctorSummaryService(
    profileRepo: ref.watch(profileRepositoryProvider),
    memoryService: ref.watch(personalHealthMemoryServiceProvider),
  );
});
