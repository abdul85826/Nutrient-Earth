import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../data/learn_discover_repository.dart';

class ExerciseSection extends ConsumerWidget {
  const ExerciseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routinesAsync = ref.watch(exerciseRoutinesProvider);

    return routinesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading routines: $err')),
      data: (routines) => ListView.builder(
        padding: const EdgeInsets.all(NETokens.space16),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: NETokens.space16),
            child: NECard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      NEChip(
                        label: routine.targetGoal,
                        type: NEChipType.outline,
                        isSelected: true,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: NETokens.textMuted,
                      ),
                      const SizedBox(width: NETokens.space4),
                      Text(
                        '${routine.durationMinutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: NETokens.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: NETokens.space12),
                  Text(
                    routine.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: NETokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: NETokens.space4),
                  Text(
                    'Difficulty: ${routine.difficultyLevel} • Equipment: ${routine.equipmentNeeded.join(", ")}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: NETokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: NETokens.space16),
                  const Text(
                    'Exercise Movements:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: NETokens.primary,
                    ),
                  ),
                  const SizedBox(height: NETokens.space8),
                  ...routine.movements.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: NETokens.space8),
                      child: Container(
                        padding: const EdgeInsets.all(NETokens.space8),
                        decoration: BoxDecoration(
                          color: NETokens.surfaceElevated,
                          borderRadius: BorderRadius.circular(
                            NETokens.radiusSm,
                          ),
                          border: Border.all(color: NETokens.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  m.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  m.repsOrDuration,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: NETokens.space4),
                            Text(
                              'Cue: ${m.coachingCue}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: NETokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: NETokens.space12),
                  // Injury modifications
                  Container(
                    padding: const EdgeInsets.all(NETokens.space8),
                    decoration: BoxDecoration(
                      color: NETokens.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(NETokens.radiusSm),
                    ),
                    child: Text(
                      'Modifications: ${routine.injuryModifications}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: NETokens.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
