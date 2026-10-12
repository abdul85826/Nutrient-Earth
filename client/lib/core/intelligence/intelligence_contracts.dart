import 'package:flutter/foundation.dart';

enum IntelligenceDomain { nutrition, body, environment, behavior, evidence }

enum ClaimEpistemicState {
  supported,
  preliminary,
  conflicting,
  unverified,
  refuted,
}

@immutable
class EvidenceItem {
  final String id;
  final String title;
  final String authors;
  final int year;
  final String source;
  final String? url;
  final String studyType; // e.g. "Double-Blind RCT", "Meta-Analysis", "Cohort"
  final String keyFinding;
  final double qualityScore; // 0.0 to 1.0

  const EvidenceItem({
    required this.id,
    required this.title,
    required this.authors,
    required this.year,
    required this.source,
    this.url,
    required this.studyType,
    required this.keyFinding,
    this.qualityScore = 0.9,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'authors': authors,
    'year': year,
    'source': source,
    'url': url,
    'studyType': studyType,
    'keyFinding': keyFinding,
    'qualityScore': qualityScore,
  };
}

@immutable
class IntelligenceClaim {
  final String statement;
  final ClaimEpistemicState epistemicState;
  final double confidenceScore; // 0.0 to 1.0
  final List<String> evidenceIds;
  final String? clinicalNote;

  const IntelligenceClaim({
    required this.statement,
    required this.epistemicState,
    required this.confidenceScore,
    this.evidenceIds = const [],
    this.clinicalNote,
  });

  Map<String, dynamic> toJson() => {
    'statement': statement,
    'epistemicState': epistemicState.name,
    'confidenceScore': confidenceScore,
    'evidenceIds': evidenceIds,
    'clinicalNote': clinicalNote,
  };
}

@immutable
class DomainFinding {
  final IntelligenceDomain domain;
  final String title;
  final String summary;
  final List<String> insights;
  final List<String> warnings;
  final double domainConfidence;

  const DomainFinding({
    required this.domain,
    required this.title,
    required this.summary,
    this.insights = const [],
    this.warnings = const [],
    this.domainConfidence = 0.85,
  });

  Map<String, dynamic> toJson() => {
    'domain': domain.name,
    'title': title,
    'summary': summary,
    'insights': insights,
    'warnings': warnings,
    'domainConfidence': domainConfidence,
  };
}

enum QueryInputType { text, camera, gallery, link, voice }

@immutable
class AgentTask {
  final String id;
  final String query;
  final QueryInputType inputType;
  final List<int>? imageBytes;
  final String? url;
  final Map<String, dynamic>? userContext;
  final DateTime timestamp;

  const AgentTask({
    required this.id,
    required this.query,
    this.inputType = QueryInputType.text,
    this.imageBytes,
    this.url,
    this.userContext,
    required this.timestamp,
  });
}

@immutable
class AnswerPlan {
  final String taskId;
  final String query;
  final String executiveSummary;
  final List<DomainFinding> domainFindings;
  final List<IntelligenceClaim> verifiedClaims;
  final List<EvidenceItem> evidenceCitations;
  final List<String> actionableGuidance;
  final List<String> safetyDisclaimers;
  final double overallConfidence;
  final DateTime generatedAt;
  final bool isAbstained;
  final String? abstentionReason;
  final bool isEmergency;
  final String? emergencyNotice;

  const AnswerPlan({
    required this.taskId,
    required this.query,
    required this.executiveSummary,
    required this.domainFindings,
    required this.verifiedClaims,
    required this.evidenceCitations,
    required this.actionableGuidance,
    required this.safetyDisclaimers,
    required this.overallConfidence,
    required this.generatedAt,
    this.isAbstained = false,
    this.abstentionReason,
    this.isEmergency = false,
    this.emergencyNotice,
  });
}
