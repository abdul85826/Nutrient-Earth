import 'package:flutter/foundation.dart';

@immutable
class MedicalSafetyAssessment {
  final bool isEmergency;
  final String? emergencyNotice;
  final String? emergencyCategory;
  final String? recommendedAction;
  final List<String> redFlags;
  final bool shouldAbstain;

  const MedicalSafetyAssessment({
    required this.isEmergency,
    this.emergencyNotice,
    this.emergencyCategory,
    this.recommendedAction,
    this.redFlags = const [],
    required this.shouldAbstain,
  });

  static const safe = MedicalSafetyAssessment(
    isEmergency: false,
    shouldAbstain: false,
  );
}

class MedicalSafetyGuard {
  static final List<Map<String, dynamic>> _emergencyRules = [
    {
      'category': 'cardiac_coronary',
      'pattern': RegExp(
        r'\b(crushing\s+(chest\s+pain|pressure)|chest\s+pain.*radiat|radiating\s+to\s+(left\s+arm|jaw)|chest\s+pain)\b',
        caseSensitive: false,
      ),
      'action':
          'Call 911 or local emergency medical services immediately. Do not attempt self-treatment.',
    },
    {
      'category': 'acute_respiratory',
      'pattern': RegExp(
        r'\b(cannot\s+breathe|severe\s+shortness\s+of\s+breath|choking|asphyxi|stridor)\b',
        caseSensitive: false,
      ),
      'action':
          'Seek urgent emergency medical treatment immediately for acute airway obstruction.',
    },
    {
      'category': 'anaphylaxis_allergic',
      'pattern': RegExp(
        r'\b(anaphylax|throat\s+closing|lip\s+swelling.*breath|difficulty\s+swallowing.*breath|throat.*swelling)\b',
        caseSensitive: false,
      ),
      'action':
          'Administer epinephrine autoinjector if prescribed and call emergency services (911/999) immediately.',
    },
    {
      'category': 'neurological_stroke',
      'pattern': RegExp(
        r'\b(facial\s+droop|slurred\s+speech|sudden\s+weakness\s+on\s+one\s+side|signs\s+of\s+stroke|arm\s+numbness.*slurred)\b',
        caseSensitive: false,
      ),
      'action':
          'Immediate stroke protocol required (FAST). Transport to the nearest stroke center.',
    },
    {
      'category': 'severe_hemorrhage',
      'pattern': RegExp(
        r'\b(coughing\s+up\s+blood|vomiting\s+blood|profuse\s+bleeding|severe\s+hemorrhage)\b',
        caseSensitive: false,
      ),
      'action':
          'Apply firm pressure if external and contact emergency services immediately.',
    },
    {
      'category': 'toxicology',
      'pattern': RegExp(
        r'\b(swallowed\s+poison|ingested\s+(battery|bleach|detergent)|overdose)\b',
        caseSensitive: false,
      ),
      'action':
          'Call Poison Control (1-800-222-1222 in US) or emergency services immediately.',
    },
    {
      'category': 'altered_consciousness',
      'pattern': RegExp(
        r'\b(seizure.*active|unconscious|unresponsive|passing\s+out.*chest)\b',
        caseSensitive: false,
      ),
      'action':
          'Place in recovery position, ensure airway is clear, and call emergency services immediately.',
    },
    {
      'category': 'crisis_support',
      'pattern': RegExp(
        r'\b(suicid\w*|kill(?:ing)?\s+myself|end(?:ing)?\s+my\s+life|self[-\s]harm)\b',
        caseSensitive: false,
      ),
      'action':
          'Call or text 988 (Suicide & Crisis Lifeline in US/Canada) or 111 (UK) for free, confidential, immediate support.',
    },
  ];

  static MedicalSafetyAssessment evaluate(String query) {
    for (final rule in _emergencyRules) {
      final pattern = rule['pattern'] as RegExp;
      final match = pattern.firstMatch(query);
      if (match != null) {
        final category = rule['category'] as String;
        final action = rule['action'] as String;
        return MedicalSafetyAssessment(
          isEmergency: true,
          emergencyCategory: category,
          recommendedAction: action,
          emergencyNotice:
              'Potential acute emergency symptom detected: "${match.group(0)}".\n\nAction: $action\n\nNutrient Earth is an evidence research platform, not an acute emergency medical system.',
          redFlags: [match.group(0)!],
          shouldAbstain: true,
        );
      }
    }

    return MedicalSafetyAssessment.safe;
  }
}
