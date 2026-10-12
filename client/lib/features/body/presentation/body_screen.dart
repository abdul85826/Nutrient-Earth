import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';

class PhysiologicalSystem {
  final String title;
  final String iconName;
  final IconData icon;
  final String physiologySummary;
  final List<String> referenceBiomarkers;
  final List<String> nutritionalSubstrates;
  final String researchQuery;

  const PhysiologicalSystem({
    required this.title,
    required this.iconName,
    required this.icon,
    required this.physiologySummary,
    required this.referenceBiomarkers,
    required this.nutritionalSubstrates,
    required this.researchQuery,
  });
}

const List<PhysiologicalSystem> kPhysiologicalSystems = [
  PhysiologicalSystem(
    title: 'Cardiovascular & Endothelial Axis',
    iconName: 'Heart',
    icon: Icons.favorite_border_rounded,
    physiologySummary:
        'Governs systemic hemodynamics, vascular tone, and endothelial nitric oxide synthase (eNOS) kinetics. Endothelial health preserves arterial compliance and microvascular capillary perfusion.',
    referenceBiomarkers: [
      'Apolipoprotein B (ApoB): < 80 mg/dL',
      'High-Sensitivity C-Reactive Protein (hs-CRP): < 1.0 mg/L',
      'Resting Blood Pressure: < 120/80 mmHg',
    ],
    nutritionalSubstrates: [
      'Dietary nitrates (arginine / citrulline pathway)',
      'Potassium & Magnesium (vascular smooth muscle tone)',
      'Omega-3 EPA/DHA (endothelial cell membrane fluidity)',
    ],
    researchQuery:
        'Endothelial nitric oxide synthase vascular compliance dietary nitrates',
  ),
  PhysiologicalSystem(
    title: 'Metabolic & Hepatic Network',
    iconName: 'Metabolic',
    icon: Icons.bubble_chart_outlined,
    physiologySummary:
        'Regulates substrate partitioning between lipid oxidation and carbohydrate glycolysis. Hepatic glycogen turnover, gluconeogenesis, and peripheral insulin sensitivity drive energy homeostasis.',
    referenceBiomarkers: [
      'Fasting Plasma Glucose: 70–99 mg/dL',
      'Hemoglobin A1c (HbA1c): < 5.7%',
      'Fasting Triglycerides: < 150 mg/dL (optimal < 100 mg/dL)',
    ],
    nutritionalSubstrates: [
      'Fermentable soluble fiber (beta-glucan & psyllium)',
      'Alpha-lipoic acid & Chromium (insulin receptor sensitivity)',
      'Choline & Betaine (hepatic methyl donor pathway)',
    ],
    researchQuery:
        'Insulin sensitivity hepatic glycogen flux mitochondrial oxidative capacity',
  ),
  PhysiologicalSystem(
    title: 'Neuro-Endocrine & Circadian Axis',
    iconName: 'Neural',
    icon: Icons.wb_sunny_outlined,
    physiologySummary:
        'Coordinates hypothalamic-pituitary-adrenal (HPA) dynamics and central biological clock synchronization in the suprachiasmatic nucleus. Regulates diurnal cortisol curve and pineal melatonin synthesis.',
    referenceBiomarkers: [
      'Diurnal Salivary / Serum Cortisol: Peak within 30 min of waking',
      'Thyroid-Stimulating Hormone (TSH): 0.5–2.5 mIU/L',
      'Restorative Deep (Slow-Wave) Sleep Architecture',
    ],
    nutritionalSubstrates: [
      'L-Theanine (neurotransmitter balance & glutamate antagonism)',
      'Pyridoxal-5-Phosphate (Vitamin B6 - GABA synthesis cofactor)',
      'Glycine & Magnesium Bisglycinate (neural cooling & NMDA moderation)',
    ],
    researchQuery:
        'Circadian neuroendocrine regulation cortisol awakening response melatonin',
  ),
  PhysiologicalSystem(
    title: 'Musculoskeletal & Connective Tissue',
    iconName: 'Muscle',
    icon: Icons.fitness_center_rounded,
    physiologySummary:
        'Maintains contractile myofibrillar protein synthesis, osteoblast mineral deposition, and extracellular collagen triple-helix crosslinking across tendons and ligaments.',
    referenceBiomarkers: [
      'Serum 25(OH) Vitamin D: 30–50 ng/mL (optimal 40–60 ng/mL)',
      'Serum Total Calcium: 8.5–10.2 mg/dL',
      'Serum Creatine Kinase (CK): Basal recovery benchmark',
    ],
    nutritionalSubstrates: [
      'Essential Amino Acids (Leucine-rich complete protein ≥ 1.6g/kg)',
      'Vitamin D3 + K2 (MK-7 for osteocalcin carboxylation)',
      'Hydrolyzed Collagen Peptides + Vitamin C (hydroxyproline synthesis)',
    ],
    researchQuery:
        'Myofibrillar protein synthesis mechanical load leucine threshold',
  ),
  PhysiologicalSystem(
    title: 'Gastrointestinal & Mucosal Barrier',
    iconName: 'Barrier',
    icon: Icons.shield_outlined,
    physiologySummary:
        'Protects host internal milieu via tight junction proteins (claudin, occludin, zonula occludens). Ferments prebiotic substrates into trophic short-chain fatty acids (butyrate, acetate, propionate).',
    referenceBiomarkers: [
      'Fecal Calprotectin: < 50 μg/g (mucosal inflammation absence)',
      'Serum Albumin: 3.5–5.0 g/dL (visceral protein synthesis)',
    ],
    nutritionalSubstrates: [
      'L-Glutamine (primary fuel substrate for enterocytes)',
      'Zinc L-Carnosine (mucosal membrane stabilization)',
      'Prebiotic Inulin & Acacia fiber (bifidogenic microbiome support)',
    ],
    researchQuery:
        'Intestinal mucosal barrier tight junction integrity short chain fatty acids',
  ),
];

class BodyScreen extends ConsumerWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: NeTokens.warmIvory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(NeTokens.spacing20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Physiological Systems',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySerif,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                      SizedBox(height: NeTokens.spacing4),
                      Text(
                        'Evidence-based human physiology, clinical reference intervals, and nutritional substrates.',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 13,
                          color: NeTokens.slateMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Account & Data Rights',
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: NeTokens.deepForest,
                  ),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
            const SizedBox(height: NeTokens.spacing16),

            // Honest Clinical Transparency Alert
            Container(
              padding: const EdgeInsets.all(NeTokens.spacing12),
              decoration: BoxDecoration(
                color: NeTokens.pureWhite,
                borderRadius: BorderRadius.circular(NeTokens.radius12),
                border: Border.all(color: NeTokens.sandDune),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: NeTokens.botanicalEvergreen,
                    size: 20,
                  ),
                  SizedBox(width: NeTokens.spacing10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Zero Synthetic Scores Policy',
                          style: TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: NeTokens.deepForest,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Nutrient Earth never fabricates artificial organ percentages or automated diagnoses. Below is peer-reviewed educational systems biology. Diagnostic interpretation requires a licensed medical physician.',
                          style: TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 11,
                            color: NeTokens.slateMuted,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: NeTokens.spacing20),

            ...kPhysiologicalSystems.map(
              (sys) => Padding(
                padding: const EdgeInsets.only(bottom: NeTokens.spacing16),
                child: NeCard(
                  padding: const EdgeInsets.all(NeTokens.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(NeTokens.spacing8),
                            decoration: BoxDecoration(
                              color: NeTokens.mossGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                NeTokens.radius8,
                              ),
                            ),
                            child: Icon(
                              sys.icon,
                              color: NeTokens.botanicalEvergreen,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: NeTokens.spacing12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sys.title,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: NeTokens.deepForest,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Telemetry: No Live Sensor Linked',
                                  style: TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 11,
                                    color: NeTokens.slateMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeTokens.spacing12),

                      Text(
                        sys.physiologySummary,
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 12,
                          color: NeTokens.slateMuted,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: NeTokens.spacing12),

                      // Standard Clinical Reference Ranges
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(NeTokens.spacing10),
                        decoration: BoxDecoration(
                          color: NeTokens.sandDune.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(NeTokens.radius8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Standard Clinical Reference Intervals:',
                              style: TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: NeTokens.deepForest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...sys.referenceBiomarkers.map(
                              (b) => Text(
                                '• $b',
                                style: const TextStyle(
                                  fontFamily: NeTokens.fontFamilySans,
                                  fontSize: 11,
                                  color: NeTokens.deepForest,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: NeTokens.spacing10),

                      // Nutritional Substrates
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Primary Nutritional Substrates:',
                            style: TextStyle(
                              fontFamily: NeTokens.fontFamilySans,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: NeTokens.mossGreen,
                            ),
                          ),
                          const SizedBox(height: 3),
                          ...sys.nutritionalSubstrates.map(
                            (s) => Text(
                              '✓ $s',
                              style: const TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 11,
                                color: NeTokens.slateMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeTokens.spacing12),

                      InkWell(
                        onTap: () {
                          context.push(
                            '/research?q=${Uri.encodeComponent(sys.researchQuery)}',
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.biotech_outlined,
                              size: 14,
                              color: NeTokens.botanicalEvergreen,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Explore Mechanisms in Ask Workspace →',
                              style: TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: NeTokens.botanicalEvergreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
