// ==============================================================================
// Nutrient Earth — Proactive Contextual Guidance Card Widget
// Renders the non-intrusive Today decision card:
// 1. Meal Routine guidance (millet/whole grain + dal + vegetables + protein)
// 2. Small preparation insight (fat-soluble carotenoids)
// 3. After-meal movement guidance (gentle walk / soleus pushups)
//
// Adheres strictly to Nutrient Earth design:
// Canvas #FAF8F5, Cards #EAF0EC, Text #00251D, Serif headers.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/decision/personal_health_decision_engine.dart';

class ProactiveGuidanceCardWidget extends ConsumerWidget {
  final String userId;
  final DateTime? timeOverride;

  const ProactiveGuidanceCardWidget({
    super.key,
    required this.userId,
    this.timeOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionEngine = ref.watch(personalHealthDecisionEngineProvider);

    return FutureBuilder<ContextualGuidanceCard?>(
      future: decisionEngine.evaluateProactiveGuidance(
        userId: userId,
        currentTimeOverride: timeOverride,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          // Zero-Spam: Say nothing when no guidance is appropriate
          return const SizedBox.shrink();
        }

        final card = snapshot.data!;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF0EC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCCD7D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Header
              Row(
                children: [
                  const Icon(Icons.wb_sunny_outlined, size: 16, color: Color(0xFF4A6B5D)),
                  const SizedBox(width: 6),
                  Text(
                    card.categoryTag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A6B5D),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 1. Routine Section
              Text(
                card.routineTitle,
                style: const TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00251D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.routineBody,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF2E4035),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Preparation Insight Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF8F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCD7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 15, color: Color(0xFF00251D)),
                        const SizedBox(width: 6),
                        Text(
                          card.preparationInsightTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00251D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.preparationInsightBody,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Color(0xFF2E4035),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. After-Meal Movement Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2.0),
                    child: Icon(Icons.directions_walk, size: 16, color: Color(0xFF00251D)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.afterMealMovementTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00251D),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.afterMealMovementBody,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Color(0xFF2E4035),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
