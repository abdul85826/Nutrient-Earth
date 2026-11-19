// ==============================================================================
// Nutrient Earth — Daily Scientific Intelligence Domain Models
// Curated 5-article daily editions with bilingual summaries (English + Tamil)
// and auditable 60-second read engagement verification.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum EvidenceStrength {
  metaAnalysis,
  systematicReview,
  randomizedControlledTrial,
  cohortStudy,
  mechanisticInVitro,
  observational;

  String get dbValue {
    switch (this) {
      case EvidenceStrength.metaAnalysis:
        return 'meta_analysis';
      case EvidenceStrength.systematicReview:
        return 'systematic_review';
      case EvidenceStrength.randomizedControlledTrial:
        return 'randomized_controlled_trial';
      case EvidenceStrength.cohortStudy:
        return 'cohort_study';
      case EvidenceStrength.mechanisticInVitro:
        return 'mechanistic_in_vitro';
      case EvidenceStrength.observational:
        return 'observational';
    }
  }

  static EvidenceStrength fromDbValue(String value) {
    return EvidenceStrength.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => EvidenceStrength.randomizedControlledTrial,
    );
  }

  String get label {
    switch (this) {
      case EvidenceStrength.metaAnalysis:
        return 'Meta-Analysis (Tier 1)';
      case EvidenceStrength.systematicReview:
        return 'Systematic Review (Tier 1)';
      case EvidenceStrength.randomizedControlledTrial:
        return 'Randomized Controlled Trial (Tier 2)';
      case EvidenceStrength.cohortStudy:
        return 'Longitudinal Cohort Study (Tier 3)';
      case EvidenceStrength.mechanisticInVitro:
        return 'Mechanistic In Vitro / In Vivo (Tier 4)';
      case EvidenceStrength.observational:
        return 'Observational Study (Tier 4)';
    }
  }
}

enum GoalCategory {
  circadianSleep,
  gutMicrobiome,
  metabolicHealth,
  stressReduction,
  cellularLongevity,
  cognitivePerformance,
  musculoskeletalStrength;

  String get dbValue {
    switch (this) {
      case GoalCategory.circadianSleep:
        return 'circadian_sleep';
      case GoalCategory.gutMicrobiome:
        return 'gut_microbiome';
      case GoalCategory.metabolicHealth:
        return 'metabolic_health';
      case GoalCategory.stressReduction:
        return 'stress_reduction';
      case GoalCategory.cellularLongevity:
        return 'cellular_longevity';
      case GoalCategory.cognitivePerformance:
        return 'cognitive_performance';
      case GoalCategory.musculoskeletalStrength:
        return 'musculoskeletal_strength';
    }
  }

  static GoalCategory fromDbValue(String value) {
    return GoalCategory.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => GoalCategory.metabolicHealth,
    );
  }

  String get displayName {
    switch (this) {
      case GoalCategory.circadianSleep:
        return 'Circadian Rhythm & Sleep';
      case GoalCategory.gutMicrobiome:
        return 'Gut Microbiome & Digestion';
      case GoalCategory.metabolicHealth:
        return 'Metabolic Flexibility';
      case GoalCategory.stressReduction:
        return 'Nervous System & Stress';
      case GoalCategory.cellularLongevity:
        return 'Cellular Longevity & Autophagy';
      case GoalCategory.cognitivePerformance:
        return 'Cognitive Clarity & Focus';
      case GoalCategory.musculoskeletalStrength:
        return 'Musculoskeletal Strength';
    }
  }
}

class DailyResearchArticle {
  final String id;
  final String editionId;
  final int orderIndex; // 1 to 5
  // English
  final String title;
  final String summaryEn;
  final String scientificTakeaway;
  final String actionableRecommendation;
  // Tamil
  final String? titleTa;
  final String? summaryTa;
  final String? scientificTakeawayTa;
  final String? actionableRecommendationTa;
  // Provenance & Rigor
  final EvidenceStrength evidenceStrength;
  final String citationReference;
  final String? publicationDoi;
  final GoalCategory matchedGoalCategory;
  final int estimatedReadingSeconds;
  final String? audioNarrationUrl;
  final int audioDurationSeconds;
  final DateTime createdAt;

  const DailyResearchArticle({
    required this.id,
    required this.editionId,
    required this.orderIndex,
    required this.title,
    required this.summaryEn,
    required this.scientificTakeaway,
    required this.actionableRecommendation,
    this.titleTa,
    this.summaryTa,
    this.scientificTakeawayTa,
    this.actionableRecommendationTa,
    required this.evidenceStrength,
    required this.citationReference,
    this.publicationDoi,
    required this.matchedGoalCategory,
    this.estimatedReadingSeconds = 90,
    this.audioNarrationUrl,
    this.audioDurationSeconds = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'editionId': editionId,
        'orderIndex': orderIndex,
        'title': title,
        'summaryEn': summaryEn,
        'scientificTakeaway': scientificTakeaway,
        'actionableRecommendation': actionableRecommendation,
        'titleTa': titleTa,
        'summaryTa': summaryTa,
        'scientificTakeawayTa': scientificTakeawayTa,
        'actionableRecommendationTa': actionableRecommendationTa,
        'evidenceStrength': evidenceStrength.dbValue,
        'citationReference': citationReference,
        'publicationDoi': publicationDoi,
        'matchedGoalCategory': matchedGoalCategory.dbValue,
        'estimatedReadingSeconds': estimatedReadingSeconds,
        'audioNarrationUrl': audioNarrationUrl,
        'audioDurationSeconds': audioDurationSeconds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DailyResearchArticle.fromJson(Map<String, dynamic> json) {
    return DailyResearchArticle(
      id: json['id'] as String? ?? const Uuid().v4(),
      editionId: json['edition_id'] as String? ?? json['editionId'] as String? ?? '',
      orderIndex: (json['order_index'] as num? ?? json['orderIndex'] as num? ?? 1).toInt(),
      title: json['title'] as String? ?? '',
      summaryEn: json['summary_en'] as String? ?? json['summaryEn'] as String? ?? '',
      scientificTakeaway: json['scientific_takeaway'] as String? ?? json['scientificTakeaway'] as String? ?? '',
      actionableRecommendation: json['actionable_recommendation'] as String? ?? json['actionableRecommendation'] as String? ?? '',
      titleTa: json['title_ta'] as String? ?? json['titleTa'] as String?,
      summaryTa: json['summary_ta'] as String? ?? json['summaryTa'] as String?,
      scientificTakeawayTa: json['scientific_takeaway_ta'] as String? ?? json['scientificTakeawayTa'] as String?,
      actionableRecommendationTa: json['actionable_recommendation_ta'] as String? ?? json['actionableRecommendationTa'] as String?,
      evidenceStrength: EvidenceStrength.fromDbValue(json['evidence_strength'] as String? ?? json['evidenceStrength'] as String? ?? 'randomized_controlled_trial'),
      citationReference: json['citation_reference'] as String? ?? json['citationReference'] as String? ?? '',
      publicationDoi: json['publication_doi'] as String? ?? json['publicationDoi'] as String?,
      matchedGoalCategory: GoalCategory.fromDbValue(json['matched_goal_category'] as String? ?? json['matchedGoalCategory'] as String? ?? 'metabolic_health'),
      estimatedReadingSeconds: (json['estimated_reading_seconds'] as num? ?? json['estimatedReadingSeconds'] as num? ?? 90).toInt(),
      audioNarrationUrl: json['audio_narration_url'] as String? ?? json['audioNarrationUrl'] as String?,
      audioDurationSeconds: (json['audio_duration_seconds'] as num? ?? json['audioDurationSeconds'] as num? ?? 0).toInt(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}

class DailyResearchEdition {
  final String id;
  final String userId;
  final DateTime editionDate;
  final String title;
  final String subtitle;
  final String status;
  final List<DailyResearchArticle> articles;
  final DateTime createdAt;

  const DailyResearchEdition({
    required this.id,
    required this.userId,
    required this.editionDate,
    required this.title,
    required this.subtitle,
    this.status = 'published',
    this.articles = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'editionDate': editionDate.toIso8601String().substring(0, 10),
        'title': title,
        'subtitle': subtitle,
        'status': status,
        'articles': articles.map((a) => a.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory DailyResearchEdition.fromJson(Map<String, dynamic> json) {
    final rawArticles = json['articles'] as List? ?? [];
    return DailyResearchEdition(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      editionDate: DateTime.parse(json['edition_date'] as String? ?? json['editionDate'] as String),
      title: json['title'] as String? ?? 'Daily Scientific Intelligence',
      subtitle: json['subtitle'] as String? ?? 'Evidence-based insights for your biology',
      status: json['status'] as String? ?? 'published',
      articles: rawArticles.map((e) => DailyResearchArticle.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}

enum ReadEngagementState {
  unread,
  inProgress,
  verifiedRead;

  String get label {
    switch (this) {
      case ReadEngagementState.unread:
        return 'Unread';
      case ReadEngagementState.inProgress:
        return 'Reading In Progress';
      case ReadEngagementState.verifiedRead:
        return 'Verified Read';
    }
  }
}

class ArticleReadingSession {
  final String id;
  final String userId;
  final String articleId;
  final DateTime sessionStart;
  final DateTime? sessionEnd;
  final int dwellTimeSeconds;
  final int audioListenSeconds;
  final double scrollDepthPercent;
  final bool isVerifiedRead;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  const ArticleReadingSession({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.sessionStart,
    this.sessionEnd,
    this.dwellTimeSeconds = 0,
    this.audioListenSeconds = 0,
    this.scrollDepthPercent = 0.0,
    this.isVerifiedRead = false,
    this.verifiedAt,
    required this.createdAt,
  });

  /// Engagement state machine:
  /// Requires at least 60s active dwell or 60s audio listen to be verifiedRead.
  ReadEngagementState get engagementState {
    if (isVerifiedRead || dwellTimeSeconds >= 60 || audioListenSeconds >= 60) {
      return ReadEngagementState.verifiedRead;
    }
    if (dwellTimeSeconds > 0 || audioListenSeconds > 0) {
      return ReadEngagementState.inProgress;
    }
    return ReadEngagementState.unread;
  }

  int get remainingSecondsToVerify => (60 - dwellTimeSeconds).clamp(0, 60);

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'articleId': articleId,
        'sessionStart': sessionStart.toIso8601String(),
        'sessionEnd': sessionEnd?.toIso8601String(),
        'dwellTimeSeconds': dwellTimeSeconds,
        'audioListenSeconds': audioListenSeconds,
        'scrollDepthPercent': scrollDepthPercent,
        'isVerifiedRead': isVerifiedRead,
        'verifiedAt': verifiedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ArticleReadingSession.fromJson(Map<String, dynamic> json) {
    return ArticleReadingSession(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      articleId: json['article_id'] as String? ?? json['articleId'] as String? ?? '',
      sessionStart: json['session_start'] != null ? DateTime.parse(json['session_start'] as String) : DateTime.now(),
      sessionEnd: json['session_end'] != null ? DateTime.parse(json['session_end'] as String) : null,
      dwellTimeSeconds: (json['dwell_time_seconds'] as num? ?? json['dwellTimeSeconds'] as num? ?? 0).toInt(),
      audioListenSeconds: (json['audio_listen_seconds'] as num? ?? json['audioListenSeconds'] as num? ?? 0).toInt(),
      scrollDepthPercent: (json['scroll_depth_percent'] as num? ?? json['scrollDepthPercent'] as num? ?? 0.0).toDouble(),
      isVerifiedRead: json['is_verified_read'] as bool? ?? json['isVerifiedRead'] as bool? ?? false,
      verifiedAt: json['verified_at'] != null ? DateTime.parse(json['verified_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}
