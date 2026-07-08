/// Domain Rules Engine Interfaces for Nutrient Earth BIOS.
///
/// Purpose: Define the contract for adaptive rule engines that apply
/// clinical decision logic to computed biological state outputs.
///
/// Responsibilities:
/// - Define rule types and priorities
/// - Enforce safety override triggers
/// - Support pluggable rule sets
/// - Log rule activations for audit trail
///
/// Future expansion:
/// - Clinical guidelines integration (NIH, WHO)
/// - Rule versioning and A/B testing
/// - Machine learning-derived rule discovery
library;

enum RulePriority { low, medium, high, critical }

enum RuleCategory {
  hydration,
  nutrition,
  sleep,
  stress,
  recovery,
  environment,
  safety,       // Clinical safety limits — highest priority
  behavioral,
}

/// A clinical or behavioral rule that can be triggered by biological state data.
class BiologicalRule {
  final String ruleId;
  final String name;
  final RuleCategory category;
  final RulePriority priority;
  final String description;
  final String intervention; // What to recommend when this rule fires

  const BiologicalRule({
    required this.ruleId,
    required this.name,
    required this.category,
    required this.priority,
    required this.description,
    required this.intervention,
  });

  Map<String, dynamic> toMap() => {
    'rule_id': ruleId,
    'name': name,
    'category': category.name,
    'priority': priority.name,
    'description': description,
    'intervention': intervention,
  };
}

/// A fired rule event — captures when a rule matched and why.
class RuleFiredEvent {
  final BiologicalRule rule;
  final String triggerReason;
  final double triggerValue;
  final double threshold;
  final DateTime firedAt;

  const RuleFiredEvent({
    required this.rule,
    required this.triggerReason,
    required this.triggerValue,
    required this.threshold,
    required this.firedAt,
  });

  Map<String, dynamic> toMap() => {
    ...rule.toMap(),
    'trigger_reason': triggerReason,
    'trigger_value': triggerValue,
    'threshold': threshold,
    'fired_at': firedAt.toIso8601String(),
  };
}

/// Abstract rule engine contract.
abstract class RuleEngine<TState> {
  /// Evaluate all rules against the given biological state.
  Future<List<RuleFiredEvent>> evaluate(TState state);

  /// Add a new rule to the engine's rule set.
  void addRule(BiologicalRule rule);

  /// Remove a rule by ID.
  void removeRule(String ruleId);

  /// Return all currently loaded rules.
  List<BiologicalRule> get loadedRules;
}
