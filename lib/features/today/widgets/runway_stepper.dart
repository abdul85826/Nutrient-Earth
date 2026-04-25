import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/models/app_models.dart';

class RunwayStepper extends ConsumerWidget {
  const RunwayStepper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(actionProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'THE RUNWAY',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 16),
        ...actionState.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == actionState.steps.length - 1;
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTimeline(index, step, isLast),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: _buildStepCard(context, ref, step),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimeline(int index, ActionStep step, bool isLast) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: step.isCompleted 
                ? AppTheme.moss 
                : (step.isLocked ? AppTheme.forestMid : AppTheme.earth),
            border: Border.all(color: AppTheme.glassBorder),
          ),
          child: Center(
            child: step.isCompleted 
                ? const Icon(Icons.check, size: 16, color: AppTheme.forestDeep)
                : Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Container(
              width: 2,
              color: step.isCompleted ? AppTheme.moss : AppTheme.glassBorder,
            ),
          ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, WidgetRef ref, ActionStep step) {
    return Opacity(
      opacity: step.isLocked ? 0.4 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: step.isLocked ? Colors.transparent : AppTheme.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.cloud,
                    ),
                  ),
                ),
                if (!step.isLocked && !step.isCompleted)
                  TextButton(
                    onPressed: () {
                      ref.read(actionProvider.notifier).completeStep(step.id);
                      final providerState = ref.read(actionProvider);
                      final allCompleted = providerState.steps.every((s) => s.isCompleted);
                      if (allCompleted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You unlocked today\'s recovery state! +50 Points. Enhance this recovery with Glucose Balance Mix.'),
                            backgroundColor: AppTheme.moss,
                            duration: Duration(seconds: 4),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${step.title} completed. +10 Points. Pancreas improving.'),
                            backgroundColor: AppTheme.moss,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('DO NOW', style: TextStyle(color: AppTheme.earth, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                if (step.isCompleted)
                  const Text('DONE', style: TextStyle(color: AppTheme.moss, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              step.instruction,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13),
            ),
            if (!step.isLocked) ...[
              const SizedBox(height: 8),
              Text(
                '↳ ${step.benefit}',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.moss, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
