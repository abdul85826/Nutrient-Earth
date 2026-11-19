// ==============================================================================
// Nutrient Earth — 10-Year Bitemporal Personal Memory Models
// Distinct dimensions:
// 1. Valid Time: [validFrom, validTo] (Reality)
// 2. Transaction/System Time: [recordedAt, supersededAt] (System Knowledge)
// ==============================================================================

import 'package:uuid/uuid.dart';

enum FactCategory {
  preference,
  routine,
  allergyAndIntolerance,
  medicalHistory,
  medicationAndSupplement,
  biologicalBaseline,
  lifeEvent,
  environmentalSensitivity,
  goal;

  String get dbValue {
    switch (this) {
      case FactCategory.preference:
        return 'preference';
      case FactCategory.routine:
        return 'routine';
      case FactCategory.allergyAndIntolerance:
        return 'allergy_and_intolerance';
      case FactCategory.medicalHistory:
        return 'medical_history';
      case FactCategory.medicationAndSupplement:
        return 'medication_and_supplement';
      case FactCategory.biologicalBaseline:
        return 'biological_baseline';
      case FactCategory.lifeEvent:
        return 'life_event';
      case FactCategory.environmentalSensitivity:
        return 'environmental_sensitivity';
      case FactCategory.goal:
        return 'goal';
    }
  }

  static FactCategory fromDbValue(String value) {
    return FactCategory.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => FactCategory.preference,
    );
  }

  String get displayName {
    switch (this) {
      case FactCategory.preference:
        return 'Personal Preference';
      case FactCategory.routine:
        return 'Daily Routine';
      case FactCategory.allergyAndIntolerance:
        return 'Allergy & Intolerance';
      case FactCategory.medicalHistory:
        return 'Medical History';
      case FactCategory.medicationAndSupplement:
        return 'Medication & Supplement';
      case FactCategory.biologicalBaseline:
        return 'Biological Baseline';
      case FactCategory.lifeEvent:
        return 'Life Event';
      case FactCategory.environmentalSensitivity:
        return 'Environmental Sensitivity';
      case FactCategory.goal:
        return 'Health Goal';
    }
  }
}

enum FactProvenance {
  userExplicit,
  clinicianVerified,
  wearableInferred,
  aiConversationInferred,
  documentExtracted;

  String get dbValue {
    switch (this) {
      case FactProvenance.userExplicit:
        return 'user_explicit';
      case FactProvenance.clinicianVerified:
        return 'clinician_verified';
      case FactProvenance.wearableInferred:
        return 'wearable_inferred';
      case FactProvenance.aiConversationInferred:
        return 'ai_conversation_inferred';
      case FactProvenance.documentExtracted:
        return 'document_extracted';
    }
  }

  static FactProvenance fromDbValue(String value) {
    return FactProvenance.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => FactProvenance.userExplicit,
    );
  }
}

enum FactVerificationStatus {
  unverified,
  userConfirmed,
  clinicianApproved,
  rejected;

  String get dbValue {
    switch (this) {
      case FactVerificationStatus.unverified:
        return 'unverified';
      case FactVerificationStatus.userConfirmed:
        return 'user_confirmed';
      case FactVerificationStatus.clinicianApproved:
        return 'clinician_approved';
      case FactVerificationStatus.rejected:
        return 'rejected';
    }
  }

  static FactVerificationStatus fromDbValue(String value) {
    return FactVerificationStatus.values.firstWhere(
      (e) => e.dbValue == value || e.name == value,
      orElse: () => FactVerificationStatus.unverified,
    );
  }
}

/// Header record representing the persistent identity of a personal fact over decades.
class BitemporalPersonalFact {
  final String id;
  final String userId;
  final FactCategory category;
  final String factKey;
  final String title;
  final Map<String, dynamic> currentValue;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BitemporalPersonalFact({
    required this.id,
    required this.userId,
    required this.category,
    required this.factKey,
    required this.title,
    required this.currentValue,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'category': category.dbValue,
        'factKey': factKey,
        'title': title,
        'currentValue': currentValue,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory BitemporalPersonalFact.fromJson(Map<String, dynamic> json) {
    return BitemporalPersonalFact(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      category: FactCategory.fromDbValue(json['category'] as String? ?? 'preference'),
      factKey: json['fact_key'] as String? ?? json['factKey'] as String? ?? '',
      title: json['title'] as String? ?? '',
      currentValue: Map<String, dynamic>.from(json['current_value'] as Map? ?? json['currentValue'] as Map? ?? {}),
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }
}

/// Immutable record capturing a fact during its valid-time interval as known by system time.
class BitemporalFactVersion {
  final String id;
  final String factId;
  final String userId;
  final int versionNumber;
  final Map<String, dynamic> factValue;
  final DateTime validFrom;
  final DateTime? validTo;
  final DateTime recordedAt;
  final DateTime? supersededAt;
  final double confidence;
  final FactProvenance provenance;
  final Map<String, dynamic>? sourceReference;
  final FactVerificationStatus verificationStatus;
  final String? changeReason;
  final DateTime createdAt;

  const BitemporalFactVersion({
    required this.id,
    required this.factId,
    required this.userId,
    required this.versionNumber,
    required this.factValue,
    required this.validFrom,
    this.validTo,
    required this.recordedAt,
    this.supersededAt,
    this.confidence = 1.0,
    required this.provenance,
    this.sourceReference,
    this.verificationStatus = FactVerificationStatus.userConfirmed,
    this.changeReason,
    required this.createdAt,
  });

  /// Check if this version was true in the real world at [realTime].
  bool isRealWorldValidAt(DateTime realTime) {
    final startsBeforeOrAt = !validFrom.isAfter(realTime);
    final endsAfter = validTo == null || validTo!.isAfter(realTime);
    return startsBeforeOrAt && endsAfter;
  }

  /// Check if the system believed this version at [systemTime].
  bool isSystemBelievedAt(DateTime systemTime) {
    final recordedBeforeOrAt = !recordedAt.isAfter(systemTime);
    final supersededAfter = supersededAt == null || supersededAt!.isAfter(systemTime);
    return recordedBeforeOrAt && supersededAfter;
  }

  /// True if currently believed by the system (not superseded).
  bool get isCurrentlyActive => supersededAt == null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'factId': factId,
        'userId': userId,
        'versionNumber': versionNumber,
        'factValue': factValue,
        'validFrom': validFrom.toIso8601String(),
        'validTo': validTo?.toIso8601String(),
        'recordedAt': recordedAt.toIso8601String(),
        'supersededAt': supersededAt?.toIso8601String(),
        'confidence': confidence,
        'provenance': provenance.dbValue,
        'sourceReference': sourceReference,
        'verificationStatus': verificationStatus.dbValue,
        'changeReason': changeReason,
        'createdAt': createdAt.toIso8601String(),
      };

  factory BitemporalFactVersion.fromJson(Map<String, dynamic> json) {
    return BitemporalFactVersion(
      id: json['id'] as String? ?? const Uuid().v4(),
      factId: json['fact_id'] as String? ?? json['factId'] as String? ?? '',
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      versionNumber: (json['version_number'] as num? ?? json['versionNumber'] as num? ?? 1).toInt(),
      factValue: Map<String, dynamic>.from(json['fact_value'] as Map? ?? json['factValue'] as Map? ?? {}),
      validFrom: DateTime.parse(json['valid_from'] as String? ?? json['validFrom'] as String),
      validTo: json['valid_to'] != null
          ? DateTime.tryParse(json['valid_to'] as String)
          : (json['validTo'] != null ? DateTime.tryParse(json['validTo'] as String) : null),
      recordedAt: DateTime.parse(json['recorded_at'] as String? ?? json['recordedAt'] as String),
      supersededAt: json['superseded_at'] != null
          ? DateTime.tryParse(json['superseded_at'] as String)
          : (json['supersededAt'] != null ? DateTime.tryParse(json['supersededAt'] as String) : null),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      provenance: FactProvenance.fromDbValue(json['provenance'] as String? ?? 'user_explicit'),
      sourceReference: json['source_reference'] != null
          ? Map<String, dynamic>.from(json['source_reference'] as Map)
          : (json['sourceReference'] != null ? Map<String, dynamic>.from(json['sourceReference'] as Map) : null),
      verificationStatus: FactVerificationStatus.fromDbValue(
        json['verification_status'] as String? ?? json['verificationStatus'] as String? ?? 'unverified',
      ),
      changeReason: json['change_reason'] as String? ?? json['changeReason'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
