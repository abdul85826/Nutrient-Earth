// ==============================================================================
// Nutrient Earth — Personal Health Memory Domain Models
// Explicit data governance model separating conversational preferences
// from structured clinical records.
// Enforces Confirmation Gate: AI extractions start as draft_pending_review.
// ==============================================================================

import 'package:uuid/uuid.dart';

enum HealthRecordType {
  symptom,
  condition,
  allergy,
  medication,
  supplement,
  surgery,
  vital,
  labResult,
  medicalDocument,
  lifestylePattern;

  String get displayName {
    switch (this) {
      case HealthRecordType.symptom:
        return 'Symptom';
      case HealthRecordType.condition:
        return 'Medical Condition';
      case HealthRecordType.allergy:
        return 'Allergy & Reaction';
      case HealthRecordType.medication:
        return 'Medication';
      case HealthRecordType.supplement:
        return 'Active Supplement';
      case HealthRecordType.surgery:
        return 'Surgery / Hospitalization';
      case HealthRecordType.vital:
        return 'Vital Measurement';
      case HealthRecordType.labResult:
        return 'Biomarker & Lab Result';
      case HealthRecordType.medicalDocument:
        return 'Medical Document';
      case HealthRecordType.lifestylePattern:
        return 'Lifestyle & Cadence';
    }
  }
}

enum MemoryProvenanceSource {
  userReported,
  deviceMeasured,
  documentExtracted,
  clinicianConfirmed,
  aiInferred;

  String get label {
    switch (this) {
      case MemoryProvenanceSource.userReported:
        return 'User Reported';
      case MemoryProvenanceSource.deviceMeasured:
        return 'Device Measured';
      case MemoryProvenanceSource.documentExtracted:
        return 'Document Extracted';
      case MemoryProvenanceSource.clinicianConfirmed:
        return 'Clinician Confirmed';
      case MemoryProvenanceSource.aiInferred:
        return 'AI Inferred (Unconfirmed)';
    }
  }
}

enum MemoryVerificationStatus {
  draftPendingReview,
  userConfirmed,
  rejected,
  superseded;

  String get displayName {
    switch (this) {
      case MemoryVerificationStatus.draftPendingReview:
        return 'Draft (Needs Review)';
      case MemoryVerificationStatus.userConfirmed:
        return 'Confirmed';
      case MemoryVerificationStatus.rejected:
        return 'Rejected';
      case MemoryVerificationStatus.superseded:
        return 'Superseded';
    }
  }

  bool get isConfirmed => this == MemoryVerificationStatus.userConfirmed;
  bool get isDraft => this == MemoryVerificationStatus.draftPendingReview;
}

class HealthMemoryRecord {
  final String id;
  final String userId;
  final HealthRecordType recordType;
  final MemoryProvenanceSource provenanceSource;
  final String entityName;
  final String? recordValue;
  final String? recordUnit;
  final String? referenceRange;
  final bool? isAbnormal;
  final DateTime? observedDate;
  final DateTime recordedDate;
  final MemoryVerificationStatus verificationStatus;
  final double confidenceScore;
  final String? sourceReference;
  final String? notes;

  const HealthMemoryRecord({
    required this.id,
    required this.userId,
    required this.recordType,
    required this.provenanceSource,
    required this.entityName,
    this.recordValue,
    this.recordUnit,
    this.referenceRange,
    this.isAbnormal,
    this.observedDate,
    required this.recordedDate,
    this.verificationStatus = MemoryVerificationStatus.draftPendingReview,
    this.confidenceScore = 1.0,
    this.sourceReference,
    this.notes,
  });

  /// Factory creating an unconfirmed draft record from document extraction or AI observation.
  /// Anti-Diagnosis Rule: Always starts as draft_pending_review.
  factory HealthMemoryRecord.draftExtraction({
    required String userId,
    required HealthRecordType recordType,
    required String entityName,
    String? recordValue,
    String? recordUnit,
    String? referenceRange,
    bool? isAbnormal,
    DateTime? observedDate,
    String? sourceReference,
    double confidenceScore = 0.85,
    String? notes,
  }) {
    return HealthMemoryRecord(
      id: const Uuid().v4(),
      userId: userId,
      recordType: recordType,
      provenanceSource: MemoryProvenanceSource.documentExtracted,
      entityName: entityName,
      recordValue: recordValue,
      recordUnit: recordUnit,
      referenceRange: referenceRange,
      isAbnormal: isAbnormal,
      observedDate: observedDate,
      recordedDate: DateTime.now(),
      verificationStatus: MemoryVerificationStatus.draftPendingReview,
      confidenceScore: confidenceScore,
      sourceReference: sourceReference,
      notes: notes,
    );
  }

  HealthMemoryRecord confirmByUser() {
    return copyWith(
      verificationStatus: MemoryVerificationStatus.userConfirmed,
      notes: notes != null ? '$notes [User Confirmed]' : 'User Confirmed',
    );
  }

  HealthMemoryRecord rejectByUser() {
    return copyWith(
      verificationStatus: MemoryVerificationStatus.rejected,
      notes: notes != null ? '$notes [Rejected by User]' : 'Rejected by User',
    );
  }

  HealthMemoryRecord copyWith({
    MemoryVerificationStatus? verificationStatus,
    String? recordValue,
    String? recordUnit,
    String? notes,
    DateTime? observedDate,
  }) {
    return HealthMemoryRecord(
      id: id,
      userId: userId,
      recordType: recordType,
      provenanceSource: provenanceSource,
      entityName: entityName,
      recordValue: recordValue ?? this.recordValue,
      recordUnit: recordUnit ?? this.recordUnit,
      referenceRange: referenceRange,
      isAbnormal: isAbnormal,
      observedDate: observedDate ?? this.observedDate,
      recordedDate: recordedDate,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      confidenceScore: confidenceScore,
      sourceReference: sourceReference,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'recordType': recordType.name,
        'provenanceSource': provenanceSource.name,
        'entityName': entityName,
        'recordValue': recordValue,
        'recordUnit': recordUnit,
        'referenceRange': referenceRange,
        'isAbnormal': isAbnormal,
        'observedDate': observedDate?.toIso8601String(),
        'recordedDate': recordedDate.toIso8601String(),
        'verificationStatus': verificationStatus.name,
        'confidenceScore': confidenceScore,
        'sourceReference': sourceReference,
        'notes': notes,
      };

  factory HealthMemoryRecord.fromJson(Map<String, dynamic> json) {
    return HealthMemoryRecord(
      id: json['id'] as String? ?? const Uuid().v4(),
      userId: json['userId'] as String? ?? '',
      recordType: HealthRecordType.values.firstWhere(
        (e) => e.name == json['recordType'],
        orElse: () => HealthRecordType.symptom,
      ),
      provenanceSource: MemoryProvenanceSource.values.firstWhere(
        (e) => e.name == json['provenanceSource'],
        orElse: () => MemoryProvenanceSource.userReported,
      ),
      entityName: json['entityName'] as String? ?? 'General Health Note',
      recordValue: json['recordValue'] as String?,
      recordUnit: json['recordUnit'] as String?,
      referenceRange: json['referenceRange'] as String?,
      isAbnormal: json['isAbnormal'] as bool?,
      observedDate: json['observedDate'] != null ? DateTime.tryParse(json['observedDate'] as String) : null,
      recordedDate: json['recordedDate'] != null ? DateTime.parse(json['recordedDate'] as String) : DateTime.now(),
      verificationStatus: MemoryVerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => MemoryVerificationStatus.draftPendingReview,
      ),
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 1.0,
      sourceReference: json['sourceReference'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

