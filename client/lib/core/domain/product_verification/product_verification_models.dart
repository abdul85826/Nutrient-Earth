// ==============================================================================
// Nutrient Earth — Product Verification & Multi-Tier Resolution Models
// Models: Company, Brand, Product, Variant, Formulation, Ingredients, and Candidates
// ==============================================================================

import 'package:uuid/uuid.dart';

enum ProductCategory {
  food,
  supplement,
  medicine,
  ayurvedicHerbal,
  personalCare,
  consumerGood;

  String get value => name;

  static ProductCategory fromString(String val) {
    return ProductCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase().replaceAll('_', ''),
      orElse: () => ProductCategory.food,
    );
  }
}

class ProductCompany {
  final String id;
  final String name;
  final String? headquartersCountry;
  final String? websiteUrl;
  final bool isVerified;

  const ProductCompany({
    required this.id,
    required this.name,
    this.headquartersCountry,
    this.websiteUrl,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'headquarters_country': headquartersCountry,
        'website_url': websiteUrl,
        'is_verified': isVerified,
      };
}

class ProductBrand {
  final String id;
  final String? companyId;
  final String name;
  final String? description;

  const ProductBrand({
    required this.id,
    this.companyId,
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'description': description,
      };
}

class ProductIdentifierEntity {
  final String id;
  final String variantId;
  final String identifierType; // gtin, upc_a, ean_13, qr_code
  final String identifierValue;
  final bool isPrimary;

  const ProductIdentifierEntity({
    required this.id,
    required this.variantId,
    required this.identifierType,
    required this.identifierValue,
    this.isPrimary = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant_id': variantId,
        'identifier_type': identifierType,
        'identifier_value': identifierValue,
        'is_primary': isPrimary,
      };
}

class ProductIngredientEntity {
  final String id;
  final String formulationId;
  final String ingredientName;
  final String? standardizedInciOrMesh;
  final double? quantityAmount;
  final String? quantityUnit;
  final bool isActiveIngredient;
  final int orderOfPredominance;
  final String? processingNotes;

  const ProductIngredientEntity({
    required this.id,
    required this.formulationId,
    required this.ingredientName,
    this.standardizedInciOrMesh,
    this.quantityAmount,
    this.quantityUnit,
    this.isActiveIngredient = false,
    required this.orderOfPredominance,
    this.processingNotes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'formulation_id': formulationId,
        'ingredient_name': ingredientName,
        'standardized_inci_or_mesh': standardizedInciOrMesh,
        'quantity_amount': quantityAmount,
        'quantity_unit': quantityUnit,
        'is_active_ingredient': isActiveIngredient,
        'order_of_predominance': orderOfPredominance,
        'processing_notes': processingNotes,
      };
}

class ProductFormulationEntity {
  final String id;
  final String variantId;
  final String formulationVersion;
  final String? packagingVersion;
  final List<ProductIngredientEntity> ingredients;
  final bool isActive;

  const ProductFormulationEntity({
    required this.id,
    required this.variantId,
    required this.formulationVersion,
    this.packagingVersion,
    this.ingredients = const [],
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'variant_id': variantId,
        'formulation_version': formulationVersion,
        'packaging_version': packagingVersion,
        'is_active': isActive,
      };
}

class ProductVariantEntity {
  final String id;
  final String productId;
  final String variantName;
  final String? sku;
  final double? servingSize;
  final String? servingUnit;
  final List<ProductIdentifierEntity> identifiers;
  final List<ProductFormulationEntity> formulations;

  const ProductVariantEntity({
    required this.id,
    required this.productId,
    required this.variantName,
    this.sku,
    this.servingSize,
    this.servingUnit,
    this.identifiers = const [],
    this.formulations = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'variant_name': variantName,
        'sku': sku,
        'serving_size': servingSize,
        'serving_unit': servingUnit,
      };
}

class ProductEntity {
  final String id;
  final String? brandId;
  final String? brandName;
  final String canonicalName;
  final ProductCategory category;
  final String? description;
  final String marketCountry;
  final bool isDiscontinued;
  final List<ProductVariantEntity> variants;

  const ProductEntity({
    required this.id,
    this.brandId,
    this.brandName,
    required this.canonicalName,
    required this.category,
    this.description,
    this.marketCountry = 'GLOBAL',
    this.isDiscontinued = false,
    this.variants = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand_id': brandId,
        'brand_name': brandName,
        'canonical_name': canonicalName,
        'category': category.value,
        'description': description,
        'market_country': marketCountry,
        'is_discontinued': isDiscontinued,
      };
}

class ProductIdentityCandidate {
  final ProductEntity product;
  final ProductVariantEntity variant;
  final ProductFormulationEntity formulation;
  final double confidenceScore;
  final String matchMethod; // e.g. 'exact_barcode_match', 'ocr_brand_fuzzy', 'catalog_sku'
  final Map<String, dynamic> candidateProvenance;

  const ProductIdentityCandidate({
    required this.product,
    required this.variant,
    required this.formulation,
    required this.confidenceScore,
    required this.matchMethod,
    this.candidateProvenance = const {},
  });

  Map<String, dynamic> toJson() => {
        'product_name': product.canonicalName,
        'brand_name': product.brandName,
        'variant_name': variant.variantName,
        'formulation_version': formulation.formulationVersion,
        'confidence_score': confidenceScore,
        'match_method': matchMethod,
        'candidate_provenance': candidateProvenance,
      };
}

class ProductIdentityResolutionResult {
  final ProductIdentityCandidate? resolvedProduct;
  final List<ProductIdentityCandidate> alternativeCandidates;
  final bool requiresClarification;
  final String? clarificationPrompt;
  final double topConfidence;

  const ProductIdentityResolutionResult({
    this.resolvedProduct,
    this.alternativeCandidates = const [],
    required this.requiresClarification,
    this.clarificationPrompt,
    required this.topConfidence,
  });

  factory ProductIdentityResolutionResult.confident(ProductIdentityCandidate candidate) {
    return ProductIdentityResolutionResult(
      resolvedProduct: candidate,
      alternativeCandidates: const [],
      requiresClarification: false,
      topConfidence: candidate.confidenceScore,
    );
  }

  factory ProductIdentityResolutionResult.uncertain({
    required List<ProductIdentityCandidate> candidates,
    required String prompt,
  }) {
    final top = candidates.isEmpty ? 0.0 : candidates.first.confidenceScore;
    return ProductIdentityResolutionResult(
      resolvedProduct: null,
      alternativeCandidates: candidates,
      requiresClarification: true,
      clarificationPrompt: prompt,
      topConfidence: top,
    );
  }
}
