import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/design_system/tokens/ne_tokens.dart';

/// Screen 28: Nutrition Analysis (Macronutrients & Energy)
/// Route: /research/food/nutrition
/// Authoritative Stitch Reference: nutrition_analysis_macronutrients_energy
class NutritionAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic>? initialData;

  const NutritionAnalysisScreen({
    super.key,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    final title = initialData?['title'] as String? ??
        'Pacific Wild Salmon with Quinoa & Broccoli';
    final portionWeight = initialData?['portionWeight'] as String? ?? '380g';

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
              'Nutrition Analysis',
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
              // Stepper Context Header & Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: NETokens.secondaryFixed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: NETokens.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'VERIFIED COMPOSITION • STAGE 3 OF 4',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: NETokens.onSecondaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: NETokens.onSurface,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '1 Prepared Serving ($portionWeight total weight) • Calculated from USDA FoodData Central Ref #173688',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: NETokens.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Visual Dish Specimen Capsule
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: NETokens.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        size: 24,
                        color: NETokens.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'SPECTRAL COMPOSITION',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: NETokens.secondary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: NETokens.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$portionWeight NET',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Wild Sockeye Fillet, Tricolor Quinoa & Steamed Brassica',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: NETokens.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Energy Information Card
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
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: NETokens.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bolt,
                                size: 18,
                                color: NETokens.onSecondaryFixed,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'METABOLIC YIELD',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                                color: NETokens.secondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '2,175 kJ Equiv.',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '520',
                          style: GoogleFonts.manrope(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                            color: NETokens.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'kcal',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Caloric Density',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: NETokens.onSurface,
                          ),
                        ),
                        Text(
                          '1.37 kcal/g',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NETokens.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.48,
                        minHeight: 6,
                        backgroundColor: NETokens.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          NETokens.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Moderate nutrient-dense matrix',
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        color: NETokens.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 14,
                            color: NETokens.secondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Calculated estimate. Natural biological variance ±8%.',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Macronutrient Matrix
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MACRONUTRIENT MATRIX',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: NETokens.onSurface,
                    ),
                  ),
                  Text(
                    'Caloric Share',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      color: NETokens.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Macro Triple Grid
              Row(
                children: [
                  _buildMacroCard(
                    title: 'PROTEIN',
                    amount: '44',
                    pct: '34% kcal',
                    desc: 'High biological amino acids',
                    dotColor: NETokens.primaryContainer,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroCard(
                    title: 'CARBS',
                    amount: '42',
                    pct: '32% kcal',
                    desc: 'Complex polysaccharides',
                    dotColor: NETokens.secondary,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroCard(
                    title: 'LIPIDS',
                    amount: '18',
                    pct: '31% kcal',
                    desc: 'Rich in EPA/DHA Omega-3',
                    dotColor: NETokens.primaryFixed,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Fiber Expansion Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NETokens.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: NETokens.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.grass,
                            size: 18,
                            color: NETokens.primaryContainer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Fiber: 7.2g ',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.onSurface,
                                  ),
                                ),
                                Text(
                                  '(26% DV)',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: NETokens.secondary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '4.8g insoluble • 2.4g soluble',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                color: NETokens.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: NETokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'PREBIOTIC',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Key Micronutrients Overview
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
                              'Key Micronutrients',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: NETokens.onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'ANALYTICAL PEAK',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: NETokens.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.3,
                      children: [
                        _buildMicroItem(
                          'OMEGA-3 FATTY ACIDS',
                          '1,850mg',
                          'EPA / DHA Marine Lipids',
                        ),
                        _buildMicroItem(
                          'VITAMIN D3',
                          '560 IU (70% DV)',
                          'Calciferol Co-factors',
                        ),
                        _buildMicroItem(
                          'POTASSIUM',
                          '820mg (17% DV)',
                          'Cellular Electrolyte',
                        ),
                        _buildMicroItem(
                          'IRON',
                          '3.4mg (19% DV)',
                          'Bioavailable Chelation',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push(
                    '/research/food/assessment',
                    extra: {'title': title},
                  ),
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
                        'Understand this meal',
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
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.tune, size: 16),
                  label: Text(
                    'Adjust portions or ingredients',
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

  Widget _buildMacroCard({
    required String title,
    required String amount,
    required String pct,
    required String desc,
    required Color dotColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NETokens.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: NETokens.secondary,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  amount,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: NETokens.primaryContainer,
                  ),
                ),
                Text(
                  'g',
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: NETokens.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Text(
              pct,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: NETokens.secondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: GoogleFonts.manrope(
                fontSize: 9,
                color: NETokens.onSurfaceVariant,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroItem(String title, String val, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: NETokens.secondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            val,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NETokens.primaryContainer,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              fontSize: 9,
              color: NETokens.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
