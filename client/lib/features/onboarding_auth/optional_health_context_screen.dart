import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 13: Optional Health Context
/// Authoritative Stitch Design: optional_health_context
class OptionalHealthContextScreen extends StatefulWidget {
  const OptionalHealthContextScreen({super.key});

  @override
  State<OptionalHealthContextScreen> createState() =>
      _OptionalHealthContextScreenState();
}

class _OptionalHealthContextScreenState
    extends State<OptionalHealthContextScreen> {
  final Set<String> _selectedConditions = {'sleep_disruption'};
  final _notesController = TextEditingController();

  final List<Map<String, String>> _conditionOptions = const [
    {'id': 'sleep_disruption', 'label': 'Sleep disruption / Insomnia'},
    {'id': 'vitamin_d', 'label': 'Low Vitamin D / Ferritin'},
    {'id': 'digestive', 'label': 'Digestive sensitivity / Bloating'},
    {'id': 'blood_pressure', 'label': 'Blood pressure management'},
    {'id': 'joint_pain', 'label': 'Joint stiffness / Inflammation'},
    {'id': 'metabolic', 'label': 'Metabolic / Blood sugar focus'},
    {'id': 'stress_energy', 'label': 'Chronic fatigue / Stress'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Nutrient Deficiencies',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: NETokens.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Step 3 of 4',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: NETokens.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: NETokens.space20, vertical: NETokens.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Is there any health context we should consider?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Share any areas you would like research and recommendations to take into account. Completely optional.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Condition options
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _conditionOptions.map((opt) {
                  final isSelected = _selectedConditions.contains(opt['id']);
                  return FilterChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedConditions.add(opt['id']!);
                        } else {
                          _selectedConditions.remove(opt['id']!);
                        }
                      });
                    },
                    selectedColor: NETokens.secondaryContainer,
                    checkmarkColor: NETokens.onSecondaryContainer,
                    backgroundColor: NETokens.surfaceContainerLow,
                    labelStyle: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? NETokens.onSecondaryContainer
                          : NETokens.onSurface,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                      side: BorderSide(
                        color: isSelected
                            ? NETokens.secondary
                            : NETokens.outlineVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: NETokens.space24),

              Text(
                'Current medications or notes (Optional)',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g. Taking magnesium glycinate 200mg, avoid grapefruit interactions',
                  hintStyle: const TextStyle(color: NETokens.outline, fontSize: 13),
                  filled: true,
                  fillColor: NETokens.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    borderSide: const BorderSide(color: NETokens.outlineVariant),
                  ),
                ),
              ),

              const SizedBox(height: NETokens.space28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusMd),
                    ),
                  ),
                  onPressed: () => context.go('/onboarding/constraints'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: NETokens.space8),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/onboarding/constraints'),
                  child: Text(
                    'Skip for now',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
