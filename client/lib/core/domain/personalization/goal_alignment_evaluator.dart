// ==============================================================================
// Nutrient Earth — Goal Alignment & Suitability Evaluator
// Transparent, testable evaluation rules comparing scientific inquiries to explicit user goals.
// Never invents preferences; explicitly identifies missing profile context.
// ==============================================================================

import 'user_profile_context.dart';

enum GoalAlignmentStatus {
  aligned,
  partiallyAligned,
  misaligned,
  insufficientInformation,
}

class GoalAssessmentResult {
  final GoalAlignmentStatus status;
  final List<String> matchedGoals;
  final String alignmentRationale;
  final List<String> contraindicationsOrWarnings;
  final String? missingContextNotes;

  const GoalAssessmentResult({
    required this.status,
    this.matchedGoals = const [],
    required this.alignmentRationale,
    this.contraindicationsOrWarnings = const [],
    this.missingContextNotes,
  });

  factory GoalAssessmentResult.fromJson(Map<String, dynamic> json) {
    return GoalAssessmentResult(
      status: _parseStatus(json['status'] as String?),
      matchedGoals: (json['matchedGoals'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          const [],
      alignmentRationale: json['alignmentRationale'] as String? ?? '',
      contraindicationsOrWarnings: (json['contraindicationsOrWarnings'] as List<dynamic>?)
              ?.map((w) => w.toString())
              .toList() ??
          const [],
      missingContextNotes: json['missingContextNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'matchedGoals': matchedGoals,
        'alignmentRationale': alignmentRationale,
        'contraindicationsOrWarnings': contraindicationsOrWarnings,
        'missingContextNotes': missingContextNotes,
      };

  static GoalAlignmentStatus _parseStatus(String? raw) {
    if (raw == null) return GoalAlignmentStatus.insufficientInformation;
    for (final status in GoalAlignmentStatus.values) {
      if (status.name.toLowerCase() == raw.toLowerCase()) return status;
    }
    return GoalAlignmentStatus.insufficientInformation;
  }
}

class GoalAlignmentEvaluator {
  GoalAlignmentEvaluator._();

  /// Evaluates an inquiry and topic against a user's verified profile context.
  /// Operates deterministically without probabilistic hallucination.
  static GoalAssessmentResult evaluate({
    required String query,
    UserProfileContext? userProfile,
  }) {
    if (userProfile == null || userProfile.primaryGoals.isEmpty) {
      return const GoalAssessmentResult(
        status: GoalAlignmentStatus.insufficientInformation,
        alignmentRationale:
            'General scientific evidence synthesis provided. Personalized goal suitability requires an active user profile with declared primary goals.',
        missingContextNotes:
            'To receive goal-aware alignment analysis, configure your health goals and dietary preferences in your profile.',
      );
    }

    final lowerQuery = query.toLowerCase();
    final userConditions = userProfile.knownConditions.map((c) => c.toLowerCase()).toList();
    final dietaryPref = userProfile.dietaryPreference.toLowerCase();

    final matchedGoals = <String>[];
    final warnings = <String>[];
    var isAligned = false;
    var isMisaligned = false;

    // 1. Dietary Preference Conflicts (e.g. animal products for vegan/vegetarian)
    final animalProductKeywords = ['whey', 'gelatin', 'collagen', 'beef', 'chicken', 'fish oil', 'bone broth'];
    if (dietaryPref.contains('vegan') || dietaryPref.contains('vegetarian')) {
      for (final kw in animalProductKeywords) {
        if (lowerQuery.contains(kw)) {
          isMisaligned = true;
          warnings.add(
            'The inquiry references "$kw", which conflicts with your declared dietary preference ($dietaryPref). Plant-based alternatives (e.g., fermented pea/rice protein, algae EPA/DHA) are recommended.',
          );
        }
      }
    }

    // 2. Known Condition Contraindications
    if (userConditions.any((c) => c.contains('kidney') || c.contains('renal'))) {
      if (lowerQuery.contains('protein') || lowerQuery.contains('potassium') || lowerQuery.contains('creatine')) {
        warnings.add(
          'Clinical Caution: Elevated intake of protein, potassium, or creatine requires nephrologist oversight due to declared renal health considerations.',
        );
      }
    }

    if (userConditions.any((c) => c.contains('hypertension') || c.contains('blood pressure'))) {
      if (lowerQuery.contains('sodium') || lowerQuery.contains('licorice') || lowerQuery.contains('ephedra')) {
        warnings.add(
          'Precaution: Ingestion of compounds affecting vascular tone should be monitored closely with declared hypertension.',
        );
      }
    }

    // 3. Duplicate Active Supplementation Check (Normalized ingredient matching)
    for (final originalSupp in userProfile.activeSupplements) {
      if (isDuplicateSupplement(originalSupp, query)) {
        warnings.add(
          'You already report taking "$originalSupp". Additional supplementation should be adjusted to avoid exceeding established Tolerable Upper Intake Levels (UL).',
        );
      }
    }

    // 4. Positive Goal Matching
    if (lowerQuery.contains('sleep') || lowerQuery.contains('magnesium') || lowerQuery.contains('circadian')) {
      for (final goal in userProfile.primaryGoals) {
        if (goal.toLowerCase().contains('sleep') || goal.toLowerCase().contains('recovery')) {
          matchedGoals.add(goal);
          isAligned = true;
        }
      }
    }

    if (lowerQuery.contains('protein') || lowerQuery.contains('muscle') || lowerQuery.contains('strength')) {
      for (final goal in userProfile.primaryGoals) {
        if (goal.toLowerCase().contains('muscle') ||
            goal.toLowerCase().contains('strength') ||
            goal.toLowerCase().contains('hypertrophy')) {
          matchedGoals.add(goal);
          isAligned = true;
        }
      }
    }

    if (lowerQuery.contains('glucose') || lowerQuery.contains('energy') || lowerQuery.contains('fasting')) {
      for (final goal in userProfile.primaryGoals) {
        if (goal.toLowerCase().contains('energy') ||
            goal.toLowerCase().contains('metabolic') ||
            goal.toLowerCase().contains('vitality')) {
          matchedGoals.add(goal);
          isAligned = true;
        }
      }
    }

    // Determine Final Status
    if (isMisaligned) {
      return GoalAssessmentResult(
        status: GoalAlignmentStatus.misaligned,
        matchedGoals: matchedGoals,
        alignmentRationale:
            'The researched intervention conflicts with one or more declared dietary preferences or clinical parameters.',
        contraindicationsOrWarnings: warnings,
      );
    }

    if (isAligned && warnings.isNotEmpty) {
      return GoalAssessmentResult(
        status: GoalAlignmentStatus.partiallyAligned,
        matchedGoals: matchedGoals,
        alignmentRationale:
            'Directly supports target goals (${matchedGoals.join(', ')}), with specific clinical or dosing precautions noted.',
        contraindicationsOrWarnings: warnings,
      );
    }

    if (isAligned) {
      return GoalAssessmentResult(
        status: GoalAlignmentStatus.aligned,
        matchedGoals: matchedGoals,
        alignmentRationale:
            'Strong biochemical and physiological synergy with declared target goals: ${matchedGoals.join(', ')}.',
        contraindicationsOrWarnings: warnings,
      );
    }

    return GoalAssessmentResult(
      status: GoalAlignmentStatus.insufficientInformation,
      matchedGoals: const [],
      alignmentRationale:
          'Relevant research synthesized; however, this inquiry does not explicitly map to your active target goals (${userProfile.primaryGoals.join(', ')}).',
      contraindicationsOrWarnings: warnings,
      missingContextNotes: 'Consider specifying target outcomes to refine personalized guidance.',
    );
  }

  /// Evaluates whether an active supplement matches an inquiry without false positives
  /// from generic brand tokens (e.g., "Doctor's Best") or generic category words (e.g., "Vitamin").
  static bool isDuplicateSupplement(String activeSupp, String query) {
    final lowerSupp = activeSupp.toLowerCase().trim();
    final lowerQuery = query.toLowerCase().trim();

    if (lowerSupp.isEmpty || lowerQuery.isEmpty) return false;

    // 1. Exact phrase containment
    if (lowerQuery.contains(lowerSupp)) return true;

    // 2. Vitamin matching: strictly compare vitamin designations
    // E.g. "Vitamin D3" vs "Vitamin C" must NEVER match.
    final suppVitaminMatch = RegExp(r'\bvitamin\s*([a-z0-9\-]+)\b').firstMatch(lowerSupp);
    if (suppVitaminMatch != null) {
      final suppVitTag = suppVitaminMatch.group(1)!.replaceAll('-', '');
      final queryVitaminMatch = RegExp(r'\bvitamin\s*([a-z0-9\-]+)\b').firstMatch(lowerQuery);
      if (queryVitaminMatch != null) {
        final queryVitTag = queryVitaminMatch.group(1)!.replaceAll('-', '');
        if (suppVitTag == queryVitTag) return true;
        if ((suppVitTag == 'd3' && queryVitTag == 'd') || (suppVitTag == 'd' && queryVitTag == 'd3')) return true;
        if ((suppVitTag == 'k2' && queryVitTag == 'k') || (suppVitTag == 'k' && queryVitTag == 'k2')) return true;
        return false;
      }
      // If query does not mention "vitamin <tag>", check known clinical synonyms
      if ((suppVitTag == 'd' || suppVitTag == 'd3') &&
          (lowerQuery.contains('cholecalciferol') || lowerQuery.contains('ergocalciferol'))) {
        return true;
      }
      if (suppVitTag == 'c' && lowerQuery.contains('ascorbic acid')) {
        return true;
      }
      if ((suppVitTag == 'b12' || suppVitTag == 'b-12') &&
          (lowerQuery.contains('methylcobalamin') || lowerQuery.contains('cyanocobalamin'))) {
        return true;
      }
      // Specific vitamin was declared, but query did not match that specific vitamin
      return false;
    }

    // 3. Elemental mineral matching (e.g. Zinc picolinate vs Zinc carnosine)
    const elementalMinerals = {
      'magnesium', 'zinc', 'iron', 'calcium', 'selenium',
      'potassium', 'copper', 'iodine', 'manganese', 'chromium', 'boron',
    };
    for (final mineral in elementalMinerals) {
      final suppHasMineral = RegExp('\\b$mineral\\b').hasMatch(lowerSupp);
      final queryHasMineral = RegExp('\\b$mineral\\b').hasMatch(lowerQuery);
      if (suppHasMineral && queryHasMineral) {
        return true;
      }
    }

    // 4. Core bioactive compound matching (e.g. Creatine monohydrate vs Creatine)
    const coreBioactiveCompounds = {
      'creatine', 'melatonin', 'ashwagandha', 'berberine', 'curcumin',
      'turmeric', 'theanine', 'glutathione', 'ubiquinol', 'coq10',
      'quercetin', 'resveratrol', 'collagen', 'glucosamine', 'chondroitin',
    };
    for (final compound in coreBioactiveCompounds) {
      final suppHasCompound = RegExp('\\b$compound\\b').hasMatch(lowerSupp);
      final queryHasCompound = RegExp('\\b$compound\\b').hasMatch(lowerQuery);
      if (suppHasCompound && queryHasCompound) {
        return true;
      }
    }

    // 5. Omega-3 / Fish oil matching
    final suppHasOmega = lowerSupp.contains('omega-3') ||
        lowerSupp.contains('fish oil') ||
        lowerSupp.contains('epa/dha');
    final queryHasOmega = lowerQuery.contains('omega-3') ||
        lowerQuery.contains('fish oil') ||
        lowerQuery.contains('epa/dha');
    if (suppHasOmega && queryHasOmega) return true;

    // 6. Token matching after stripping generic brand names and formulations
    const genericStopWords = {
      'doctor\'s', 'doctors', 'doctor', 'best',
      'pure', 'encapsulations',
      'now', 'foods',
      'nature', 'made', 'bounty',
      'thorne', 'jarrow', 'formulas',
      'life', 'extension',
      'garden', 'of',
      'solgar', 'nordic', 'naturals',
      'daily', 'supplement', 'supplements',
      'capsule', 'capsules', 'tablet', 'tablets', 'powder',
      'softgel', 'softgels', 'gummy', 'gummies', 'liquid', 'drops',
      'extract', 'complex', 'formula', 'blend', 'ultra', 'high', 'potency',
      'organic', 'raw', 'natural', 'standardized', 'liposomal', 'chelate', 'chelated',
    };

    final cleanSuppTokens = lowerSupp
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 3 && !genericStopWords.contains(t))
        .toList();

    for (final token in cleanSuppTokens) {
      if (RegExp('\\b$token\\b').hasMatch(lowerQuery)) {
        return true;
      }
    }

    return false;
  }
}
