import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 29: Meal Assessment (Strengths, Limitations & Actions)
/// Route: /research/food/assessment
/// Authoritative Stitch Reference: meal_assessment_strengths_limitations_actions
class MealAssessmentScreen extends StatelessWidget {
  final Map<String, dynamic>? initialData;

  const MealAssessmentScreen({
    super.key,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final title = initialData?['title'] as String? ??
        'Pacific Wild Salmon with Quinoa & Broccoli (380g)';

    return Scaffold(
      backgroundColor: NETokens.surface,
      appBar: AppBar(
        backgroundColor: NETokens.surface.withValues(alpha: 0.85),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: NETokens.onSurface),
          onPressed: () => context.pop(),
          tooltip: 'Navigate back',
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.eco, size: 20, color: NETokens.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Meal Assessment',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NETokens.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: NETokens.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: NETokens.onPrimary, size: 18),
            ),
            onPressed: () => context.push('/profile/context'),
            tooltip: 'Account profile',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Specimen Context Meta Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NETokens.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'STEP 04 // EVIDENCE-BASED SYNTHESIS',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                  ),
                  Text(
                    'SPECIMEN #380G-PAC',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: NETokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: NETokens.onSurface,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 16),

              // Narrative Prompt
              Text(
                'What does this meal tell you?',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore its nutritional strengths, limitations, and possible adjustments in context.',
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Assessment Synthesis Dossier Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.biotech,
                              size: 18,
                              color: NETokens.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SYNTHESIS READOUT',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CALIBRATED',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'High-protein, micronutrient-dense meal with favorable anti-inflammatory lipid profile. Balanced glycemic index supported by intact quinoa fiber.',
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        color: NETokens.onSurface,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bioavailability spectrum indicators
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'BIOAVAILABILITY SPECTRUM',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: NETokens.secondary,
                                ),
                              ),
                              Text(
                                'OPTIMAL SYNERGY',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: NETokens.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: const LinearProgressIndicator(
                              value: 0.94,
                              minHeight: 6,
                              backgroundColor: NETokens.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                NETokens.secondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '44g Amino Mass',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '1.8g EPA/DHA',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Fiber & Phytonutrients',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: NETokens.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Nutritional Strengths Module
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: NETokens.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'NUTRITIONAL STRENGTHS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: NETokens.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '3 DETECTED',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Strength 1
              _buildCard(
                title: 'Complete Protein Profile (44g)',
                icon: Icons.fitness_center,
                body:
                    'Contains all 9 essential amino acids with high bioavailability for skeletal muscle protein synthesis.',
                tags: ['LEUCINE 3.6g', 'DIAAS 1.28'],
              ),
              const SizedBox(height: 10),

              // Strength 2
              _buildCard(
                title: 'Marine Omega-3 Polyunsaturates',
                icon: Icons.water_drop,
                body:
                    '1.8g EPA/DHA supporting cardiovascular endothelia and cellular membrane fluidity.',
                tags: ['EPA: 0.8g', 'DHA: 1.0g'],
              ),
              const SizedBox(height: 10),

              // Strength 3
              _buildCard(
                title: 'Cruciferous Glucosinolates',
                icon: Icons.eco,
                body:
                    'Broccoli sulforaphane precursors providing antioxidant response pathway stimulation.',
                tags: ['NRF2 ACTIVATION', 'MYROSINASE +'],
              ),
              const SizedBox(height: 20),

              // Relevant Limitations & Unknowns
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.help_outline,
                        size: 16,
                        color: NETokens.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'RELEVANT LIMITATIONS & UNKNOWNS',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: NETokens.secondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'UNCERTAINTY BOUNDS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: NETokens.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Limitation 1
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sodium & Seasoning Uncertainty',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NETokens.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ESTIMATED',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preparation seasonings and sodium levels unmeasured. Sodium estimated at ~320mg baseline.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Limitation 2
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Absence of Specific Fermented Microbes',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NETokens.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: NETokens.surface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'GAP',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: NETokens.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Meal provides prebiotic fibers but lacks active probiotic cultures for gut microbiome colonization.',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: NETokens.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Practical Improvements
              Row(
                children: [
                  const Icon(
                    Icons.tune,
                    size: 16,
                    color: NETokens.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PRACTICAL IMPROVEMENTS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: NETokens.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              _buildImprovementItem(
                '01',
                'Add a fermented botanical side (e.g. kimchi or kraut) to introduce lactobacilli alongside the fiber matrix.',
              ),
              const SizedBox(height: 8),
              _buildImprovementItem(
                '02',
                'Incorporate leafy dark greens (spinach, arugula) to elevate folate and lutein retention.',
              ),
              const SizedBox(height: 24),

              // Actions: Turn into Goal
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    context.push(
                      '/goals/create',
                      extra: {
                        'title': 'Optimize Weekly Salmon & Fermented Foods',
                        'category': 'Nutrition',
                        'outcome':
                            'Incorporate wild omega-3 and fermented side with evening meal 3 times a week.',
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.primaryContainer,
                    foregroundColor: NETokens.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Turn into a goal',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton.icon(
                  onPressed: () => context.go('/research'),
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: Text(
                    'Back to Research Home',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NETokens.secondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required String body,
    required List<String> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSurface,
                ),
              ),
              Icon(icon, size: 18, color: NETokens.secondary),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: NETokens.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: tags.map((t) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: NETokens.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  t,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: NETokens.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImprovementItem(String number, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: NETokens.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: NETokens.onSecondaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: NETokens.onSurface,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
