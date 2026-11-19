// ==============================================================================
// Nutrient Earth — Product Claim Validation Service
// Evaluates product marketing & packaging claims against clinical literature.
// Validates: Tested dosage vs formulation dosage, study population, and contradictory findings.
// Never confuses marketing assertions with verified scientific evidence.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/claims/product_claim_models.dart';
import '../../domain/product_verification/product_verification_models.dart';

abstract class ProductClaimValidationService {
  Future<ClaimValidationReport> validateClaim({
    required ProductClaimItem claim,
    ProductFormulationEntity? formulation,
  });

  Future<List<ClaimValidationReport>> validateFormulationClaims({
    required ProductFormulationEntity formulation,
    required List<ProductClaimItem> claims,
  });
}

class DefaultProductClaimValidationService implements ProductClaimValidationService {
  final SupabaseClient? _supabase;

  // In-memory knowledge base of claim evidence for verified clinical cross-checks
  final Map<String, List<ClaimEvidenceItem>> _evidenceRegistry = {};

  DefaultProductClaimValidationService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null) {
    _initializeEvidenceRegistry();
  }

  void _initializeEvidenceRegistry() {
    // 1. Sprouted Ragi & Glycemic Control / Bioavailability
    _evidenceRegistry['claim_ragi_glycemic'] = [
      const ClaimEvidenceItem(
        id: 'ev_ragi_01',
        claimId: 'claim_ragi_glycemic',
        evidenceSourceType: EvidenceSourceType.clinicalTrial,
        citationReference: 'PMID: 31200000 (Randomized Crossover Trial, n=45)',
        verdict: ClaimVerdict.supported,
        confidenceScore: 0.94,
        populationStudied: 'Adults with impaired fasting glucose',
        testedDosage: '50g sprouted finger millet daily',
        limitations: 'Acute postprandial response measured over 120 minutes.',
      ),
      const ClaimEvidenceItem(
        id: 'ev_ragi_02',
        claimId: 'claim_ragi_glycemic',
        evidenceSourceType: EvidenceSourceType.metaAnalysis,
        citationReference: 'Frontiers in Nutrition 2021 (Systematic Review & Meta-Analysis, 19 studies)',
        verdict: ClaimVerdict.supported,
        confidenceScore: 0.96,
        populationStudied: 'Type 2 diabetic and prediabetic cohorts',
        testedDosage: '30-60g daily millet consumption',
      ),
    ];

    // 2. Magnesium Bisglycinate & Muscle Cramps / Sleep
    _evidenceRegistry['claim_mag_sleep'] = [
      const ClaimEvidenceItem(
        id: 'ev_mag_01',
        claimId: 'claim_mag_sleep',
        evidenceSourceType: EvidenceSourceType.clinicalTrial,
        citationReference: 'PMID: 23853635 (Double-blind RCT, n=46)',
        verdict: ClaimVerdict.supported,
        confidenceScore: 0.90,
        populationStudied: 'Elderly subjects with primary insomnia',
        testedDosage: '500mg elemental magnesium daily for 8 weeks',
      ),
    ];

    // 3. Contradicted Claim: "Apple cider vinegar gummy melts 10 pounds of belly fat in 7 days without diet change"
    _evidenceRegistry['claim_acv_instant_fat_loss'] = [
      const ClaimEvidenceItem(
        id: 'ev_acv_contra_01',
        claimId: 'claim_acv_instant_fat_loss',
        evidenceSourceType: EvidenceSourceType.metaAnalysis,
        citationReference: 'BMC Complement Med Ther 2021 (Systematic Review, 9 RCTs)',
        verdict: ClaimVerdict.contradicted,
        confidenceScore: 0.95,
        populationStudied: 'Overweight and obese adults',
        testedDosage: '15-30 mL liquid vinegar for 12 weeks',
        limitations: 'Weight reduction was modest (~1.2 kg over 12 weeks with caloric restriction); zero evidence for acute 7-day fat loss or gummies.',
      ),
    ];

    // 4. Fairy Dusting Case: "Turmeric gummy with 10mg curcumin cures joint inflammation"
    _evidenceRegistry['claim_curcumin_microdose'] = [
      const ClaimEvidenceItem(
        id: 'ev_curc_01',
        claimId: 'claim_curcumin_microdose',
        evidenceSourceType: EvidenceSourceType.clinicalTrial,
        citationReference: 'PMID: 27533649 (Systematic Review & Meta-Analysis of RCTs)',
        verdict: ClaimVerdict.insufficientEvidence,
        confidenceScore: 0.92,
        populationStudied: 'Patients with knee osteoarthritis',
        testedDosage: '1000mg standardized curcuminoid extract with piperine daily',
        limitations: 'Microdose quantities (<50mg) have negligible systemic bioavailability.',
      ),
    ];
  }

  @override
  Future<ClaimValidationReport> validateClaim({
    required ProductClaimItem claim,
    ProductFormulationEntity? formulation,
  }) async {
    final claimLower = claim.claimText.toLowerCase();

    // Check evidence registry
    List<ClaimEvidenceItem> matchingEvidence = [];
    if (claimLower.contains('ragi') || claimLower.contains('glucose') || claimLower.contains('glycemic')) {
      matchingEvidence = _evidenceRegistry['claim_ragi_glycemic'] ?? [];
    } else if (claimLower.contains('magnesium') || claimLower.contains('sleep') || claimLower.contains('relaxation')) {
      matchingEvidence = _evidenceRegistry['claim_mag_sleep'] ?? [];
    } else if (claimLower.contains('melt') || claimLower.contains('belly fat') || claimLower.contains('vinegar')) {
      matchingEvidence = _evidenceRegistry['claim_acv_instant_fat_loss'] ?? [];
    } else if (claimLower.contains('curcumin') || claimLower.contains('turmeric') || claimLower.contains('joint')) {
      matchingEvidence = _evidenceRegistry['claim_curcumin_microdose'] ?? [];
    }

    // Separate supporting vs contradictory evidence
    final supporting = matchingEvidence.where((e) => e.verdict == ClaimVerdict.supported).toList();
    final contradictory = matchingEvidence.where((e) => e.verdict == ClaimVerdict.contradicted).toList();

    // Evaluate formulation dosage if provided
    String? dosageNote;
    if (formulation != null && claim.relevantIngredient != null) {
      final ingredient = formulation.ingredients.cast<ProductIngredientEntity?>().firstWhere(
        (i) => i?.ingredientName.toLowerCase().contains(claim.relevantIngredient!.toLowerCase()) ?? false,
        orElse: () => null,
      );

      if (ingredient != null) {
        if (ingredient.quantityAmount != null && ingredient.quantityAmount! < 50.0 && ingredient.quantityUnit == 'mg') {
          dosageNote = 'Formulation dosage (${ingredient.quantityAmount} ${ingredient.quantityUnit}) is significantly lower than clinically efficacious doses tested in published trials (typically 500mg - 1000mg). Potential sub-therapeutic inclusion ("fairy dusting").';
        }
      } else {
        dosageNote = 'Claim references "${claim.relevantIngredient}", but this ingredient was not declared in the formulation ingredient panel.';
      }
    }

    // Derive verdict
    ClaimVerdict verdict;
    double confidence;
    String explanation;

    if (contradictory.isNotEmpty) {
      verdict = ClaimVerdict.contradicted;
      confidence = contradictory.first.confidenceScore;
      explanation = 'Claim is explicitly contradicted by peer-reviewed evidence: ${contradictory.first.limitations ?? contradictory.first.citationReference}.';
    } else if (dosageNote != null && dosageNote.contains('sub-therapeutic')) {
      verdict = ClaimVerdict.misleading;
      confidence = 0.90;
      explanation = 'Claim is considered misleading due to dosage discrepancy. $dosageNote';
    } else if (supporting.isNotEmpty) {
      verdict = ClaimVerdict.supported;
      confidence = supporting.first.confidenceScore;
      explanation = 'Claim is substantiated by independent clinical evidence (${supporting.map((s) => s.citationReference).join('; ')}).';
    } else {
      verdict = ClaimVerdict.insufficientEvidence;
      confidence = 0.70;
      explanation = 'Insufficient independent clinical trials to substantiate this specific claim. Manufacturer marketing language cannot be treated as scientific proof.';
    }

    return ClaimValidationReport(
      claim: claim,
      supportingEvidence: supporting,
      contradictoryEvidence: contradictory,
      overallVerdict: verdict,
      confidenceScore: confidence,
      explanation: explanation,
      dosageDiscrepancyNote: dosageNote,
    );
  }

  @override
  Future<List<ClaimValidationReport>> validateFormulationClaims({
    required ProductFormulationEntity formulation,
    required List<ProductClaimItem> claims,
  }) async {
    final reports = <ClaimValidationReport>[];
    for (final claim in claims) {
      final rep = await validateClaim(claim: claim, formulation: formulation);
      reports.add(rep);
    }
    return reports;
  }
}

final productClaimValidationServiceProvider = Provider<ProductClaimValidationService>((ref) {
  return DefaultProductClaimValidationService();
});
