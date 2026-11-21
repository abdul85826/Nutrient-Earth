// ==============================================================================
// Nutrient Earth — Direct Open Food Facts Client (REST API v2)
// Zero MCP Dependency: Native REST Client for barcode resolution, ingredient forensics,
// NOVA ultra-processing level, and allergen extraction.
// ==============================================================================

import 'package:http/http.dart' as http;
import 'direct_source_client.dart';

class VerifiedProductRecord {
  final String barcode;
  final String productName;
  final String? brands;
  final String? ingredientsText;
  final List<String> allergensTags;
  final int? novaGroup;
  final String? nutriscoreGrade;
  final List<String> additivesTags;
  final Map<String, dynamic> nutrientLevels;
  final String rawSha256;

  const VerifiedProductRecord({
    required this.barcode,
    required this.productName,
    this.brands,
    this.ingredientsText,
    this.allergensTags = const [],
    this.novaGroup,
    this.nutriscoreGrade,
    this.additivesTags = const [],
    this.nutrientLevels = const {},
    required this.rawSha256,
  });

  Map<String, dynamic> toJson() => {
        'barcode': barcode,
        'productName': productName,
        'brands': brands,
        'ingredientsText': ingredientsText,
        'allergensTags': allergensTags,
        'novaGroup': novaGroup,
        'nutriscoreGrade': nutriscoreGrade,
        'additivesTags': additivesTags,
        'nutrientLevels': nutrientLevels,
        'rawSha256': rawSha256,
      };
}

class DirectOpenFoodFactsClient extends DirectSourceClient {
  DirectOpenFoodFactsClient({http.Client? httpClient})
      : super(
          sourceId: 'OPEN_FOOD_FACTS',
          baseUrl: 'https://world.openfoodfacts.org/api/v2/',
          maxRequestsPerSecond: 2.0,
          httpClient: httpClient,
        );

  @override
  Map<String, String> defaultHeaders() => {
        'Accept': 'application/json',
        'User-Agent': 'NutrientEarth-UniversalVerification/1.0 (evidence@nutrientearth.org)',
      };

  /// Lookup product by universal barcode (UPC / EAN)
  Future<VerifiedProductRecord?> getProductByBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return null;

    try {
      final response = await executeGet('product/$cleanBarcode.json');
      final json = response.parseJson() as Map<String, dynamic>;

      final status = json['status'];
      if (status != 1) return null;

      final product = json['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final name = product['product_name']?.toString() ??
          product['product_name_en']?.toString() ??
          'Unknown Product';
      final brands = product['brands']?.toString();
      final ingredients = product['ingredients_text']?.toString() ??
          product['ingredients_text_en']?.toString();

      final allergens = (product['allergens_tags'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          const [];

      final nova = int.tryParse(product['nova_group']?.toString() ?? '');
      final nutriscore = product['nutriscore_grade']?.toString()?.toUpperCase();

      final additives = (product['additives_tags'] as List<dynamic>?)
              ?.map((a) => a.toString())
              .toList() ??
          const [];

      final nutrientLevels = (product['nutrient_levels'] as Map<String, dynamic>?) ?? {};

      return VerifiedProductRecord(
        barcode: cleanBarcode,
        productName: name,
        brands: brands,
        ingredientsText: ingredients,
        allergensTags: allergens,
        novaGroup: nova,
        nutriscoreGrade: nutriscore,
        additivesTags: additives,
        nutrientLevels: nutrientLevels,
        rawSha256: response.sha256Hash,
      );
    } catch (_) {
      return null;
    }
  }
}
