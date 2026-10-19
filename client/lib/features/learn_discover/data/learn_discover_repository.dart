import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../domain/learn_discover_models.dart';

final learnDiscoverRepositoryProvider = Provider<LearnDiscoverRepository>((
  ref,
) {
  return LearnDiscoverRepository();
});

final articlesProvider = FutureProvider<List<ArticleItem>>((ref) async {
  final repo = ref.watch(learnDiscoverRepositoryProvider);
  return repo.getArticles();
});

final exerciseRoutinesProvider = FutureProvider<List<ExerciseRoutine>>((
  ref,
) async {
  final repo = ref.watch(learnDiscoverRepositoryProvider);
  return repo.getExerciseRoutines();
});

final storeProductsProvider = FutureProvider<List<ProductItem>>((ref) async {
  final repo = ref.watch(learnDiscoverRepositoryProvider);
  return repo.getStoreProducts();
});

class LearnDiscoverRepository {
  final List<ArticleItem> _articles = [
    ArticleItem(
      id: 'art-01',
      title: 'Zone 2 Cardio & Mitochondrial Density in Healthspan',
      category: 'Cardiorespiratory',
      summary: 'How low-intensity steady-state endurance training increases mitochondrial surface area, fatty acid oxidation, and metabolic flexibility.',
      content: 'Mitochondria are the primary metabolic organelles in human cells. Zone 2 training—defined as exercise intensity where lactate clearance matches lactate production (typically 1.5–2.0 mmol/L blood lactate)—maximizes fat oxidation and stimulates peroxisome proliferator-activated receptor gamma coactivator 1-alpha (PGC-1α). Longitudinal studies show that maintaining aerobic fitness in the top quartile reduces all-cause mortality hazard by up to 50% compared to bottom-quartile individuals.',
      readingTimeMinutes: 6,
      evidenceScore: 94,
      primarySourceCitation: 'San-Millán I, Brooks GA. Assessment of Metabolic Flexibility and Mitochondrial Function. Sports Med. 2018;48(2):467-479.',
      isPeerReviewed: true,
      publishedDate: DateTime(2026, 2, 14),
      keyTakeaways: [
        'Zone 2 corresponds to a conversational pace where breathing is rhythmic but speech remains unbroken.',
        'Volume target: 150 to 180 minutes weekly divided across 3 to 4 sessions.',
        'Improves metabolic clearance of triglycerides and circulating fasting blood glucose.',
      ],
    ),
    ArticleItem(
      id: 'art-02',
      title: 'Evidence-Based Micronutrient Timing: Vitamin D3 & Magnesium',
      category: 'Nutrition',
      summary: 'The biochemical synergy between magnesium availability and 25-hydroxyvitamin D 1-alpha-hydroxylase enzymatic activation.',
      content: 'All enzymes that metabolize vitamin D appear to require magnesium, which acts as a cofactor in the enzymatic reactions in the liver and kidneys. Individuals with suboptimal magnesium intake may experience diminished calcitriol synthesis despite high-dose cholecalciferol supplementation. Co-administration of magnesium glycinate or citrate with fat-soluble vitamin D3 taken with morning or midday meals optimizes serum 25(OH)D levels while supporting sleep architecture.',
      readingTimeMinutes: 5,
      evidenceScore: 89,
      primarySourceCitation: 'Uwitonze AM, Razzaque MS. Role of Magnesium in Vitamin D Activation and Function. J Am Osteopath Assoc. 2018;118(3):181-189.',
      isPeerReviewed: true,
      publishedDate: DateTime(2026, 3, 22),
      keyTakeaways: [
        'Magnesium acts as an obligate cofactor for hepatic 25-hydroxylation.',
        'Take Vitamin D3 with a meal containing dietary lipids (avocado, olive oil, eggs) to maximize micellar absorption.',
        'Target serum 25(OH)D between 40–60 ng/mL for non-skeletal physiological optimization.',
      ],
    ),
    ArticleItem(
      id: 'art-03',
      title: 'Circadian Light Hygiene: Adenosine, Melatonin, and Core Body Temperature',
      category: 'Sleep',
      summary: 'Quantifying the biological impact of 10,000 lux morning photon exposure versus evening blue-spectrum light suppression.',
      content: 'Intrinsically photosensitive retinal ganglion cells (ipRGCs) expressing melanopsin entrain the suprachiasmatic nucleus (SCN). Morning sunlight exposure within 45 minutes of waking advances the circadian phase, triggers early daytime cortisol release, and anchors the nocturnal melatonin onset approximately 14–16 hours later.',
      readingTimeMinutes: 7,
      evidenceScore: 96,
      primarySourceCitation: 'Blume C, Garbazza C, Spitschan M. Effects of light on human circadian rhythms, sleep and mood. Somnologie. 2019;23(3):147-156.',
      isPeerReviewed: true,
      publishedDate: DateTime(2026, 4, 10),
      keyTakeaways: [
        'Aim for 10–20 minutes of natural outdoor sunlight within 1 hour of rising.',
        'Dim ambient overhead lighting 2 hours before bed; switch to warm (2200K) spectrum.',
        'Cool bedroom temperatures (18°C) assist the required 1°C drop in core body temperature for deep N3 sleep.',
      ],
    ),
  ];

  final List<ExerciseRoutine> _routines = [
    const ExerciseRoutine(
      id: 'ex-01',
      name: 'Zone 2 Base Aerobic Conditioning',
      targetGoal: 'Endurance & Mitochondrial Density',
      difficultyLevel: 'Beginner to Intermediate',
      durationMinutes: 45,
      equipmentNeeded: [
        'Stationary Bike, Treadmill, or Outdoor Trail',
        'Heart Rate Monitor',
      ],
      movements: [
        ExerciseMovement(
          name: 'Dynamic Joint Mobility Warm-Up',
          targetMuscle: 'Full Body Mobility',
          repsOrDuration: '5 Minutes',
          coachingCue: 'Leg swings, thoracic rotations, ankle circles.',
        ),
        ExerciseMovement(
          name: 'Steady-State Zone 2 Cardio',
          targetMuscle: 'Cardiorespiratory / Slow-twitch Type I Fibers',
          repsOrDuration: '35 Minutes',
          coachingCue: 'Maintain breathing pace where nose-only breathing is sustainable. Heart rate between 65-72% HRmax.',
        ),
        ExerciseMovement(
          name: 'Parasympathetic Cool-Down',
          targetMuscle: 'Vagal Tone Recovery',
          repsOrDuration: '5 Minutes',
          coachingCue:
              'Slow walking followed by 4-7-8 physiological box breathing.',
        ),
      ],
      injuryModifications: 'If joint impact is a concern, substitute running with low-impact rowing, elliptical, or cycling with zero knee shear.',
      scientificRationale: 'Sustained continuous aerobic flux induces capillary angiogenesis in skeletal muscle and upregulates fat oxidation enzymes.',
    ),
    const ExerciseRoutine(
      id: 'ex-02',
      name: 'Posterior Chain & Bone Mineral Density Protocol',
      targetGoal: 'Musculoskeletal Integrity & Posture',
      difficultyLevel: 'Intermediate',
      durationMinutes: 35,
      equipmentNeeded: ['Dumbbells or Kettlebells', 'Resistance Bands'],
      movements: [
        ExerciseMovement(
          name: 'Romanian Deadlift (Hinge)',
          targetMuscle: 'Hamstrings, Gluteus Maximus, Erector Spinae',
          repsOrDuration: '3 Sets x 10 Reps',
          coachingCue: 'Soft knees, push hips back to the rear wall, maintain neutral lumbar spine.',
        ),
        ExerciseMovement(
          name: 'Chest-Supported Dumbbell Row',
          targetMuscle: 'Rhomboids, Latissimus Dorsi, Posterior Deltoid',
          repsOrDuration: '3 Sets x 12 Reps',
          coachingCue: 'Lead with the elbows, pause for 1 second at full scapular retraction.',
        ),
        ExerciseMovement(
          name: 'Goblet Squat with Isometric Pause',
          targetMuscle: 'Quadriceps, Core Stabilizers',
          repsOrDuration: '3 Sets x 8 Reps (2s pause)',
          coachingCue: 'Drive knees over toes tracking inline, brace intra-abdominal pressure.',
        ),
      ],
      injuryModifications: 'For lower back sensitivity, elevate dumbbells on blocks or perform single-leg split squats with bodyweight.',
      scientificRationale: 'Axial loading promotes osteoblast bone remodeling and preserves lean muscle mass essential for glucose clearance.',
    ),
  ];

  final List<ProductItem> _products = [
    const ProductItem(
      id: 'prd-01',
      name: 'Nutrient Earth Ultra Pure Omega-3 EPA/DHA',
      category: 'Supplements',
      price: 38.00,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 342,
      summary: 'Triple molecularly distilled triglyceride-form fish oil providing 1200mg EPA and 600mg DHA per serving.',
      verifiedSpecs: [
        'Total Omega-3: 2000mg per serving',
        'Heavy Metals: Undetectable (<0.005 ppm lead/mercury)',
        'TOTOX (Oxidation) Value: < 4.2 (well below IFOS standard of 26)',
      ],
      thirdPartyCert: 'IFOS 5-Star Certified & NSF Certified for Sport',
      ingredientsOrComponents: [
        'Wild Alaskan Pollock Oil (Triglyceride Form)',
        'Non-GMO Mixed Tocopherols',
        'Enteric Softgel (Bovine Gelatin, Glycerin, Water)',
      ],
      transparentPricingBreakdown: 'Raw Sourcing & Wild Extraction: \$14.20 | Molecular Distillation & Lab Testing: \$8.40 | Packaging & Distribution: \$5.40 | Margin: \$10.00',
    ),
    const ProductItem(
      id: 'prd-02',
      name: 'Chewable Magnesium Bisglycinate Chelate',
      category: 'Supplements',
      price: 26.50,
      currency: 'USD',
      rating: 4.8,
      reviewCount: 218,
      summary: 'Fully reacted TRAACS magnesium bisglycinate with superior intestinal tolerability and zero laxative effect.',
      verifiedSpecs: [
        'Elemental Magnesium: 200mg per serving',
        'Purity Assay: 99.4% bisglycinate chelate bond confirmation',
        'Zero artificial sweeteners, stearates, or titanium dioxide',
      ],
      thirdPartyCert: 'USP Verified & Labdoor Quality A+',
      ingredientsOrComponents: [
        'TRAACS Magnesium Bisglycinate Chelate',
        'Organic Acacia Gum',
        'Vegetable Capsule Shell',
      ],
      transparentPricingBreakdown: 'Patented TRAACS Raw Chelate: \$9.80 | Third-Party Assay Verification: \$4.50 | Packaging: \$3.20 | Margin: \$9.00',
    ),
    const ProductItem(
      id: 'prd-03',
      name: 'At-Home Comprehensive Metabolic Panel Kit',
      category: 'Diagnostics',
      price: 119.00,
      currency: 'USD',
      rating: 4.9,
      reviewCount: 185,
      summary: 'CLIA-certified capillary blood test covering HbA1c, hs-CRP, fasting lipid sub-fractions (ApoB), and vitamin D3.',
      verifiedSpecs: [
        'Analytes: 14 Key Cardiovascular and Metabolic Markers',
        'Lab Accreditation: CAP & CLIA Certified Laboratory',
        'Pre-paid Express Cold-Chain Return Shipping Included',
      ],
      thirdPartyCert: 'CAP & CLIA Lab Validated',
      ingredientsOrComponents: [
        'Microtainer Collection Tubes',
        'Safety Lancets (21G)',
        'Biohazard Return Bag with Desiccant',
      ],
      transparentPricingBreakdown: 'Clinical Diagnostic Assay Fee: \$62.00 | Medical Director Review: \$18.00 | Cold-Chain Logistics: \$16.00 | Margin: \$23.00',
    ),
  ];

  Future<List<ArticleItem>> getArticles() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client.from('learn_content').select();
        if (res.isNotEmpty) {
          return (res as List)
              .map((e) => ArticleItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }
    return _articles;
  }

  Future<List<ExerciseRoutine>> getExerciseRoutines() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client.from('exercise_routines').select();
        if (res.isNotEmpty) {
          return (res as List)
              .map((e) => ExerciseRoutine.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }
    return _routines;
  }

  Future<List<ProductItem>> getStoreProducts() async {
    final client = SupabaseConfig.client;
    if (client != null) {
      try {
        final res = await client.from('store_products').select();
        if (res.isNotEmpty) {
          return (res as List)
              .map((e) => ProductItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }
    return _products;
  }
}
