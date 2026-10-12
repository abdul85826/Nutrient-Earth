import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';

class FormulationBenchmark {
  final String title;
  final String formulationSummary;
  final String activeConstituents;
  final String certification;
  final bool isThirdPartyVerified;
  final String unverifiedNotice;
  final String allergenDisclosure;
  final List<String> compositionHighlights;
  final String researchQuery;

  const FormulationBenchmark({
    required this.title,
    required this.formulationSummary,
    required this.activeConstituents,
    required this.certification,
    required this.isThirdPartyVerified,
    this.unverifiedNotice = '',
    required this.allergenDisclosure,
    required this.compositionHighlights,
    required this.researchQuery,
  });
}

const List<FormulationBenchmark> kCuratedFormulations = [
  FormulationBenchmark(
    title: 'Pea & Brown Rice Protein Isolate',
    formulationSummary:
        'Cold-water processed complementary plant protein matrix yielding an essential amino acid profile equivalent to whey.',
    activeConstituents: '24g Complete Protein • 2.8g Leucine • PDCAAS 1.0',
    certification: 'NSF Certified for Sport®',
    isThirdPartyVerified: true,
    allergenDisclosure:
        'Allergens: Free from dairy, soy, gluten, and artificial sweeteners/gums.',
    compositionHighlights: [
      'Cold-water mechanical extraction without hexane solvents',
      'Leucine threshold met for mTOR activation (2.8g/serving)',
      'Heavy metal screened (Lead < 0.1 ppm, Cadmium < 0.05 ppm)',
    ],
    researchQuery:
        'Plant protein isolate pea rice amino acid kinetics myofibrillar synthesis',
  ),
  FormulationBenchmark(
    title: 'Magnesium Bisglycinate Chelate',
    formulationSummary:
        'Fully reacted bisglycinate chelate bonded to two glycine molecules for high mucosal absorption via dipeptide pathways.',
    activeConstituents: '200 mg Elemental Mg per serving (TRAACS® chelated)',
    certification: 'USP Verified™ & Non-GMO Project',
    isThirdPartyVerified: true,
    allergenDisclosure:
        'Allergens: Hypoallergenic vegetable cellulose capsule, zero magnesium stearate.',
    compositionHighlights: [
      'Chelated to two glycine amino acids, protecting from gastric acid ionization',
      'Minimal osmotic laxative effect compared to magnesium oxide/citrate',
      'Assayed by HPLC to confirm 100% chelation integrity',
    ],
    researchQuery:
        'Magnesium bisglycinate chelate TRAACS bioavailability intestinal transport',
  ),
  FormulationBenchmark(
    title: 'Liposomal Vitamin D3 + K2 (MK-7)',
    formulationSummary:
        'Phospholipid micro-encapsulated cholecalciferol combined with all-trans menaquinone-7 to facilitate proper calcium deposition.',
    activeConstituents: '5,000 IU D3 (125 mcg) • 100 mcg K2 (all-trans MK-7)',
    certification: 'ISO/IEC 17025 Third-Party Lab Assayed',
    isThirdPartyVerified: true,
    allergenDisclosure:
        'Allergens: Contains non-GMO sunflower lecithin phospholipids.',
    compositionHighlights: [
      'Liposomal delivery shields fat-soluble vitamins through gastric transit',
      'Menaquinone-7 in 99%+ all-trans bioactive isomer',
      'Synergistic matrix: activates matrix Gla protein and osteocalcin',
    ],
    researchQuery:
        'Vitamin D3 and vitamin K2 MK-7 osteocalcin matrix Gla protein vascular calcification',
  ),
  FormulationBenchmark(
    title: 'Wild Alaskan Omega-3 Triglycerides',
    formulationSummary:
        'Molecularly distilled re-esterified triglyceride (rTG) marine oil offering superior bioavailability over synthetic ethyl esters.',
    activeConstituents: '800 mg EPA • 400 mg DHA per softgel',
    certification: 'IFOS 5-Star Certified (TOTOX < 5)',
    isThirdPartyVerified: true,
    allergenDisclosure:
        'Allergens: Contains purified fish oil (Wild Alaskan Pollock).',
    compositionHighlights: [
      'Re-esterified triglyceride form (rTG) for 70% higher absorption efficiency',
      'Certified ultra-low oxidation index (Total Oxidation / TOTOX score < 5)',
      'Sustainably harvested MSC-certified wild Alaskan fishery',
    ],
    researchQuery:
        'Re-esterified triglyceride omega-3 EPA DHA endothelial function lipid profile',
  ),
  FormulationBenchmark(
    title: 'Fermented Prebiotic Inulin & Acacia',
    formulationSummary:
        'Slow-fermenting prebiotic soluble polysaccharide designed to feed beneficial distal colon bifidobacteria.',
    activeConstituents: '7g Prebiotic Soluble Fiber per serving',
    certification: 'Pending Certificate of Analysis',
    isThirdPartyVerified: false,
    unverifiedNotice:
        'Third-party heavy metal assay and microbiological CoA are currently pending publisher validation. Verification will be updated upon receipt of independent lab documentation.',
    allergenDisclosure:
        'Allergens: Pure plant fiber, zero grain, gluten, or dairy derivatives.',
    compositionHighlights: [
      'Acacia fiber fermentability generates trophic short-chain fatty acids',
      'Low gas/bloating profile relative to rapidly fermenting short-chain FOS',
      '100% water-soluble neutral dissolution',
    ],
    researchQuery:
        'Acacia fiber inulin microbiome short chain fatty acids bifidogenic index',
  ),
];

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

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
                        'Formulation Catalog',
                        style: TextStyle(
                          fontFamily: NeTokens.fontFamilySerif,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: NeTokens.deepForest,
                        ),
                      ),
                      SizedBox(height: NeTokens.spacing4),
                      Text(
                        'Transparent ingredient quantities, laboratory assay certificates, and research mechanism links.',
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

            // Honest Non-Commercial Neutrality Notice
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
                    Icons.verified_outlined,
                    color: NeTokens.botanicalEvergreen,
                    size: 20,
                  ),
                  SizedBox(width: NeTokens.spacing10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Non-Commercial Research Neutrality',
                          style: TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: NeTokens.deepForest,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Direct commercial checkout and in-app purchasing are intentionally disabled. Nutrient Earth accepts no affiliate commissions or sponsored brand placements. Below are objective reference formulations with verifiable assay standards.',
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

            ...kCuratedFormulations.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: NeTokens.spacing16),
                child: NeCard(
                  padding: const EdgeInsets.all(NeTokens.spacing16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: NeTokens.deepForest,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.activeConstituents,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 12,
                                    color: NeTokens.mossGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: item.isThirdPartyVerified
                                  ? NeTokens.mossGreen.withValues(alpha: 0.15)
                                  : NeTokens.amberWarning.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(
                                NeTokens.radius6,
                              ),
                            ),
                            child: Text(
                              item.isThirdPartyVerified
                                  ? '✓ Verified'
                                  : '⚠ Pending Assay',
                              style: TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: item.isThirdPartyVerified
                                    ? NeTokens.botanicalEvergreen
                                    : NeTokens.amberWarning,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: NeTokens.spacing8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: NeTokens.sandDune.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(NeTokens.radius6),
                        ),
                        child: Text(
                          'Certification: ${item.certification}',
                          style: const TextStyle(
                            fontFamily: NeTokens.fontFamilySans,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: NeTokens.deepForest,
                          ),
                        ),
                      ),
                      const SizedBox(height: NeTokens.spacing10),

                      Text(
                        item.formulationSummary,
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 12,
                          color: NeTokens.slateMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: NeTokens.spacing10),

                      if (!item.isThirdPartyVerified &&
                          item.unverifiedNotice.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(
                            bottom: NeTokens.spacing10,
                          ),
                          padding: const EdgeInsets.all(NeTokens.spacing8),
                          decoration: BoxDecoration(
                            color: NeTokens.amberWarning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              NeTokens.radius8,
                            ),
                            border: Border.all(
                              color: NeTokens.amberWarning.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: NeTokens.amberWarning,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.unverifiedNotice,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 11,
                                    color: NeTokens.deepForest,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Composition Details
                      ...item.compositionHighlights.map(
                        (feat) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check,
                                size: 13,
                                color: NeTokens.mossGreen,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  feat,
                                  style: const TextStyle(
                                    fontFamily: NeTokens.fontFamilySans,
                                    fontSize: 11,
                                    color: NeTokens.slateMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: NeTokens.spacing8),

                      // Allergen Notice
                      Text(
                        item.allergenDisclosure,
                        style: const TextStyle(
                          fontFamily: NeTokens.fontFamilySans,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: NeTokens.slateMuted,
                        ),
                      ),
                      const SizedBox(height: NeTokens.spacing12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              context.push(
                                '/research?q=${Uri.encodeComponent(item.researchQuery)}',
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
                                  'Research Evidence in Ask →',
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: NeTokens.sandDune.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(
                                NeTokens.radius6,
                              ),
                            ),
                            child: const Text(
                              'Checkout Disabled',
                              style: TextStyle(
                                fontFamily: NeTokens.fontFamilySans,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: NeTokens.slateMuted,
                              ),
                            ),
                          ),
                        ],
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
