import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 12: Food Preferences and Dietary Restrictions
/// Authoritative Stitch Design: food_preferences_and_dietary_restrictions
class FoodPreferencesScreen extends StatefulWidget {
  const FoodPreferencesScreen({super.key});

  @override
  State<FoodPreferencesScreen> createState() => _FoodPreferencesScreenState();
}

class _FoodPreferencesScreenState extends State<FoodPreferencesScreen> {
  final Set<String> _selectedDiets = {'mediterranean'};
  final _avoidanceController = TextEditingController();

  final List<Map<String, String>> _dietOptions = const [
    {'id': 'no_specific', 'label': 'No specific pattern'},
    {'id': 'mediterranean', 'label': 'Mediterranean'},
    {'id': 'vegetarian', 'label': 'Vegetarian'},
    {'id': 'vegan', 'label': 'Vegan'},
    {'id': 'pescatarian', 'label': 'Pescatarian'},
    {'id': 'low_fodmap', 'label': 'Low FODMAP'},
    {'id': 'gluten_free', 'label': 'Gluten-Free'},
    {'id': 'keto_low_carb', 'label': 'Ketogenic / Low-Carb'},
  ];

  @override
  void dispose() {
    _avoidanceController.dispose();
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
          'Laboratory Integration',
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
                'Step 2 of 4',
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
                'How do you prefer to eat?',
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              Text(
                'Select dietary patterns that apply to your lifestyle to filter recommendations.',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: NETokens.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: NETokens.space20),

              // Wrap of diet option chips
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _dietOptions.map((opt) {
                  final isSelected = _selectedDiets.contains(opt['id']);
                  return FilterChip(
                    label: Text(opt['label']!),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        if (opt['id'] == 'no_specific') {
                          _selectedDiets.clear();
                          if (val) _selectedDiets.add('no_specific');
                        } else {
                          _selectedDiets.remove('no_specific');
                          if (val) {
                            _selectedDiets.add(opt['id']!);
                          } else {
                            _selectedDiets.remove(opt['id']!);
                          }
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

              // Any foods you avoid or allergic to
              Text(
                'Any specific foods or ingredients to avoid?',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: NETokens.space6),
              TextFormField(
                controller: _avoidanceController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'e.g. Peanuts, lactose, shellfish, artificial sweeteners',
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

              // Continue Button
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
                  onPressed: () => context.go('/onboarding/health-context'),
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
                  onPressed: () => context.go('/onboarding/health-context'),
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
