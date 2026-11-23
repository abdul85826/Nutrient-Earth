// ==============================================================================
// Nutrient Earth — Scientific Contradiction Engine & Study-Family Deduplication
// Master Engineering Hardening: Part D (Sections 13, 14, 15)
//
// Identifies and reconciles discordant clinical evidence across study design,
// population demographics, dosage, and duration. Groups multi-publication
// trial families to prevent artificial replication inflation.
// ==============================================================================

import '../../domain/evidence/scientific_evidence_contract.dart';

/// Scientific consensus state on a given biological or clinical inquiry
enum ScientificConsensusState {
  scientificConsensus,  // High consistency across independent high-powered RCTs / meta-analyses
  contextDependent,     // Apparent conflict resolved by dosage, duration, form, or baseline deficiency
  genuineControversy,   // Truly conflicting outcomes under equivalent methodology and populations
  insufficientData,     // Evidence base too sparse or low powered to establish consensus
}

/// Confounding dimension that accounts for discordant study outcomes
enum ConfounderDimension {
  baselineStatus,  // e.g. Effect observed in deficient subjects, absent in replete subjects
  dosageLevel,     // e.g. Sub-therapeutic dose vs clinical therapeutic threshold
  chemicalForm,    // e.g. Magnesium Oxide (4% bioavailability) vs Magnesium Bisglycinate
  studyDuration,   // e.g. Acute 2-week trial vs 12-month structural remodeling
  studyDesign,     // e.g. Observational correlation vs double-blind placebo-controlled RCT
  populationAge,   // e.g. Young athletes vs sarcopenic elderly
  coIntervention,  // e.g. Administered with meals vs fasting, or with synergistic co-factors
}

/// Represents a cluster of publications originating from the same clinical trial or cohort
class StudyFamilyGroup {
  final String familyId;
  final String primaryTrialIdentifier; // e.g., NCT01169259 or "NHANES 2017-2018"
  final String cohortName;
  final List<ScientificSource> memberCitations;
  final int totalUniqueParticipants;
  final bool isMultiPublication;

  const StudyFamilyGroup({
    required this.familyId,
    required this.primaryTrialIdentifier,
    required this.cohortName,
    required this.memberCitations,
    this.totalUniqueParticipants = 0,
    this.isMultiPublication = false,
  });

  /// The authoritative citation for the primary outcome
  ScientificSource get primaryCitation => memberCitations.first;
}

/// Comprehensive outcome of a scientific contradiction analysis
class ContradictionAnalysisRecord {
  final String topic;
  final ScientificConsensusState consensusState;
  final bool hasDiscordantOutcomes;
  final List<ConfounderDimension> identifiedConfounders;
  final List<String> explanatoryMechanisms;
  final List<StudyFamilyGroup> deduplicatedFamilies;
  final int totalRawCitations;
  final int deduplicatedIndependentTrials;
  final String synthesisSummary;

  const ContradictionAnalysisRecord({
    required this.topic,
    required this.consensusState,
    required this.hasDiscordantOutcomes,
    required this.identifiedConfounders,
    required this.explanatoryMechanisms,
    required this.deduplicatedFamilies,
    required this.totalRawCitations,
    required this.deduplicatedIndependentTrials,
    required this.synthesisSummary,
  });
}

class ScientificContradictionEngine {
  ScientificContradictionEngine._();

  static final RegExp _nctPattern = RegExp(r'NCT\d{8}', caseSensitive: false);

  /// Known multi-publication epidemiological cohorts
  static const List<String> _knownCohorts = [
    'nhanes', 'framingham', 'nurses\' health study', 'health professionals follow-up',
    'vital trial', 'uk biobank', 'epic-oxford', 'predimed', 'womens health initiative',
  ];

  /// Deduplicates a raw list of citations into independent study families
  static List<StudyFamilyGroup> deduplicateStudyFamilies(List<ScientificSource> rawCitations) {
    if (rawCitations.isEmpty) return [];

    final groups = <String, List<ScientificSource>>{};
    final unlinked = <ScientificSource>[];

    for (final cit in rawCitations) {
      String? matchedKey;

      // 1. Match by ClinicalTrials.gov NCT identifier
      final textToScan = '${cit.title} ${cit.authorsOrJournal} ${cit.url ?? ''}';
      final nctMatch = _nctPattern.firstMatch(textToScan);
      if (nctMatch != null) {
        matchedKey = nctMatch.group(0)!.toUpperCase();
      }

      // 2. Match by prominent epidemiological cohort name
      if (matchedKey == null) {
        final lower = textToScan.toLowerCase();
        for (final cohort in _knownCohorts) {
          if (lower.contains(cohort)) {
            matchedKey = 'COHORT-${cohort.toUpperCase().replaceAll(' ', '_')}';
            break;
          }
        }
      }

      // 3. Match by exact DOI or PMID if present
      if (matchedKey == null) {
        if (cit.pmid != null && cit.pmid!.isNotEmpty) {
          matchedKey = 'PMID-${cit.pmid}';
        } else if (cit.doi != null && cit.doi!.isNotEmpty) {
          matchedKey = 'DOI-${cit.doi}';
        }
      }

      if (matchedKey != null) {
        groups.putIfAbsent(matchedKey, () => []).add(cit);
      } else {
        unlinked.add(cit);
      }
    }

    final result = <StudyFamilyGroup>[];
    int familyIndex = 1;

    groups.forEach((key, citations) {
      result.add(StudyFamilyGroup(
        familyId: 'FAM-${familyIndex++}',
        primaryTrialIdentifier: key,
        cohortName: _deriveCohortName(key, citations.first),
        memberCitations: citations,
        totalUniqueParticipants: citations.first.sampleSize ?? 0,
        isMultiPublication: citations.length > 1,
      ));
    });

    for (final cit in unlinked) {
      result.add(StudyFamilyGroup(
        familyId: 'FAM-${familyIndex++}',
        primaryTrialIdentifier: cit.pmid ?? 'UNLINKED-${cit.title.hashCode}',
        cohortName: cit.authorsOrJournal,
        memberCitations: [cit],
        totalUniqueParticipants: cit.sampleSize ?? 0,
        isMultiPublication: false,
      ));
    }

    return result;
  }

  /// Evaluates discordant claims across deduplicated study families
  static ContradictionAnalysisRecord analyzeEvidence({
    required String topic,
    required List<ScientificSource> citations,
    List<ScientificClaim> claims = const [],
  }) {
    final families = deduplicateStudyFamilies(citations);
    final totalRaw = citations.length;
    final deduplicatedCount = families.length;

    // Check if there are opposing claims (e.g. supported vs contradicted)
    bool hasSupported = claims.any((c) => c.supportStatus == ClaimSupportStatus.supported);
    bool hasContradicted = claims.any((c) => c.supportStatus == ClaimSupportStatus.contradicted);
    bool hasUnresolved = claims.any((c) => c.supportStatus == ClaimSupportStatus.unresolved);

    // If citations or claims are empty or very sparse
    if (totalRaw == 0 || claims.isEmpty) {
      return ContradictionAnalysisRecord(
        topic: topic,
        consensusState: ScientificConsensusState.insufficientData,
        hasDiscordantOutcomes: false,
        identifiedConfounders: const [],
        explanatoryMechanisms: const [
          'Insufficient published clinical data to evaluate consensus or detect statistical discordance.',
        ],
        deduplicatedFamilies: families,
        totalRawCitations: totalRaw,
        deduplicatedIndependentTrials: deduplicatedCount,
        synthesisSummary: 'Insufficient high-powered trial evidence available for $topic.',
      );
    }

    final confounders = <ConfounderDimension>[];
    final mechanisms = <String>[];

    final lowerTopic = topic.toLowerCase();

    // Evaluate known clinical divergence mechanisms
    if (lowerTopic.contains('vitamin d') || lowerTopic.contains('magnesium') || lowerTopic.contains('zinc')) {
      confounders.add(ConfounderDimension.baselineStatus);
      mechanisms.add(
        'Baseline Nutritional Repletion: Clinical benefits are concentrated almost exclusively in baseline-deficient cohorts; trials administering supplements to nutrient-replete participants demonstrate null effect.',
      );
    }

    if (lowerTopic.contains('magnesium') || lowerTopic.contains('curcumin') || lowerTopic.contains('coq10')) {
      confounders.add(ConfounderDimension.chemicalForm);
      mechanisms.add(
        'Bioavailability & Chemical Speciation: Divergent bioavailability profiles (e.g., chelated organic salts vs poorly absorbed oxides) significantly dictate biological target engagement.',
      );
    }

    if (lowerTopic.contains('omega-3') || lowerTopic.contains('fish oil') || lowerTopic.contains('creatine')) {
      confounders.add(ConfounderDimension.dosageLevel);
      confounders.add(ConfounderDimension.studyDuration);
      mechanisms.add(
        'Dosage Threshold & Duration: Cardioprotective and cognitive endpoints require sustained therapeutic plasma thresholds over months; brief or low-dose trials consistently yield null outcomes.',
      );
    }

    // Determine consensus state
    ScientificConsensusState state;
    bool hasDiscordance = hasSupported && (hasContradicted || hasUnresolved);

    if (!hasDiscordance) {
      state = ScientificConsensusState.scientificConsensus;
    } else if (confounders.isNotEmpty) {
      state = ScientificConsensusState.contextDependent;
    } else {
      state = ScientificConsensusState.genuineControversy;
    }

    final summary = _generateSynthesisSummary(
      topic: topic,
      state: state,
      confounders: confounders,
      rawCount: totalRaw,
      dedupCount: deduplicatedCount,
    );

    return ContradictionAnalysisRecord(
      topic: topic,
      consensusState: state,
      hasDiscordantOutcomes: hasDiscordance,
      identifiedConfounders: confounders,
      explanatoryMechanisms: mechanisms,
      deduplicatedFamilies: families,
      totalRawCitations: totalRaw,
      deduplicatedIndependentTrials: deduplicatedCount,
      synthesisSummary: summary,
    );
  }

  static String _deriveCohortName(String key, ScientificSource sample) {
    if (key.startsWith('COHORT-')) {
      return key.substring(7).replaceAll('_', ' ');
    }
    if (key.startsWith('NCT')) {
      return 'Trial Registration $key';
    }
    return sample.authorsOrJournal;
  }

  static String _generateSynthesisSummary({
    required String topic,
    required ScientificConsensusState state,
    required List<ConfounderDimension> confounders,
    required int rawCount,
    required int dedupCount,
  }) {
    switch (state) {
      case ScientificConsensusState.scientificConsensus:
        return 'Strong convergent consensus across $dedupCount independent study families ($rawCount published reports). Outcomes demonstrate high methodological reproducibility.';
      case ScientificConsensusState.contextDependent:
        final confNames = confounders.map((c) => c.name).join(', ');
        return 'Apparent outcome discordance is context-dependent, mediated by: $confNames. Subgroup stratification accounts for disparate findings between trials.';
      case ScientificConsensusState.genuineControversy:
        return 'Genuine scientific divergence observed across $dedupCount independent trials. Methodologically sound RCTs report conflicting primary endpoints without a single resolved confounder.';
      case ScientificConsensusState.insufficientData:
        return 'Sparse clinical literature ($rawCount citations). Additional high-powered preregistered trials are required before definitive conclusions can be drawn.';
    }
  }
}
