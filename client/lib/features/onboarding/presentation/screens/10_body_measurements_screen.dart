// ==============================================================================
// Nutrient Earth — Screen 10: Body Measurements (Stitch Ref: screen_10_body_measurements)
// Phase 2: Step 2 of 8. Height (ft/in or cm toggle), Weight (lb or kg toggle),
// non-judgmental weight skip option with standard metabolic averaging fallback.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../state/onboarding_journey_state.dart';

class BodyMeasurementsScreen extends ConsumerStatefulWidget {
  final String? returnTo;

  const BodyMeasurementsScreen({super.key, this.returnTo});

  @override
  ConsumerState<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends ConsumerState<BodyMeasurementsScreen> {
  late String _heightUnit; // 'ft' or 'cm'
  late String _weightUnit; // 'lb' or 'kg'
  late bool _weightSkipped;

  late final TextEditingController _feetController;
  late final TextEditingController _inchesController;
  late final TextEditingController _cmController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingJourneyProvider);
    _heightUnit = state.heightUnit;
    _weightUnit = state.weightUnit;
    _weightSkipped = state.weightSkipped;

    final initialCm = state.heightCm ?? 175.0;
    final totalInches = (initialCm / 2.54).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;

    _feetController = TextEditingController(text: feet.toString());
    _inchesController = TextEditingController(text: inches.toString());
    _cmController = TextEditingController(text: initialCm.round().toString());
    _weightController = TextEditingController(
      text: _weightUnit == 'lb'
          ? ((state.weightKg ?? 70.0) * 2.20462).round().toString()
          : (state.weightKg ?? 70.0).round().toString(),
    );
  }

  @override
  void dispose() {
    _feetController.dispose();
    _inchesController.dispose();
    _cmController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    double? calculatedCm;
    if (_heightUnit == 'cm') {
      calculatedCm = double.tryParse(_cmController.text.trim()) ?? 175.0;
    } else {
      final f = double.tryParse(_feetController.text.trim()) ?? 5.0;
      final i = double.tryParse(_inchesController.text.trim()) ?? 9.0;
      calculatedCm = ((f * 12) + i) * 2.54;
    }

    double? calculatedKg;
    if (!_weightSkipped) {
      final w = double.tryParse(_weightController.text.trim()) ?? 70.0;
      calculatedKg = _weightUnit == 'lb' ? (w / 2.20462) : w;
    }

    ref.read(onboardingJourneyProvider.notifier).setBodyMeasurements(
      heightCm: calculatedCm,
      weightKg: calculatedKg,
      heightUnit: _heightUnit,
      weightUnit: _weightUnit,
      weightSkipped: _weightSkipped,
    );

    if (widget.returnTo != null && widget.returnTo!.isNotEmpty) {
      context.go('/onboarding/${widget.returnTo}');
    } else {
      context.go('/onboarding/health-concerns');
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
              context.go('/onboarding/personal-details');
            }
          },
        ),
        title: Column(
          children: [
            Text(
              'STEP 2 OF 9 • SOIL PROFILE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: NETokens.botanicalTeal,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Body Metrics',
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
                            'STAGE 10 • BODY METRICS',
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
                          'Your body measurements',
                          style: GoogleFonts.manrope(
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            color: NETokens.darkEvergreen,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'These help us personalize your daily metabolic baselines and tailored nutrition recommendations.',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            color: NETokens.textSecondary,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Height Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: NETokens.borderDefault),
                            boxShadow: NETokens.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.height_rounded, size: 20, color: NETokens.botanicalTeal),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Height',
                                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                                      ),
                                    ],
                                  ),
                                  // Unit switcher
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: NETokens.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildUnitTab('ft & in', _heightUnit == 'ft', () => setState(() => _heightUnit = 'ft')),
                                        _buildUnitTab('cm', _heightUnit == 'cm', () => setState(() => _heightUnit = 'cm')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (_heightUnit == 'ft') ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _feetController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Feet',
                                          labelStyle: GoogleFonts.manrope(fontSize: 12),
                                          suffixText: 'ft',
                                          suffixStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: NETokens.textSecondary),
                                          filled: true,
                                          fillColor: NETokens.surfaceContainerLow,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextField(
                                        controller: _inchesController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Inches',
                                          labelStyle: GoogleFonts.manrope(fontSize: 12),
                                          suffixText: 'in',
                                          suffixStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: NETokens.textSecondary),
                                          filled: true,
                                          fillColor: NETokens.surfaceContainerLow,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                TextField(
                                  controller: _cmController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Centimeters',
                                    labelStyle: GoogleFonts.manrope(fontSize: 12),
                                    suffixText: 'cm',
                                    suffixStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: NETokens.textSecondary),
                                    filled: true,
                                    fillColor: NETokens.surfaceContainerLow,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Weight Card
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: NETokens.borderDefault),
                            boxShadow: NETokens.cardShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.fitness_center_rounded, size: 20, color: NETokens.botanicalTeal),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Weight',
                                        style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: NETokens.darkEvergreen),
                                      ),
                                    ],
                                  ),
                                  // Unit switcher
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: NETokens.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildUnitTab('lb', _weightUnit == 'lb', () => setState(() => _weightUnit = 'lb')),
                                        _buildUnitTab('kg', _weightUnit == 'kg', () => setState(() => _weightUnit = 'kg')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (!_weightSkipped) ...[
                                TextField(
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: _weightUnit == 'lb' ? 'Pounds' : 'Kilograms',
                                    labelStyle: GoogleFonts.manrope(fontSize: 12),
                                    suffixText: _weightUnit,
                                    suffixStyle: GoogleFonts.jetBrainsMono(fontSize: 12, color: NETokens.textSecondary),
                                    filled: true,
                                    fillColor: NETokens.surfaceContainerLow,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),
                              InkWell(
                                onTap: () => setState(() => _weightSkipped = !_weightSkipped),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _weightSkipped,
                                        activeColor: NETokens.darkEvergreen,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                        onChanged: (val) => setState(() => _weightSkipped = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Prefer to skip weight for now',
                                      style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w500, color: NETokens.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              if (_weightSkipped) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Standard metabolic population averages will be used for your Basal Metabolic Rate (BMR) calculations.',
                                  style: GoogleFonts.manrope(fontSize: 11.5, color: NETokens.textMuted, fontStyle: FontStyle.italic),
                                ),
                              ],
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

  Widget _buildUnitTab(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? NETokens.darkEvergreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : NETokens.textSecondary,
          ),
        ),
      ),
    );
  }
}

