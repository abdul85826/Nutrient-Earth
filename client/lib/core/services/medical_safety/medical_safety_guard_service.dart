// ==============================================================================
// Nutrient Earth — Medical Safety & Oncology Intelligence Guard
// Handles sensitive clinical and high-stakes medical inquiries:
// - Refuses neither with useless boilerplate nor prescribes recklessly
// - Explains oncology complexity: cancer is a spectrum of diseases governed by
//   type, stage, histology, and molecular biomarkers (HER2, EGFR, KRAS, PD-L1)
// - Outlines multimodal standard of care (surgery, chemo, targeted, immunotherapy, radiation)
// - Formulates specific, empowered questions for the treating oncologist
// - Strict Non-Prescription Directive: Diagnostic and dosing decisions remain with clinicians
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MedicalQueryTriageCategory {
  emergencyLifeThreatening, // Chest pain, stroke, severe anaphylaxis -> Immediate 911/112 referral
  oncologyTherapyOverview,  // "What medicine is for cancer?" -> Nuanced oncology educational triage
  medicationInteractionCheck,// Drug-herb, drug-supplement safety
  generalClinicalEducation; // Symptom understanding, lab test reference ranges
}

class MedicalTriageEvaluation {
  final MedicalQueryTriageCategory category;
  final bool requiresEmergencyInterruption;
  final String structuredResponse;
  final List<String> questionsForClinician;
  final List<String> clinicalGuidelinesReferenced;
  final String safetyBoundaryNotice;

  const MedicalTriageEvaluation({
    required this.category,
    this.requiresEmergencyInterruption = false,
    required this.structuredResponse,
    this.questionsForClinician = const [],
    this.clinicalGuidelinesReferenced = const [],
    required this.safetyBoundaryNotice,
  });
}

class MedicalContraindicationResult {
  final bool hasContraindication;
  final String severity; // 'critical', 'warning', 'info'
  final String contraindicationDescription;
  final String clinicalRationale;
  final List<String> safeAlternatives;
  final List<String> guidelines;

  const MedicalContraindicationResult({
    required this.hasContraindication,
    this.severity = 'info',
    this.contraindicationDescription = '',
    this.clinicalRationale = '',
    this.safeAlternatives = const [],
    this.guidelines = const [],
  });

  static const safe = MedicalContraindicationResult(hasContraindication: false);
}

abstract class MedicalSafetyGuardService {
  MedicalTriageEvaluation evaluateMedicalQuery({
    required String query,
    Map<String, dynamic>? userHealthContext,
  });

  bool isHighStakesQuery(String query);

  MedicalContraindicationResult checkContraindications({
    required String queryOrItem,
    required List<String> knownConditions,
    required List<String> knownAllergies,
    required List<String> activeMedications,
  });
}

class DefaultMedicalSafetyGuardService implements MedicalSafetyGuardService {
  static final List<String> _emergencyTerms = [
    'chest pain',
    'heart attack',
    'stroke',
    'face drooping',
    'severe bleeding',
    'cannot breathe',
    'anaphylaxis',
    'suicidal',
    'overdose',
  ];

  static final List<String> _oncologyTerms = [
    'cancer',
    'tumor',
    'tumour',
    'oncology',
    'chemotherapy',
    'immunotherapy',
    'carcinoma',
    'lymphoma',
    'leukemia',
    'metastasis',
    'biopsy',
  ];

  @override
  bool isHighStakesQuery(String query) {
    final lower = query.toLowerCase();
    return _emergencyTerms.any((t) => lower.contains(t)) || _oncologyTerms.any((t) => lower.contains(t));
  }

  @override
  MedicalTriageEvaluation evaluateMedicalQuery({
    required String query,
    Map<String, dynamic>? userHealthContext,
  }) {
    final lower = query.toLowerCase().trim();

    // 1. Emergency Life-Threatening Triage
    if (_emergencyTerms.any((t) => lower.contains(t))) {
      return const MedicalTriageEvaluation(
        category: MedicalQueryTriageCategory.emergencyLifeThreatening,
        requiresEmergencyInterruption: true,
        structuredResponse:
            'EMERGENCY SAFETY TRIAGE: Your query indicates symptoms that require immediate, emergency medical evaluation. '
            'Please call your local emergency services (112 in India, 911 in the US) or go to the nearest emergency room immediately.',
        safetyBoundaryNotice:
            'Nutrient Earth does not provide emergency triage services. Seek immediate emergency care.',
      );
    }

    // 2. Oncology / Cancer Treatment Inquiry
    if (_oncologyTerms.any((t) => lower.contains(t))) {
      return MedicalTriageEvaluation(
        category: MedicalQueryTriageCategory.oncologyTherapyOverview,
        requiresEmergencyInterruption: false,
        structuredResponse: _generateOncologyGuidanceResponse(query),
        questionsForClinician: [
          'What is the exact histological subtype and TNM stage of this cancer?',
          'Has comprehensive molecular profiling or next-generation sequencing (NGS) been conducted for targetable biomarkers (e.g. EGFR, ALK, KRAS, BRAF, HER2, PD-L1)?',
          'What are the primary goals of the recommended regimen (curative vs. adjuvant vs. disease control)?',
          'Are there active clinical trials exploring novel targeted agents or immunotherapies for this specific biomarker profile?',
          'What supportive care or nutritional protocols are clinically safe to maintain lean mass and reduce treatment-related nausea without blunting therapeutic efficacy?',
        ],
        clinicalGuidelinesReferenced: [
          'NCCN (National Comprehensive Cancer Network) Clinical Practice Guidelines in Oncology',
          'ASCO (American Society of Clinical Oncology) Clinical Practice Guidelines',
          'ESMO (European Society for Medical Oncology) Clinical Practice Guidelines',
          'ICMR (Indian Council of Medical Research) Consensus Guidelines on Cancer Care',
        ],
        safetyBoundaryNotice:
            'Clinical Boundary: Cancer diagnosis, staging, and therapeutic prescriptions must be managed exclusively by a board-certified oncologist. Nutrient Earth provides evidence explanations and consultation questions to support informed clinical dialogue.',
      );
    }

    // 3. General Clinical / Medication Safety
    return const MedicalTriageEvaluation(
      category: MedicalQueryTriageCategory.generalClinicalEducation,
      requiresEmergencyInterruption: false,
      structuredResponse:
          'Educational overview of clinical concepts based on peer-reviewed pharmacology and physiology literature.',
      safetyBoundaryNotice:
          'Educational content only. Consult your healthcare provider before altering prescribed treatment.',
    );
  }

  String _generateOncologyGuidanceResponse(String query) {
    return '''Cancer is not a single disease, and there is no single medicine that treats every cancer. 

Scientifically, cancer is a diverse family of over 200 distinct cellular diseases characterized by uncontrolled proliferation. Modern oncology treatment depends entirely on:
1. **Specific Cancer Origin & Histology** (e.g. adenocarcinoma, squamous cell, sarcoma, hematologic)
2. **Clinical Staging** (TNM stage I to IV, local vs. metastatic spread)
3. **Molecular & Genetic Biomarkers** (e.g. HER2 amplification, EGFR mutations, BRCA status, Microsatellite Instability [MSI-H], PD-L1 expression)
4. **Prior Treatments & Performance Status** (cardiac, renal, hepatic functional reserves)

### Evidence-Supported Treatment Modalities:
- **Surgical Resection**: Primary local control for solid tumors prior to dissemination.
- **Radiation Therapy**: Targeted ionizing radiation (IMRT, SBRT, Proton therapy) for localized tumor disruption.
- **Systemic Chemotherapy**: Cytotoxic agents disrupting rapid DNA synthesis and mitotic cell division.
- **Targeted Therapies**: Small-molecule kinase inhibitors and monoclonal antibodies engineered against specific genetic mutations (e.g. Osimertinib for EGFR-mutant lung cancer, Trastuzumab for HER2+ breast cancer).
- **Immunotherapy (Immune Checkpoint Inhibitors)**: Monoclonal antibodies (e.g. Pembrolizumab, Nivolumab) that block PD-1/PD-L1 or CTLA-4, releasing the body\'s own T-cells to identify and eliminate cancer cells.
- **Hormone (Endocrine) Therapy**: Blocker agents for hormone-dependent malignancies (e.g. Tamoxifen, Aromatase inhibitors, Androgen deprivation therapy).

To explore evidence for a specific situation, knowing the exact cancer type, stage, and biomarker report is essential. Below are high-priority questions to review with your oncologist.''';
  }

  @override
  MedicalContraindicationResult checkContraindications({
    required String queryOrItem,
    required List<String> knownConditions,
    required List<String> knownAllergies,
    required List<String> activeMedications,
  }) {
    final lowerItem = queryOrItem.toLowerCase();
    final lowerConditions = knownConditions.map((c) => c.toLowerCase()).toList();
    final lowerAllergies = knownAllergies.map((a) => a.toLowerCase()).toList();
    final lowerMeds = activeMedications.map((m) => m.toLowerCase()).toList();

    // 1. Potassium Salt Substitute + ACE-Inhibitors / ARBs / Potassium-Sparing Diuretics / CKD
    final isPotassiumQuery = lowerItem.contains('potassium') ||
        lowerItem.contains('salt substitute') ||
        lowerItem.contains('kcl') ||
        lowerItem.contains('low sodium salt');
    final takesAceOrArbOrKSpares = lowerMeds.any((m) =>
        m.contains('lisinopril') ||
        m.contains('ramipril') ||
        m.contains('enalapril') ||
        m.contains('losartan') ||
        m.contains('valsartan') ||
        m.contains('spironolactone') ||
        m.contains('eplerenone') ||
        m.contains('triamterene'));
    final hasCkd = lowerConditions.any((c) =>
        c.contains('ckd') ||
        c.contains('kidney disease') ||
        c.contains('renal insufficiency') ||
        c.contains('reduced egfr'));

    if (isPotassiumQuery && (takesAceOrArbOrKSpares || hasCkd)) {
      return const MedicalContraindicationResult(
        hasContraindication: true,
        severity: 'critical',
        contraindicationDescription:
            'Critical Hyperkalemia Risk: Concomitant potassium supplements or potassium-chloride-based salt substitutes with ACE-inhibitors, ARBs, aldosterone antagonists, or impaired renal clearance can trigger life-threatening hyperkalemia (serum K+ > 5.5 mEq/L) and fatal cardiac conduction abnormalities.',
        clinicalRationale:
            'Inhibition of the renin-angiotensin-aldosterone axis reduces renal potassium secretion. Ingesting potassium salt substitutes (which often contain ~2,500 mg K+ per teaspoon) rapidly overwhelms compensatory excretion channels.',
        safeAlternatives: [
          'Flavor meals using potassium-free herbal seasonings (black pepper, roasted cumin, smoked paprika, garlic and onion powder, dried oregano, lemon zest, sumac).',
          'Use moderate iodized salt within guideline-directed sodium limits (under 2,000 mg/day) rather than replacing sodium with high potassium chloride.',
          'Consult your prescribing physician or nephrologist before introducing any commercial "low-sodium salt substitute".'
        ],
        guidelines: [
          'AHA/ACC Guideline for the Prevention, Detection, Evaluation, and Management of High Blood Pressure',
          'KDIGO Clinical Practice Guideline for the Management of Blood Pressure in Chronic Kidney Disease',
        ],
      );
    }

    // 2. Tree Nut / Peanut Allergy
    final mentionsNuts = lowerItem.contains('almond') ||
        lowerItem.contains('peanut') ||
        lowerItem.contains('walnut') ||
        lowerItem.contains('cashew') ||
        lowerItem.contains('pistachio') ||
        lowerItem.contains('hazelnut') ||
        lowerItem.contains('nut flour');
    final hasNutAllergy = lowerAllergies.any((a) =>
        a.contains('nut') ||
        a.contains('peanut') ||
        a.contains('almond') ||
        a.contains('tree nut'));

    if (mentionsNuts && hasNutAllergy) {
      return const MedicalContraindicationResult(
        hasContraindication: true,
        severity: 'critical',
        contraindicationDescription:
            'Severe Anaphylaxis Alert: The requested ingredient/recipe contains nuts or nut derivatives which directly conflicts with your documented allergy profile.',
        clinicalRationale:
            'IgE-mediated hypersensitivity to storage proteins (e.g., Ara h proteins in peanuts, Cor a in hazelnuts) can precipitate acute bronchospasm, laryngeal angioedema, gastrointestinal collapse, and distributive shock within minutes.',
        safeAlternatives: [
          'Use sunflower seed flour or pumpkin seed (pepita) flour as a direct 1:1 replacement in baking.',
          'Substitute seed butters (tahini, sunflower seed butter) for nut butters.',
          'Use certified nut-free oat flour, besan (chickpea flour), or tiger nut flour (tubers, not true nuts).'
        ],
        guidelines: [
          'EAACI (European Academy of Allergy and Clinical Immunology) Guidelines on Food Allergy and Anaphylaxis',
          'AAAAI/ACAAI Practice Parameter: Food Allergy: A practice parameter update',
        ],
      );
    }

    // 3. Statin + Grapefruit CYP3A4 Inhibition
    final mentionsGrapefruit = lowerItem.contains('grapefruit') || lowerItem.contains('pomelo');
    final takesCyp3a4Statin = lowerMeds.any((m) =>
        m.contains('atorvastatin') ||
        m.contains('simvastatin') ||
        m.contains('lovastatin'));

    if (mentionsGrapefruit && takesCyp3a4Statin) {
      return const MedicalContraindicationResult(
        hasContraindication: true,
        severity: 'warning',
        contraindicationDescription:
            'Pharmacokinetic Interaction Warning: Grapefruit and pomelo contain furanocoumarins (bergamottin) that irreversibly inhibit intestinal CYP3A4 enzymes, dramatically multiplying statin plasma concentrations.',
        clinicalRationale:
            'Loss of first-pass intestinal metabolism leads to toxic statin accumulation, dramatically increasing the risk of myopathy, myalgia, and severe rhabdomyolysis.',
        safeAlternatives: [
          'Consume sweet oranges, mandarins, lemons, or limes which do not contain CYP3A4-inhibiting furanocoumarins.',
          'Maintain a minimum 24-48 hour separation if grapefruit is occasionally consumed, or discuss non-CYP3A4 statins (rosuvastatin, pravastatin) with your doctor.'
        ],
        guidelines: [
          'FDA Drug Safety Communication: Grapefruit Juice and Some Drugs Don\'t Mix',
          'ACC/AHA Guideline on the Management of Blood Cholesterol',
        ],
      );
    }

    return MedicalContraindicationResult.safe;
  }
}

final medicalSafetyGuardServiceProvider = Provider<MedicalSafetyGuardService>((ref) {
  return DefaultMedicalSafetyGuardService();
});
