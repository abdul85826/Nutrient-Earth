// ==============================================================================
// Nutrient Earth — Native-Language & Terminology Preservation Models
// Protects critical domain terminology (Ayurvedic herbs, Botanical names,
// medicine names, exact units) from corrupted translation, and supports code-switching.
// ==============================================================================

enum TerminologyCategory {
  ayurvedicHerb,
  botanicalName,
  clinicalCondition,
  medicineName,
  measurementUnit;

  String get value => name;
}

class ProtectedTerm {
  final String originalTerm;
  final TerminologyCategory category;
  final String standardizedOrScientific;
  final bool strictPreservation;

  const ProtectedTerm({
    required this.originalTerm,
    required this.category,
    required this.standardizedOrScientific,
    this.strictPreservation = true,
  });

  Map<String, dynamic> toJson() => {
        'original_term': originalTerm,
        'category': category.value,
        'standardized_or_scientific': standardizedOrScientific,
        'strict_preservation': strictPreservation,
      };
}

class LanguageDetectionResult {
  final String primaryLanguageCode; // e.g. 'hi', 'ta', 'te', 'es', 'en'
  final double confidence;
  final bool isCodeSwitched; // e.g. Hinglish (hi + en)
  final List<String> detectedLanguages;

  const LanguageDetectionResult({
    required this.primaryLanguageCode,
    required this.confidence,
    this.isCodeSwitched = false,
    this.detectedLanguages = const [],
  });

  Map<String, dynamic> toJson() => {
        'primary_language_code': primaryLanguageCode,
        'confidence': confidence,
        'is_code_switched': isCodeSwitched,
        'detected_languages': detectedLanguages,
      };
}

class MultilingualInteractionResult {
  final String originalInputText;
  final LanguageDetectionResult languageDetection;
  final String normalizedText;
  final String translatedEnglishText;
  final String nativeResponseText;
  final List<ProtectedTerm> preservedTerms;

  const MultilingualInteractionResult({
    required this.originalInputText,
    required this.languageDetection,
    required this.normalizedText,
    required this.translatedEnglishText,
    required this.nativeResponseText,
    this.preservedTerms = const [],
  });

  Map<String, dynamic> toJson() => {
        'original_input_text': originalInputText,
        'language_detection': languageDetection.toJson(),
        'normalized_text': normalizedText,
        'translated_english_text': translatedEnglishText,
        'native_response_text': nativeResponseText,
        'preserved_terms': preservedTerms.map((t) => t.toJson()).toList(),
      };
}
