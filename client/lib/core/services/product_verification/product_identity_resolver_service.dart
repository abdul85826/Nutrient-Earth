// ==============================================================================
// Nutrient Earth — Product Identity Resolver Service
// Resolves: Company, Brand, Product, Variant, Formulation, and Barcode.
// Differentiates similar product names with distinct formulations.
// Enforces explicit confidence thresholds (>0.85) or prompts for clearer image/barcode.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/product_verification/product_verification_models.dart';

abstract class ProductIdentityResolverService {
  Future<ProductIdentityResolutionResult> resolveFromBarcode(String barcode);

  Future<ProductIdentityResolutionResult> resolveFromLabelOcr({
    required String brandNameCandidate,
    required String productNameCandidate,
    String? variantCandidate,
    List<String> visibleIngredients = const [],
  });

  bool validateBarcodeChecksum(String barcode);
}

class DefaultProductIdentityResolverService implements ProductIdentityResolverService {
  final SupabaseClient? _supabase;

  // Curated database of verified products, variants, and formulations
  final List<ProductIdentityCandidate> _candidateCatalog = [];

  DefaultProductIdentityResolverService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null) {
    _initializeSeedCatalog();
  }

  void _initializeSeedCatalog() {
    // 1. Sprouted Ragi Powder (Millets & Traditional)
    final ragiProduct = const ProductEntity(
      id: 'prod_ragi_sprouted_001',
      canonicalName: 'Organic Sprouted Ragi Flour',
      brandName: 'Ancient Harvest Craft',
      category: ProductCategory.food,
      marketCountry: 'IN',
    );
    final ragiVariant = const ProductVariantEntity(
      id: 'var_ragi_500g',
      productId: 'prod_ragi_sprouted_001',
      variantName: '500g Stone Ground',
      sku: 'SKU-RAGI-500',
      servingSize: 40.0,
      servingUnit: 'g',
    );
    final ragiFormulation = ProductFormulationEntity(
      id: 'form_ragi_v1',
      variantId: 'var_ragi_500g',
      formulationVersion: 'v1.0',
      ingredients: [
        const ProductIngredientEntity(
          id: 'ing_ragi_01',
          formulationId: 'form_ragi_v1',
          ingredientName: '100% Sprouted Finger Millet (Eleusine coracana)',
          orderOfPredominance: 1,
          isActiveIngredient: true,
          quantityAmount: 40.0,
          quantityUnit: 'g',
        )
      ],
    );
    _candidateCatalog.add(ProductIdentityCandidate(
      product: ragiProduct,
      variant: ragiVariant,
      formulation: ragiFormulation,
      confidenceScore: 0.99,
      matchMethod: 'exact_barcode_match',
      candidateProvenance: {'barcode': '8901234567890'},
    ));

    // 2. Magnesium Bisglycinate Chelate 200mg (Supplement)
    final magProduct = const ProductEntity(
      id: 'prod_mag_chelate_002',
      canonicalName: 'Magnesium Bisglycinate Chelate 200mg',
      brandName: 'Equilibrium Labs',
      category: ProductCategory.supplement,
      marketCountry: 'US',
    );
    final magVariant = const ProductVariantEntity(
      id: 'var_mag_120caps',
      productId: 'prod_mag_chelate_002',
      variantName: '120 Vegetarian Capsules',
      sku: 'SKU-MAG-120',
      servingSize: 2.0,
      servingUnit: 'capsules',
    );
    final magFormulation = ProductFormulationEntity(
      id: 'form_mag_v2',
      variantId: 'var_mag_120caps',
      formulationVersion: 'v2.0',
      packagingVersion: '2026-label',
      ingredients: [
        const ProductIngredientEntity(
          id: 'ing_mag_01',
          formulationId: 'form_mag_v2',
          ingredientName: 'Magnesium (as Magnesium Bisglycinate Chelate TRAACS)',
          orderOfPredominance: 1,
          isActiveIngredient: true,
          quantityAmount: 200.0,
          quantityUnit: 'mg',
        ),
        const ProductIngredientEntity(
          id: 'ing_mag_02',
          formulationId: 'form_mag_v2',
          ingredientName: 'Hypromellose (vegetarian capsule)',
          orderOfPredominance: 2,
        ),
      ],
    );
    _candidateCatalog.add(ProductIdentityCandidate(
      product: magProduct,
      variant: magVariant,
      formulation: magFormulation,
      confidenceScore: 0.99,
      matchMethod: 'exact_barcode_match',
      candidateProvenance: {'barcode': '0038137003423'},
    ));

    // 3. Similar Product Name Case A: "Pure Pea Protein Isolate" (Formula 1: Yellow Pea Only)
    final peaPure = const ProductEntity(
      id: 'prod_pea_isolate_pure',
      canonicalName: 'Organic Fermented Yellow Pea Protein',
      brandName: 'Botanical Kraft',
      category: ProductCategory.supplement,
      marketCountry: 'US',
    );
    final peaPureVariant = const ProductVariantEntity(
      id: 'var_pea_pure_1kg',
      productId: 'prod_pea_isolate_pure',
      variantName: '1kg Unflavored',
    );
    final peaPureFormula = ProductFormulationEntity(
      id: 'form_pea_pure_v1',
      variantId: 'var_pea_pure_1kg',
      formulationVersion: 'v1.0_unflavored',
      ingredients: [
        const ProductIngredientEntity(
          id: 'ing_pea_pure_01',
          formulationId: 'form_pea_pure_v1',
          ingredientName: 'Organic Yellow Pea Protein Isolate',
          orderOfPredominance: 1,
          quantityAmount: 25.0,
          quantityUnit: 'g',
        )
      ],
    );
    _candidateCatalog.add(ProductIdentityCandidate(
      product: peaPure,
      variant: peaPureVariant,
      formulation: peaPureFormula,
      confidenceScore: 0.98,
      matchMethod: 'catalog_sku',
      candidateProvenance: {'sku': 'BK-PEA-UNFLV-1KG'},
    ));

    // 4. Similar Product Name Case B: "Pea Protein Blend with Added Digestive Enzymes & Cocoa"
    final peaBlend = const ProductEntity(
      id: 'prod_pea_blend_cocoa',
      canonicalName: 'Organic Pea Protein Performance Blend',
      brandName: 'Botanical Kraft',
      category: ProductCategory.supplement,
      marketCountry: 'US',
    );
    final peaBlendVariant = const ProductVariantEntity(
      id: 'var_pea_blend_1kg',
      productId: 'prod_pea_blend_cocoa',
      variantName: '1kg Dutch Chocolate',
    );
    final peaBlendFormula = ProductFormulationEntity(
      id: 'form_pea_blend_v2',
      variantId: 'var_pea_blend_1kg',
      formulationVersion: 'v2.0_chocolate_enzymes',
      ingredients: [
        const ProductIngredientEntity(
          id: 'ing_pea_b_01',
          formulationId: 'form_pea_blend_v2',
          ingredientName: 'Organic Yellow Pea Protein Isolate',
          orderOfPredominance: 1,
        ),
        const ProductIngredientEntity(
          id: 'ing_pea_b_02',
          formulationId: 'form_pea_blend_v2',
          ingredientName: 'Organic Dutch Cocoa Powder',
          orderOfPredominance: 2,
        ),
        const ProductIngredientEntity(
          id: 'ing_pea_b_03',
          formulationId: 'form_pea_blend_v2',
          ingredientName: 'Bromelain & Papain Enzyme Complex',
          orderOfPredominance: 3,
        ),
      ],
    );
    _candidateCatalog.add(ProductIdentityCandidate(
      product: peaBlend,
      variant: peaBlendVariant,
      formulation: peaBlendFormula,
      confidenceScore: 0.98,
      matchMethod: 'catalog_sku',
      candidateProvenance: {'sku': 'BK-PEA-CHOC-1KG'},
    ));
  }

  @override
  bool validateBarcodeChecksum(String barcode) {
    final sanitized = barcode.replaceAll(RegExp(r'\D'), '');
    if (sanitized.length == 12) {
      // UPC-A modulo-10
      int oddSum = 0;
      int evenSum = 0;
      for (int i = 0; i < 11; i++) {
        final d = int.parse(sanitized[i]);
        if (i % 2 == 0) oddSum += d; else evenSum += d;
      }
      final total = (oddSum * 3) + evenSum;
      final check = (10 - (total % 10)) % 10;
      return check == int.parse(sanitized[11]);
    } else if (sanitized.length == 13) {
      // EAN-13 modulo-10
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        final d = int.parse(sanitized[i]);
        sum += (i % 2 == 0) ? d : d * 3;
      }
      final check = (10 - (sum % 10)) % 10;
      return check == int.parse(sanitized[12]);
    }
    return false;
  }

  @override
  Future<ProductIdentityResolutionResult> resolveFromBarcode(String barcode) async {
    final sanitized = barcode.replaceAll(RegExp(r'\D'), '');
    if (!validateBarcodeChecksum(sanitized)) {
      return ProductIdentityResolutionResult.uncertain(
        candidates: const [],
        prompt: 'The scanned barcode "$barcode" has an invalid modulo-10 checksum. Please re-scan or provide a clear photograph of the product label.',
      );
    }

    // Match in candidate catalog
    for (final candidate in _candidateCatalog) {
      final catalogBarcode = candidate.candidateProvenance['barcode']?.toString();
      if (catalogBarcode == sanitized) {
        return ProductIdentityResolutionResult.confident(candidate);
      }
    }

    // If valid barcode not found in local catalog, return structured fallback
    return ProductIdentityResolutionResult.uncertain(
      candidates: const [],
      prompt: 'Valid barcode ($sanitized) identified, but no exact formulation was found in the verified registry. Please capture a photograph of the front label and ingredient panel.',
    );
  }

  @override
  Future<ProductIdentityResolutionResult> resolveFromLabelOcr({
    required String brandNameCandidate,
    required String productNameCandidate,
    String? variantCandidate,
    List<String> visibleIngredients = const [],
  }) async {
    final matchedCandidates = <ProductIdentityCandidate>[];

    final brandLower = brandNameCandidate.toLowerCase().trim();
    final productLower = productNameCandidate.toLowerCase().trim();

    for (final candidate in _candidateCatalog) {
      final candBrand = candidate.product.brandName?.toLowerCase() ?? '';
      final candName = candidate.product.canonicalName.toLowerCase();

      bool brandMatch = candBrand.contains(brandLower) || brandLower.contains(candBrand);
      bool productMatch = candName.contains(productLower) || productLower.contains(candName);

      if (brandMatch && productMatch) {
        // Differentiate similar formulations by checking ingredients or variant
        double score = 0.88;
        if (visibleIngredients.isNotEmpty) {
          final candIngs = candidate.formulation.ingredients
              .map((i) => i.ingredientName.toLowerCase())
              .toList();
          int matchedIngs = 0;
          for (final vis in visibleIngredients) {
            if (candIngs.any((ci) => ci.contains(vis.toLowerCase()))) {
              matchedIngs++;
            }
          }
          final ingScoreRatio = matchedIngs / visibleIngredients.length;
          score = (0.70 + (ingScoreRatio * 0.28)).clamp(0.0, 0.98);
        }

        matchedCandidates.add(ProductIdentityCandidate(
          product: candidate.product,
          variant: candidate.variant,
          formulation: candidate.formulation,
          confidenceScore: score,
          matchMethod: 'ocr_label_disambiguation',
          candidateProvenance: {
            'ocr_brand': brandNameCandidate,
            'ocr_product': productNameCandidate,
            'visible_ingredients_checked': visibleIngredients.length,
          },
        ));
      }
    }

    if (matchedCandidates.isEmpty) {
      return ProductIdentityResolutionResult.uncertain(
        candidates: const [],
        prompt: 'No products matching "$productNameCandidate" by "$brandNameCandidate" could be verified. Please capture a clearer photograph showing the barcode and full ingredient list.',
      );
    }

    // Sort by confidence
    matchedCandidates.sort((a, b) => b.confidenceScore.compareTo(a.confidenceScore));

    // If top candidate is >= 0.85 and significantly distinct from second candidate, return confident
    if (matchedCandidates.first.confidenceScore >= 0.85) {
      if (matchedCandidates.length > 1 &&
          (matchedCandidates[0].confidenceScore - matchedCandidates[1].confidenceScore) < 0.05) {
        // Ambiguity between two similar formulations!
        return ProductIdentityResolutionResult.uncertain(
          candidates: matchedCandidates,
          prompt: 'Multiple formulations exist for "${matchedCandidates.first.product.canonicalName}". Please verify whether your package is "${matchedCandidates[0].variant.variantName}" or "${matchedCandidates[1].variant.variantName}".',
        );
      }
      return ProductIdentityResolutionResult.confident(matchedCandidates.first);
    }

    return ProductIdentityResolutionResult.uncertain(
      candidates: matchedCandidates,
      prompt: 'Product candidate found with moderate confidence (${(matchedCandidates.first.confidenceScore * 100).toInt()}%). Please provide the barcode for 100% verified confirmation.',
    );
  }
}

final productIdentityResolverServiceProvider = Provider<ProductIdentityResolverService>((ref) {
  return DefaultProductIdentityResolverService();
});
