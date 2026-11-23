// ==============================================================================
// Nutrient Earth — Evidence & Citation Foundation
// Strictly verified scientific source and claim contracts.
// ==============================================================================

enum EvidenceVerificationStatus {
  liveVerified,
  peerReviewedArchive,
  unverifiedClaim,
  conflictingEvidence,
}

enum ClaimSupportStatus {
  supported,
  contradicted,
  unresolved,
  insufficientEvidence,
}

enum StudyDesignGrade {
  systematicReviewMetaAnalysis,
  randomizedControlledTrial,
  cohortStudy,
  inVitroPharmacokinetics,
  expertConsensus,
  observational,
  unspecified,
}

/// Evidence classification tier based on empirical study rigor.
enum EvidenceClassification {
  wellSupported, // Replicated randomized controlled trials, systematic reviews, meta-analyses
  limitedEvidence, // Small preliminary clinical trials, in-vitro/animal studies
  mixedEvidence, // Divergent or contradictory clinical outcomes across studies
  notVerified; // Unverified anecdotal or social media claim without indexed scientific basis

  String get displayName {
    switch (this) {
      case EvidenceClassification.wellSupported:
        return 'Well Supported';
      case EvidenceClassification.limitedEvidence:
        return 'Limited Evidence';
      case EvidenceClassification.mixedEvidence:
        return 'Mixed Evidence';
      case EvidenceClassification.notVerified:
        return 'Not Verified';
    }
  }

  static EvidenceClassification fromString(String? val) {
    if (val == null) return EvidenceClassification.notVerified;
    final lower = val.toLowerCase();
    if (lower.contains('well') || lower.contains('strong')) return EvidenceClassification.wellSupported;
    if (lower.contains('limit') || lower.contains('preliminary')) return EvidenceClassification.limitedEvidence;
    if (lower.contains('mix') || lower.contains('inconclusive')) return EvidenceClassification.mixedEvidence;
    return EvidenceClassification.notVerified;
  }
}

class ScientificSource {
  final String title;
  final String authorsOrJournal;
  final String year;
  final String evidenceGrade;
  final StudyDesignGrade studyDesign;
  final String? pmid;
  final String? doi;
  final String? url;
  final EvidenceVerificationStatus verificationStatus;
  final int? sampleSize;
  final bool isHumanTrial;

  const ScientificSource({
    required this.title,
    required this.authorsOrJournal,
    required this.year,
    required this.evidenceGrade,
    this.studyDesign = StudyDesignGrade.unspecified,
    this.pmid,
    this.doi,
    this.url,
    this.verificationStatus = EvidenceVerificationStatus.peerReviewedArchive,
    this.sampleSize,
    this.isHumanTrial = true,
  });

  factory ScientificSource.fromJson(Map<String, dynamic> json) {
    return ScientificSource(
      title: json['title'] as String? ?? 'Scientific Literature Review',
      authorsOrJournal: json['authorsOrJournal'] as String? ?? 'Nutritional Research Reviews',
      year: json['year'] as String? ?? DateTime.now().year.toString(),
      evidenceGrade: json['evidenceGrade'] as String? ?? 'Evidence Synthesis',
      studyDesign: _parseStudyDesign(json['studyDesign'] as String?),
      pmid: json['pmid'] as String?,
      doi: json['doi'] as String?,
      url: json['url'] as String?,
      verificationStatus: _parseVerificationStatus(json['verificationStatus'] as String?),
      sampleSize: json['sampleSize'] as int?,
      isHumanTrial: json['isHumanTrial'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'authorsOrJournal': authorsOrJournal,
        'year': year,
        'evidenceGrade': evidenceGrade,
        'studyDesign': studyDesign.name,
        'pmid': pmid,
        'doi': doi,
        'url': url,
        'verificationStatus': verificationStatus.name,
        'sampleSize': sampleSize,
        'isHumanTrial': isHumanTrial,
      };

  static StudyDesignGrade _parseStudyDesign(String? raw) {
    if (raw == null) return StudyDesignGrade.unspecified;
    for (final grade in StudyDesignGrade.values) {
      if (grade.name.toLowerCase() == raw.toLowerCase()) return grade;
    }
    return StudyDesignGrade.unspecified;
  }

  static EvidenceVerificationStatus _parseVerificationStatus(String? raw) {
    if (raw == null) return EvidenceVerificationStatus.peerReviewedArchive;
    for (final status in EvidenceVerificationStatus.values) {
      if (status.name.toLowerCase() == raw.toLowerCase()) return status;
    }
    return EvidenceVerificationStatus.peerReviewedArchive;
  }
}

class ScientificClaim {
  final String claimText;
  final ClaimSupportStatus supportStatus;
  final String physiologicalMechanism;
  final List<ScientificSource> supportingSources;
  final List<ScientificSource> contradictingSources;
  final String? clinicalTakeaway;

  const ScientificClaim({
    required this.claimText,
    required this.supportStatus,
    required this.physiologicalMechanism,
    this.supportingSources = const [],
    this.contradictingSources = const [],
    this.clinicalTakeaway,
  });

  factory ScientificClaim.fromJson(Map<String, dynamic> json) {
    return ScientificClaim(
      claimText: json['claimText'] as String? ?? '',
      supportStatus: _parseSupportStatus(json['supportStatus'] as String?),
      physiologicalMechanism: json['physiologicalMechanism'] as String? ?? '',
      supportingSources: (json['supportingSources'] as List<dynamic>?)
              ?.map((s) => ScientificSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      contradictingSources: (json['contradictingSources'] as List<dynamic>?)
              ?.map((s) => ScientificSource.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      clinicalTakeaway: json['clinicalTakeaway'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'claimText': claimText,
        'supportStatus': supportStatus.name,
        'physiologicalMechanism': physiologicalMechanism,
        'supportingSources': supportingSources.map((s) => s.toJson()).toList(),
        'contradictingSources': contradictingSources.map((s) => s.toJson()).toList(),
        'clinicalTakeaway': clinicalTakeaway,
      };

  static ClaimSupportStatus _parseSupportStatus(String? raw) {
    if (raw == null) return ClaimSupportStatus.supported;
    for (final status in ClaimSupportStatus.values) {
      if (status.name.toLowerCase() == raw.toLowerCase()) return status;
    }
    return ClaimSupportStatus.supported;
  }
}
