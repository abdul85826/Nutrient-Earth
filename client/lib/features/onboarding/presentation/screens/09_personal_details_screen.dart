// ==============================================================================
// Nutrient Earth — Screen 09: Personal Details (Stitch Ref: screen_09_personal_details)
// Phase 2: Step 1 of 8. Preferred name input with validation, age stepper control
// with rapid age bracket chips, life-stage metabolic justification, and returnTo support.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class PersonalDetailsScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const PersonalDetailsScreen({super.key, this.returnTo});

  @override
  ConsumerState<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends ConsumerState<PersonalDetailsScreen> {
  late final TextEditingController _nameController;
  late int _age;
  String? _nameError;

  final List<Map<String, dynamic>> _ageBrackets = [
    {'label': '18–24', 'val': 21},
    {'label': '25–34', 'val': 28},
    {'label': '35–44', 'val': 38},
    {'label': '45–54', 'val': 48},
    {'label': '55+', 'val': 60},
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingJourneyProvider);
    _nameController = TextEditingController(text: state.firstName);
    _age = state.age;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter your name or preferred nickname');
      return;
    }

    ref.read(onboardingJourneyProvider.notifier).setPersonalDetails(
      name: name,
      age: _age,
    );

    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/body-measurements');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NETokens.background,
      appBar: AppBar(
        backgroundColor: NETokens.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: NETokens.darkEvergreen),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/onboarding/review-phase1');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 1 OF 9 • SOIL PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Soil Profile Setup',
              style: GoogleFonts.manrope(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: NETokens.darkEvergreen,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainer,
                            borderRadius: BorderRadius.circular(NETokens.radiusFull),
                          ),
                          child: Text(
                            'STAGE 09 • PERSONAL DETAILS',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: NETokens.darkEvergreen,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Let\'s get to know you',
                          style: GoogleFonts.manrope(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'A few basic details will help us personalize your experience.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Name input
                        Text(
                          'What should we call you?',
                          style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'First name, nickname, or preferred name',
                          style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          onChanged: (_) {
                            if (_nameError != null) setState(() => _nameError = null);
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter your preferred name...',
                            hintStyle: GoogleFonts.manrope(fontSize: 14, color: NETokens.textMuted),
                            filled: true,
                            fillColor: Colors.white,
                            errorText: _nameError,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NETokens.borderDefault)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NETokens.borderDefault)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: NETokens.emerald, width: 1.5)),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Age Stepper
                        Text(
                          'How old are you?',
                          style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Helps calibrate metabolic and nutritional life stage baselines',
                          style: GoogleFonts.manrope(fontSize: 12.5, color: NETokens.textSecondary),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: NETokens.borderDefault),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _age > 18 ? () => setState(() => _age--) : null,
                                    icon: const Icon(Icons.remove_circle_outline_rounded, size: 28),
                                    color: NETokens.darkEvergreen,
                                    disabledColor: NETokens.borderDefault,
                                  ),
                                  const SizedBox(width: 24),
                                  Text(
                                    '$_age',
                                    style: GoogleFonts.manrope(fontSize: 36, fontWeight: FontWeight.w800, color: NETokens.darkEvergreen),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'years',
                                    style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: NETokens.textSecondary),
                                  ),
                                  const SizedBox(width: 24),
                                  IconButton(
                                    onPressed: _age < 120 ? () => setState(() => _age++) : null,
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 28),
                                    color: NETokens.darkEvergreen,
                                    disabledColor: NETokens.borderDefault,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                children: _ageBrackets.map((b) {
                                  final label = b['label'] as String;
                                  final val = b['val'] as int;
                                  final isMatch = (_age - val).abs() <= 4;

                                  return ChoiceChip(
                                    label: Text(label),
                                    selected: isMatch,
                                    onSelected: (_) => setState(() => _age = val),
                                    selectedColor: NETokens.darkEvergreen,
                                    backgroundColor: NETokens.surfaceContainerLow,
                                    labelStyle: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: isMatch ? FontWeight.w700 : FontWeight.w500,
                                      color: isMatch ? Colors.white : NETokens.textSecondary,
                                    ),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NETokens.radiusFull)),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Life stage context card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: NETokens.borderDefault),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 20, color: NETokens.botanicalTeal),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Age is used strictly for physiological scaling — such as daily fiber, micronutrient RDAs, and cardiovascular pacing — never for marketing or third-party profiling.',
                                  style: GoogleFonts.manrope(fontSize: 12, color: NETokens.textSecondary, height: 1.45),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // Sticky Bottom Action Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: NETokens.borderDefault)),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _handleContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NETokens.darkEvergreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Continue',
                            style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

