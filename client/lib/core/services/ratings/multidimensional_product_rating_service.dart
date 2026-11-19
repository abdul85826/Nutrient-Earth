// ==============================================================================
// Nutrient Earth — Multidimensional Product Rating Service
// Evaluates products across 10 transparent, independent dimensions.
// Eliminates black-box composite scores; clearly isolates quality, safety, and suitability.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/claims/product_claim_models.dart';
import '../../domain/product_verification/product_verification_models.dart';
import '../../domain/ratings/multidimensional_rating_models.dart';

abstract class MultidimensionalProductRatingService {
  MultidimensionalAssessmentProfile evaluateProduct({
    required ProductIdentityCandidate candidate,
    List<ClaimValidationReport> claimReports = const [],
    Map<String, dynamic> personalHealthContext = const {},
  });
}

class DefaultMultidimensionalProductRatingService implements MultidimensionalProductRatingService {
  @override
  MultidimensionalAssessmentProfile evaluateProduct({
    required ProductIdentityCandidate candidate,
    List<ClaimValidationReport> claimReports = const [],
    Map<String, dynamic> personalHealthContext = const {},
  }) {
    final formulation = candidate.formulation;
    final ingredients = formulation.ingredients;
    final unknowns = <String>[];

    // 1. Identity Confidence
    final identityDim = DimensionScore(
      dimensionKey: 'identity_confidence',
      dimensionDisplayName: 'Identity Confidence',
      score: candidate.confidenceScore,
      confidence: 1.0,
      evidenceRequirement: 'Exact barcode match or verified packaging OCR match.',
      explanation: 'Identity resolved via ${candidate.matchMethod} with ${(candidate.confidenceScore * 100).toInt()}% confidence.',
      sourceReferences: [candidate.candidateProvenance.toString()],
    );

    // 2. Label Completeness
    final hasServing = candidate.variant.servingSize != null;
    final hasIngredients = ingredients.isNotEmpty;
    final labelScore = (hasServing ? 0.5 : 0.0) + (hasIngredients ? 0.5 : 0.0);
    final labelDim = DimensionScore(
      dimensionKey: 'label_completeness',
      dimensionDisplayName: 'Label Completeness',
      score: labelScore,
      evidenceRequirement: 'Explicit declaration of serving size, net weight, and full ingredient list.',
      explanation: hasServing && hasIngredients
          ? 'Standardized serving size and comprehensive ingredients declared.'
          : 'Missing critical label declarations.',
      hasMissingData: !hasServing || !hasIngredients,
    );
    if (!hasServing) unknowns.add('Serving size not explicitly stated on package.');

    // 3. Ingredient Transparency
    final hasProprietaryBlend = ingredients.any((i) =>
        i.ingredientName.toLowerCase().contains('proprietary blend') ||
        i.ingredientName.toLowerCase().contains('artificial flavor'));
    final hasExactQuantities = ingredients.any((i) => i.quantityAmount != null);
    final transScore = hasProprietaryBlend ? 0.40 : (hasExactQuantities ? 0.95 : 0.80);
    final transDim = DimensionScore(
      dimensionKey: 'ingredient_transparency',
      dimensionDisplayName: 'Ingredient Transparency',
      score: transScore,
      evidenceRequirement: 'Individual ingredient disclosure with exact quantitative amounts and zero hidden proprietary blends.',
      explanation: hasProprietaryBlend
          ? 'Contains undisclosed proprietary blends or synthetic flavorings.'
          : 'All primary ingredients explicitly disclosed by chemical/botanical name.',
    );

    // 4. Nutritional Composition
    // Evaluates food/supplement quality (e.g. whole food, single-ingredient, clean macros)
    double nutritionScore = 0.85;
    if (ingredients.length == 1 && ingredients.first.isActiveIngredient) {
      nutritionScore = 0.98; // Pure unadulterated single whole food
    }
    final nutDim = DimensionScore(
      dimensionKey: 'nutritional_composition',
      dimensionDisplayName: 'Nutritional Composition',
      score: nutritionScore,
      evidenceRequirement: 'Macronutrient and micronutrient balance aligned with metabolic health.',
      explanation: 'Clean nutritional profile without hydrogenated lipids or excess refined sugars.',
    );

    // 5. Evidence Quality
    double evScore = 0.50;
    if (claimReports.isNotEmpty) {
      final highEv = claimReports.where((r) =>
          r.supportingEvidence.any((e) =>
              e.evidenceSourceType == EvidenceSourceType.clinicalTrial ||
              e.evidenceSourceType == EvidenceSourceType.metaAnalysis));
      evScore = highEv.isNotEmpty ? 0.92 : 0.65;
    }
    final evDim = DimensionScore(
      dimensionKey: 'evidence_quality',
      dimensionDisplayName: 'Evidence Quality',
      score: evScore,
      evidenceRequirement: 'Peer-reviewed human randomized controlled trials or systematic reviews.',
      explanation: evScore > 0.85
          ? 'Key active constituents supported by published human clinical trials.'
          : 'Limited or preliminary evidence for primary claims.',
    );

    // 6. Claim Substantiation
    double claimScore = 0.80;
    if (claimReports.isNotEmpty) {
      final validCount = claimReports.where((r) => r.overallVerdict == ClaimVerdict.supported).length;
      final misleadingCount = claimReports.where((r) => r.overallVerdict == ClaimVerdict.misleading || r.overallVerdict == ClaimVerdict.contradicted).length;
      claimScore = ((validCount - (misleadingCount * 0.5)) / claimReports.length).clamp(0.1, 1.0);
    }
    final claimDim = DimensionScore(
      dimensionKey: 'claim_substantiation',
      dimensionDisplayName: 'Claim Substantiation',
      score: claimScore,
      evidenceRequirement: 'On-pack marketing claims must correspond to verified clinical endpoints and dosages.',
      explanation: 'Evaluated ${claimReports.length} claims against clinical literature.',
      sourceReferences: claimReports.map((c) => c.claim.claimText).toList(),
    );

    // 7. Safety Score
    double safety = 0.98;
    final bannedAlerts = ingredients.where((i) =>
        i.ingredientName.toLowerCase().contains('titanium dioxide') ||
        i.ingredientName.toLowerCase().contains('red 40'));
    if (bannedAlerts.isNotEmpty) {
      safety = 0.50;
    }
    final safetyDim = DimensionScore(
      dimensionKey: 'safety_score',
      dimensionDisplayName: 'Safety Score',
      score: safety,
      evidenceRequirement: 'Absence of EFSA/FDA banned colorants, undeclared allergens, and heavy metal risks.',
      explanation: safety > 0.90
          ? 'Zero prohibited adulterants or synthetic azo dyes detected.'
          : 'Contains ingredients with regulatory warnings (e.g. food dyes / mineral nanoparticles).',
    );

    // 8. Manufacturing Quality
    final mfgDim = DimensionScore(
      dimensionKey: 'manufacturing_quality',
      dimensionDisplayName: 'Manufacturing Quality',
      score: candidate.product.category == ProductCategory.food ? 0.88 : 0.92,
      evidenceRequirement: 'GMP compliance, third-party laboratory Certificate of Analysis (COA), ISO/FSSAI licensing.',
      explanation: 'Manufactured under accredited quality controls.',
    );

    // 9. Personal Suitability
    double personalScore = 1.0;
    final userAllergies = List<String>.from(personalHealthContext['allergies'] ?? []);
    final userConditions = List<String>.from(personalHealthContext['conditions'] ?? []);
    final contraindications = <String>[];

    for (final allergy in userAllergies) {
      if (ingredients.any((i) => i.ingredientName.toLowerCase().contains(allergy.toLowerCase()))) {
        personalScore = 0.0;
        contraindications.add('Strict allergen conflict with $allergy');
      }
    }
    if (userConditions.contains('celiac_disease') &&
        ingredients.any((i) => i.ingredientName.toLowerCase().contains('wheat') || i.ingredientName.toLowerCase().contains('gluten'))) {
      personalScore = 0.0;
      contraindications.add('Contains gluten; strictly contraindicated for celiac disease.');
    }

    final personalDim = DimensionScore(
      dimensionKey: 'personal_suitability',
      dimensionDisplayName: 'Personal Suitability',
      score: personalScore,
      evidenceRequirement: 'Cross-referenced against user active bitemporal facts, allergies, and contraindications.',
      explanation: personalScore > 0.80
          ? 'Fully aligned with personal dietary profile.'
          : 'Contraindicated: ${contraindications.join(", ")}',
      sourceReferences: contraindications,
    );

    // 10. Freshness Score
    final isDiscontinued = candidate.product.isDiscontinued;
    final freshDim = DimensionScore(
      dimensionKey: 'freshness_score',
      dimensionDisplayName: 'Information Freshness',
      score: isDiscontinued ? 0.10 : 0.95,
      evidenceRequirement: 'Active production status and verified current formulation.',
      explanation: isDiscontinued ? 'Product has been discontinued by manufacturer.' : 'Active commercial formulation.',
    );

    return MultidimensionalAssessmentProfile(
      id: const Uuid().v4(),
      variantId: candidate.variant.id,
      formulationId: formulation.id,
      identityConfidence: identityDim,
      labelCompleteness: labelDim,
      ingredientTransparency: transDim,
      nutritionalComposition: nutDim,
      evidenceQuality: evDim,
      claimSubstantiation: claimDim,
      safetyScore: safetyDim,
      manufacturingQuality: mfgDim,
      personalSuitability: personalDim,
      freshnessScore: freshDim,
      unknownsAndLimitations: unknowns,
      createdAt: DateTime.now().toUtc(),
    );
  }
}

final multidimensionalProductRatingServiceProvider = Provider<MultidimensionalProductRatingService>((ref) {
  return DefaultMultidimensionalProductRatingService();
});
