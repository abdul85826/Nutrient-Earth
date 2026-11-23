// ==============================================================================
// Nutrient Earth — Universal Generative Response Engine
// Dynamic Block-Based Response Architecture (Schema v2026.3)
//
// The answer structure emerges from the requirements of the actual request:
// - TextBlock (markdown, direct answer, explanation, callout)
// - ComparisonTableBlock (structured comparative matrices)
// - CodeBlock (syntax-highlighted algorithms, calculations, scripts)
// - ActionPlanBlock (step-by-step routines, checklists)
// - MetricCalculationBlock (formulas, targets, baseline parameters)
// - EvidenceCardBlock (verified scientific sources, grades, limitations)
// - ProductAuditBlock (ingredient transparency, safety profiles)
// - SafetyNoticeBlock (clinical boundaries, medical emergency notices)
// - ClarificationBlock (follow-up intent resolution)
// - InteractiveSuggestionsBlock (dynamic next-step prompts)
// ==============================================================================

import '../evidence/scientific_evidence_contract.dart';

/// Adaptive effort and response depth selected by the planner.
enum AnswerDepthStrategy {
  minimal,
  concise,
  standard,
  detailed,
  comprehensive;

  String get displayName {
    switch (this) {
      case AnswerDepthStrategy.minimal:
        return 'Minimal (Direct & Conversational)';
      case AnswerDepthStrategy.concise:
        return 'Concise (Direct Answer)';
      case AnswerDepthStrategy.standard:
        return 'Standard (Contextual Explanation)';
      case AnswerDepthStrategy.detailed:
        return 'Detailed (Multi-Part Breakdown)';
      case AnswerDepthStrategy.comprehensive:
        return 'Comprehensive (Deep Investigation)';
    }
  }

  static AnswerDepthStrategy fromString(String? raw) {
    if (raw == null) return AnswerDepthStrategy.standard;
    final lower = raw.toLowerCase().trim();
    for (final s in AnswerDepthStrategy.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return AnswerDepthStrategy.standard;
  }
}

/// Callout styling for textual insights
enum TextCalloutType {
  none,
  leadSummary,
  insight,
  warning,
  quote,
  takeaway;

  static TextCalloutType fromString(String? val) {
    if (val == null) return TextCalloutType.none;
    for (final t in TextCalloutType.values) {
      if (t.name.toLowerCase() == val.toLowerCase()) return t;
    }
    return TextCalloutType.none;
  }
}

/// Severity level for safety alerts and medical boundaries
enum SafetySeverity {
  informational,
  caution,
  medicalDisclaimer,
  criticalEmergency;

  static SafetySeverity fromString(String? val) {
    if (val == null) return SafetySeverity.informational;
    for (final s in SafetySeverity.values) {
      if (s.name.toLowerCase() == val.toLowerCase()) return s;
    }
    return SafetySeverity.informational;
  }
}

/// Individual step in a dynamic action plan or checklist
class ActionStepItem {
  final String title;
  final String? detail;
  final String? timeOrDuration;
  final bool isCompleted;

  const ActionStepItem({
    required this.title,
    this.detail,
    this.timeOrDuration,
    this.isCompleted = false,
  });

  factory ActionStepItem.fromJson(Map<String, dynamic> json) {
    return ActionStepItem(
      title: json['title'] as String? ?? '',
      detail: json['detail'] as String?,
      timeOrDuration: json['timeOrDuration'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'detail': detail,
        'timeOrDuration': timeOrDuration,
        'isCompleted': isCompleted,
      };
}

/// Base class for all polymorphic response content blocks
abstract class ResponseContentBlock {
  final String blockType;

  const ResponseContentBlock({required this.blockType});

  Map<String, dynamic> toJson();

  static ResponseContentBlock fromJson(Map<String, dynamic> json) {
    final type = json['blockType'] as String? ?? 'text';
    switch (type) {
      case 'text':
        return TextBlock.fromJson(json);
      case 'table':
        return ComparisonTableBlock.fromJson(json);
      case 'code':
        return CodeBlock.fromJson(json);
      case 'actionPlan':
        return ActionPlanBlock.fromJson(json);
      case 'metricCalculation':
        return MetricCalculationBlock.fromJson(json);
      case 'evidenceCard':
        return EvidenceCardBlock.fromJson(json);
      case 'productAudit':
        return ProductAuditBlock.fromJson(json);
      case 'safetyNotice':
        return SafetyNoticeBlock.fromJson(json);
      case 'interactiveSuggestions':
        return InteractiveSuggestionsBlock.fromJson(json);
      default:
        return TextBlock(
          content: json['content'] as String? ?? json['text'] as String? ?? '',
        );
    }
  }
}

// -----------------------------------------------------------------------------
// 1. Text & Prose Block
// -----------------------------------------------------------------------------
class TextBlock extends ResponseContentBlock {
  final String content;
  final TextCalloutType calloutType;
  final String? heading;

  const TextBlock({
    required this.content,
    this.calloutType = TextCalloutType.none,
    this.heading,
  }) : super(blockType: 'text');

  bool get isLeadSummary => calloutType == TextCalloutType.leadSummary;

  factory TextBlock.fromJson(Map<String, dynamic> json) {
    return TextBlock(
      content: json['content'] as String? ?? '',
      calloutType: TextCalloutType.fromString(json['calloutType'] as String?),
      heading: json['heading'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'content': content,
        'calloutType': calloutType.name,
        'heading': heading,
      };
}

// -----------------------------------------------------------------------------
// 2. Structured Comparison Table Block
// -----------------------------------------------------------------------------
class ComparisonTableRow {
  final List<String> cells;

  const ComparisonTableRow({required this.cells});

  factory ComparisonTableRow.fromList(List<String> list) => ComparisonTableRow(cells: list);

  dynamic toJson() => cells;

  factory ComparisonTableRow.fromJson(dynamic json) {
    if (json is List) {
      return ComparisonTableRow(cells: json.map((e) => e.toString()).toList());
    } else if (json is Map && json['cells'] is List) {
      return ComparisonTableRow(cells: (json['cells'] as List).map((e) => e.toString()).toList());
    }
    return const ComparisonTableRow(cells: []);
  }
}

class ComparisonTableBlock extends ResponseContentBlock {
  final String? title;
  final List<String> headers;
  final List<ComparisonTableRow> rows;
  final String? caption;

  const ComparisonTableBlock({
    this.title,
    required this.headers,
    required this.rows,
    this.caption,
  }) : super(blockType: 'table');

  factory ComparisonTableBlock.fromJson(Map<String, dynamic> json) {
    return ComparisonTableBlock(
      title: json['title'] as String?,
      headers: (json['headers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      rows: (json['rows'] as List<dynamic>?)
              ?.map((r) => ComparisonTableRow.fromJson(r))
              .toList() ??
          const [],
      caption: json['caption'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'title': title,
        'headers': headers,
        'rows': rows.map((r) => r.toJson()).toList(),
        'caption': caption,
      };
}

// -----------------------------------------------------------------------------
// 3. Syntax-Styled Code Block
// -----------------------------------------------------------------------------
class CodeBlock extends ResponseContentBlock {
  final String language;
  final String code;
  final String? filename;
  final String? explanation;

  const CodeBlock({
    required this.language,
    required this.code,
    this.filename,
    this.explanation,
  }) : super(blockType: 'code');

  factory CodeBlock.fromJson(Map<String, dynamic> json) {
    return CodeBlock(
      language: json['language'] as String? ?? 'text',
      code: json['code'] as String? ?? '',
      filename: json['filename'] as String?,
      explanation: json['explanation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'language': language,
        'code': code,
        'filename': filename,
        'explanation': explanation,
      };
}

// -----------------------------------------------------------------------------
// 4. Action Plan & Checklist Block
// -----------------------------------------------------------------------------
class ActionPlanBlock extends ResponseContentBlock {
  final String title;
  final List<ActionStepItem> steps;

  const ActionPlanBlock({
    required this.title,
    required this.steps,
  }) : super(blockType: 'actionPlan');

  factory ActionPlanBlock.fromJson(Map<String, dynamic> json) {
    return ActionPlanBlock(
      title: json['title'] as String? ?? 'Practical Next Steps',
      steps: (json['steps'] as List<dynamic>?)
              ?.map((s) => ActionStepItem.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'title': title,
        'steps': steps.map((s) => s.toJson()).toList(),
      };
}

// -----------------------------------------------------------------------------
// 5. Quantitative Metric & Mathematical Calculation Block
// -----------------------------------------------------------------------------
class MetricCalculationBlock extends ResponseContentBlock {
  final String label;
  final String value;
  final String? unit;
  final String? formula;
  final String? baselineDetails;
  final double? confidenceScore;
  final bool isStandardBaseline;

  const MetricCalculationBlock({
    String? label,
    String? metricName,
    String? value,
    String? calculatedValue,
    this.unit,
    this.formula,
    String? baselineDetails,
    String? baselineReference,
    this.confidenceScore,
    this.isStandardBaseline = false,
  })  : label = label ?? metricName ?? 'Calculated Target',
        value = value ?? calculatedValue ?? '',
        baselineDetails = baselineDetails ?? baselineReference,
        super(blockType: 'metricCalculation');

  String get metricName => label;
  String get calculatedValue => value;
  String? get baselineReference => baselineDetails;

  factory MetricCalculationBlock.fromJson(Map<String, dynamic> json) {
    return MetricCalculationBlock(
      label: json['label'] as String? ?? json['metricName'] as String? ?? 'Calculated Target',
      value: json['value'] as String? ?? json['calculatedValue'] as String? ?? '',
      unit: json['unit'] as String?,
      formula: json['formula'] as String?,
      baselineDetails: json['baselineDetails'] as String? ?? json['baselineReference'] as String?,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      isStandardBaseline: json['isStandardBaseline'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'label': label,
        'value': value,
        'unit': unit,
        'formula': formula,
        'baselineDetails': baselineDetails,
        'confidenceScore': confidenceScore,
        'isStandardBaseline': isStandardBaseline,
      };
}

// -----------------------------------------------------------------------------
// 6. Scientific Evidence & Verified Provenance Block
// -----------------------------------------------------------------------------
class EvidenceCardBlock extends ResponseContentBlock {
  final String watermarkLabel;
  final EvidenceClassification classification;
  final List<ScientificSource> citations;
  final String? studyLimitations;
  final bool hasVerifiedSources;

  const EvidenceCardBlock({
    required this.watermarkLabel,
    this.classification = EvidenceClassification.wellSupported,
    this.citations = const [],
    this.studyLimitations,
    required this.hasVerifiedSources,
  }) : super(blockType: 'evidenceCard');

  factory EvidenceCardBlock.fromJson(Map<String, dynamic> json) {
    final citationsList = (json['citations'] as List<dynamic>?)
            ?.map((c) => ScientificSource.fromJson(c as Map<String, dynamic>))
            .toList() ??
        const [];
    final hasSources = (json['hasVerifiedSources'] as bool? ?? false) && citationsList.isNotEmpty;

    return EvidenceCardBlock(
      watermarkLabel: json['watermarkLabel'] as String? ?? 'Verified Scientific Evidence',
      classification: EvidenceClassification.fromString(json['classification'] as String?),
      citations: citationsList,
      studyLimitations: json['studyLimitations'] as String?,
      hasVerifiedSources: hasSources,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'watermarkLabel': watermarkLabel,
        'classification': classification.name,
        'citations': citations.map((c) => c.toJson()).toList(),
        'studyLimitations': studyLimitations,
        'hasVerifiedSources': hasVerifiedSources,
      };
}

// -----------------------------------------------------------------------------
// 7. Product & Cookware Safety Profile Block
// -----------------------------------------------------------------------------
class ProductAuditBlock extends ResponseContentBlock {
  final String productName;
  final String brand;
  final String safetyProfile;
  final String recommendation;
  final List<String> keyIngredients;
  final String? wearRisk;
  final bool isUncatalogued;

  const ProductAuditBlock({
    required this.productName,
    required this.brand,
    required this.safetyProfile,
    required this.recommendation,
    this.keyIngredients = const [],
    this.wearRisk,
    this.isUncatalogued = false,
  }) : super(blockType: 'productAudit');

  factory ProductAuditBlock.fromJson(Map<String, dynamic> json) {
    return ProductAuditBlock(
      productName: json['productName'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      safetyProfile: json['safetyProfile'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      keyIngredients: (json['keyIngredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      wearRisk: json['wearRisk'] as String?,
      isUncatalogued: json['isUncatalogued'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'productName': productName,
        'brand': brand,
        'safetyProfile': safetyProfile,
        'recommendation': recommendation,
        'keyIngredients': keyIngredients,
        'wearRisk': wearRisk,
        'isUncatalogued': isUncatalogued,
      };
}

// -----------------------------------------------------------------------------
// 8. Safety Notice & Clinical Boundary Block
// -----------------------------------------------------------------------------
class SafetyNoticeBlock extends ResponseContentBlock {
  final SafetySeverity severity;
  final String title;
  final String message;
  final List<String> emergencyActions;

  const SafetyNoticeBlock({
    this.severity = SafetySeverity.medicalDisclaimer,
    required this.title,
    required this.message,
    this.emergencyActions = const [],
  }) : super(blockType: 'safetyNotice');

  factory SafetyNoticeBlock.fromJson(Map<String, dynamic> json) {
    return SafetyNoticeBlock(
      severity: SafetySeverity.fromString(json['severity'] as String?),
      title: json['title'] as String? ?? 'Notice',
      message: json['message'] as String? ?? '',
      emergencyActions: (json['emergencyActions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'severity': severity.name,
        'title': title,
        'message': message,
        'emergencyActions': emergencyActions,
      };
}

// -----------------------------------------------------------------------------
// 9. Interactive Suggestions Block
// -----------------------------------------------------------------------------
class InteractiveSuggestionsBlock extends ResponseContentBlock {
  final List<String> promptChips;

  const InteractiveSuggestionsBlock({
    required this.promptChips,
  }) : super(blockType: 'interactiveSuggestions');

  factory InteractiveSuggestionsBlock.fromJson(Map<String, dynamic> json) {
    return InteractiveSuggestionsBlock(
      promptChips: (json['promptChips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'blockType': blockType,
        'promptChips': promptChips,
      };
}
