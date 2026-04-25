import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/app_providers.dart';

class ProblemPicker extends ConsumerWidget {
  const ProblemPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedArea = ref.watch(personaProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT IS YOUR MAIN FOCUS?',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildChoiceChip(ref, 'High Sugar', ProblemArea.sugar, selectedArea),
            _buildChoiceChip(ref, 'Low Energy', ProblemArea.energy, selectedArea),
            _buildChoiceChip(ref, 'Weight Gain', ProblemArea.weight, selectedArea),
            _buildChoiceChip(ref, 'Stress', ProblemArea.stress, selectedArea),
            _buildChoiceChip(ref, 'BP Issues', ProblemArea.bp, selectedArea),
          ],
        ),
        if (selectedArea != ProblemArea.none) ...[
          const SizedBox(height: 24),
          _buildOperationPlan(context, selectedArea),
        ],
      ],
    );
  }

  Widget _buildChoiceChip(WidgetRef ref, String label, ProblemArea area, ProblemArea selected) {
    final isSelected = area == selected;
    return GestureDetector(
      onTap: () => ref.read(personaProvider.notifier).state = area,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.earth : AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppTheme.earth : AppTheme.glassBorder),
          boxShadow: isSelected ? [
            BoxShadow(color: AppTheme.earth.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 1)
          ] : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.forestDeep : AppTheme.cloud,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildOperationPlan(BuildContext context, ProblemArea area) {
    String plan = '';
    String herbs = '';
    
    switch (area) {
      case ProblemArea.sugar:
        plan = 'Fasting gap + Walking + Cinnamon tea.';
        herbs = 'Fenugreek, Cinnamon, Karela';
        break;
      case ProblemArea.energy:
        plan = 'Morning sunlight + Hydration + Breathing.';
        herbs = 'Ashwagandha, Dates, Maca';
        break;
      case ProblemArea.weight:
        plan = 'Micro-walking + Low carb + Herbal mix.';
        herbs = 'Garcinia, Green Tea, Guggul';
        break;
      case ProblemArea.stress:
        plan = 'Deep reflection + Magnesium + Tulsi.';
        herbs = 'Tulsi, Brahmi, Jatamansi';
        break;
      case ProblemArea.bp:
        plan = 'Salt reduction + Beetroot + Meditation.';
        herbs = 'Arjuna, Garlic, Hibiscus';
        break;
      default: break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.forestMid.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.moss.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: AppTheme.moss, size: 20),
              const SizedBox(width: 8),
              Text('NE OPERATION PLAN', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.moss)),
            ],
          ),
          const SizedBox(height: 16),
          Text(plan, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, color: AppTheme.cloud)),
          const SizedBox(height: 8),
          Text('Key herbs: $herbs', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 10, color: AppTheme.cloud.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
