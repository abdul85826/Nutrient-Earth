class ArticleItem {
  final String id;
  final String title;
  final String
  category; // 'Longevity', 'Nutrition', 'Sleep', 'Cardiorespiratory'
  final String summary;
  final String content;
  final int readingTimeMinutes;
  final int evidenceScore; // 0 - 100 based on study rigor
  final String primarySourceCitation;
  final bool isPeerReviewed;
  final DateTime publishedDate;
  final List<String> keyTakeaways;

  const ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.readingTimeMinutes,
    required this.evidenceScore,
    required this.primarySourceCitation,
    required this.isPeerReviewed,
    required this.publishedDate,
    required this.keyTakeaways,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'summary': summary,
    'content': content,
    'reading_time_minutes': readingTimeMinutes,
    'evidence_score': evidenceScore,
    'primary_source_citation': primarySourceCitation,
    'is_peer_reviewed': isPeerReviewed,
    'published_date': publishedDate.toIso8601String(),
    'key_takeaways': keyTakeaways,
  };

  factory ArticleItem.fromJson(Map<String, dynamic> json) => ArticleItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    summary: json['summary'] as String,
    content: json['content'] as String,
    readingTimeMinutes: (json['reading_time_minutes'] as num).toInt(),
    evidenceScore: (json['evidence_score'] as num).toInt(),
    primarySourceCitation: json['primary_source_citation'] as String,
    isPeerReviewed: json['is_peer_reviewed'] as bool,
    publishedDate: DateTime.parse(json['published_date'] as String),
    keyTakeaways:
        (json['key_takeaways'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
  );
}

class ExerciseMovement {
  final String name;
  final String targetMuscle;
  final String repsOrDuration;
  final String coachingCue;

  const ExerciseMovement({
    required this.name,
    required this.targetMuscle,
    required this.repsOrDuration,
    required this.coachingCue,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'target_muscle': targetMuscle,
    'reps_or_duration': repsOrDuration,
    'coaching_cue': coachingCue,
  };

  factory ExerciseMovement.fromJson(Map<String, dynamic> json) =>
      ExerciseMovement(
        name: json['name'] as String,
        targetMuscle: json['target_muscle'] as String,
        repsOrDuration: json['reps_or_duration'] as String,
        coachingCue: json['coaching_cue'] as String,
      );
}

class ExerciseRoutine {
  final String id;
  final String name;
  final String
  targetGoal; // 'Zone 2 Cardio', 'Hypertrophy', 'Joint Mobility', 'VO2 Max'
  final String difficultyLevel; // 'Beginner', 'Intermediate', 'Advanced'
  final int durationMinutes;
  final List<String> equipmentNeeded;
  final List<ExerciseMovement> movements;
  final String injuryModifications;
  final String scientificRationale;

  const ExerciseRoutine({
    required this.id,
    required this.name,
    required this.targetGoal,
    required this.difficultyLevel,
    required this.durationMinutes,
    required this.equipmentNeeded,
    required this.movements,
    required this.injuryModifications,
    required this.scientificRationale,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'target_goal': targetGoal,
    'difficulty_level': difficultyLevel,
    'duration_minutes': durationMinutes,
    'equipment_needed': equipmentNeeded,
    'movements': movements.map((e) => e.toJson()).toList(),
    'injury_modifications': injuryModifications,
    'scientific_rationale': scientificRationale,
  };

  factory ExerciseRoutine.fromJson(Map<String, dynamic> json) =>
      ExerciseRoutine(
        id: json['id'] as String,
        name: json['name'] as String,
        targetGoal: json['target_goal'] as String,
        difficultyLevel: json['difficulty_level'] as String,
        durationMinutes: (json['duration_minutes'] as num).toInt(),
        equipmentNeeded:
            (json['equipment_needed'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        movements:
            (json['movements'] as List<dynamic>?)
                ?.map(
                  (e) => ExerciseMovement.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        injuryModifications: json['injury_modifications'] as String? ?? '',
        scientificRationale: json['scientific_rationale'] as String? ?? '',
      );
}

class ProductItem {
  final String id;
  final String name;
  final String
  category; // 'Supplements', 'Diagnostics', 'Sleep Tech', 'Recovery'
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String summary;
  final List<String> verifiedSpecs;
  final String thirdPartyCert; // e.g. 'NSF Certified for Sport', 'USP Verified', 'Labdoor A+'
  final List<String> ingredientsOrComponents;
  final String transparentPricingBreakdown;

  const ProductItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.currency = 'USD',
    required this.rating,
    required this.reviewCount,
    required this.summary,
    required this.verifiedSpecs,
    required this.thirdPartyCert,
    required this.ingredientsOrComponents,
    required this.transparentPricingBreakdown,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'price': price,
    'currency': currency,
    'rating': rating,
    'review_count': reviewCount,
    'summary': summary,
    'verified_specs': verifiedSpecs,
    'third_party_cert': thirdPartyCert,
    'ingredients_or_components': ingredientsOrComponents,
    'transparent_pricing_breakdown': transparentPricingBreakdown,
  };

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
    id: json['id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    price: (json['price'] as num).toDouble(),
    currency: json['currency'] as String? ?? 'USD',
    rating: (json['rating'] as num).toDouble(),
    reviewCount: (json['review_count'] as num).toInt(),
    summary: json['summary'] as String,
    verifiedSpecs:
        (json['verified_specs'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    thirdPartyCert: json['third_party_cert'] as String? ?? '',
    ingredientsOrComponents:
        (json['ingredients_or_components'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    transparentPricingBreakdown:
        json['transparent_pricing_breakdown'] as String? ?? '',
  );
}
