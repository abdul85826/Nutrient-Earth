enum EvidenceQuality {
  high, // Meta-analyses, double-blind RCTs
  moderate, // Controlled prospective cohort studies
  preliminary, // Mechanistic, observational, or in-vitro evidence
}

extension EvidenceQualityExtension on EvidenceQuality {
  String get label {
    switch (this) {
      case EvidenceQuality.high:
        return 'High Quality (RCTs / Systematic Reviews)';
      case EvidenceQuality.moderate:
        return 'Moderate Quality (Prospective Cohort Studies)';
      case EvidenceQuality.preliminary:
        return 'Preliminary (Observational / Mechanistic)';
    }
  }
}

enum UncertaintyLevel { low, medium, high }

extension UncertaintyLevelExtension on UncertaintyLevel {
  String get label {
    switch (this) {
      case UncertaintyLevel.low:
        return 'Low Uncertainty (Consistent Consensus)';
      case UncertaintyLevel.medium:
        return 'Moderate Uncertainty (Context-Dependent)';
      case UncertaintyLevel.high:
        return 'High Uncertainty (Limited Human Data)';
    }
  }
}

class EvidenceSource {
  final String title;
  final String authors;
  final int year;
  final String publication;
  final String? doiOrUrl;
  final String studyType;

  const EvidenceSource({
    required this.title,
    required this.authors,
    required this.year,
    required this.publication,
    this.doiOrUrl,
    required this.studyType,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'authors': authors,
    'year': year,
    'publication': publication,
    'doi_or_url': doiOrUrl,
    'study_type': studyType,
  };

  factory EvidenceSource.fromJson(Map<String, dynamic> json) => EvidenceSource(
    title: json['title'] as String,
    authors: json['authors'] as String,
    year: (json['year'] as num).toInt(),
    publication: json['publication'] as String,
    doiOrUrl: json['doi_or_url'] as String?,
    studyType: json['study_type'] as String,
  );
}

class HealthReportAttachment {
  final String id;
  final String filename;
  final String fileType;
  final int fileSize;
  final DateTime uploadedAt;
  final String? summary;

  const HealthReportAttachment({
    required this.id,
    required this.filename,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
    this.summary,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'file_type': fileType,
    'file_size': fileSize,
    'uploaded_at': uploadedAt.toIso8601String(),
    'summary': summary,
  };

  factory HealthReportAttachment.fromJson(Map<String, dynamic> json) =>
      HealthReportAttachment(
        id: json['id'] as String,
        filename: json['filename'] as String,
        fileType: json['file_type'] as String,
        fileSize: (json['file_size'] as num).toInt(),
        uploadedAt: DateTime.parse(json['uploaded_at'] as String),
        summary: json['summary'] as String?,
      );
}

class AIMessage {
  final String id;
  final bool isUser;
  final String content;
  final DateTime timestamp;
  final List<EvidenceSource> sources;
  final EvidenceQuality? evidenceQuality;
  final UncertaintyLevel? uncertainty;
  final List<String> practicalNextSteps;
  final List<String> missingInformationQuestions;
  final HealthReportAttachment? attachedReport;

  const AIMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.timestamp,
    this.sources = const [],
    this.evidenceQuality,
    this.uncertainty,
    this.practicalNextSteps = const [],
    this.missingInformationQuestions = const [],
    this.attachedReport,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'is_user': isUser,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'sources': sources.map((e) => e.toJson()).toList(),
    'evidence_quality': evidenceQuality?.name,
    'uncertainty': uncertainty?.name,
    'practical_next_steps': practicalNextSteps,
    'missing_information_questions': missingInformationQuestions,
    'attached_report': attachedReport?.toJson(),
  };

  factory AIMessage.fromJson(Map<String, dynamic> json) => AIMessage(
    id: json['id'] as String,
    isUser: json['is_user'] as bool,
    content: json['content'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    sources:
        (json['sources'] as List<dynamic>?)
            ?.map((e) => EvidenceSource.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    evidenceQuality: json['evidence_quality'] != null
        ? EvidenceQuality.values.firstWhere(
            (e) => e.name == json['evidence_quality'],
            orElse: () => EvidenceQuality.moderate,
          )
        : null,
    uncertainty: json['uncertainty'] != null
        ? UncertaintyLevel.values.firstWhere(
            (e) => e.name == json['uncertainty'],
            orElse: () => UncertaintyLevel.medium,
          )
        : null,
    practicalNextSteps:
        (json['practical_next_steps'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    missingInformationQuestions:
        (json['missing_information_questions'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        [],
    attachedReport: json['attached_report'] != null
        ? HealthReportAttachment.fromJson(
            json['attached_report'] as Map<String, dynamic>,
          )
        : null,
  );
}

class AIConversation {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<AIMessage> messages;

  const AIConversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  AIConversation copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<AIMessage>? messages,
  }) {
    return AIConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      messages: messages ?? this.messages,
    );
  }
}
