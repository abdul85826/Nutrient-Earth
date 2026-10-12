import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';

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
            const Text(
              'Verified Clean Store',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySerif,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: NeTokens.deepForest,
              ),
            ),
            const SizedBox(height: NeTokens.spacing6),
            const Text(
              'Third-party lab assayed formulations. Zero artificial emulsifiers, heavy metals screened, 100% bioavailable.',
              style: TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 13,
                color: NeTokens.slateMuted,
              ),
            ),
            const SizedBox(height: NeTokens.spacing20),

            _buildProductCard(
              context,
              title: 'Pure Pea Protein Isolate (Organic)',
              dosage: '82% Protein Bioavailability (PDCAAS 0.93)',
              certification: 'NSF Certified for Sport®',
              price: '\$38.00',
              query: 'Pea proteins oral supplementation Babault 2015',
              features: ['Cold-water extraction', 'Full amino acid profile (2.7g Leucine)', 'Zero stevia / gums'],
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildProductCard(
              context,
              title: 'Magnesium Bisglycinate Chelate',
              dosage: '200 mg Elemental Mg / serving',
              certification: 'USP Verified™ & Non-GMO',
              price: '\$24.00',
              query: 'Magnesium dietary reference values EFSA',
              features: ['Chelated to glycine for mucosal absorption', 'Zero laxative effect', 'Gastric gentle'],
            ),
            const SizedBox(height: NeTokens.spacing12),

            _buildProductCard(
              context,
              title: 'Liposomal Vitamin D3 + K2 (MK-7)',
              dosage: '5000 IU D3 + 100 mcg K2',
              certification: 'Third-Party HPLC Assayed',
              price: '\$29.00',
              query: 'Vitamin D endocrine society clinical practice guideline',
              features: ['Phospholipid delivery matrix', 'Menaquinone-7 (all-trans)', 'Optimizes calcium routing'],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required String title,
    required String dosage,
    required String certification,
    required String price,
    required String query,
    required List<String> features,
  }) {
    return NeCard(
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
                      title,
                      style: const TextStyle(
                        fontFamily: NeTokens.fontFamilySans,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: NeTokens.deepForest,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dosage,
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
              Text(
                price,
                style: const TextStyle(
                  fontFamily: NeTokens.fontFamilySerif,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: NeTokens.deepForest,
                ),
              ),
            ],
          ),
          const SizedBox(height: NeTokens.spacing8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: NeTokens.sandDune.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(NeTokens.radius6),
            ),
            child: Text(
              '✓ $certification',
              style: const TextStyle(
                fontFamily: NeTokens.fontFamilySans,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: NeTokens.botanicalEvergreen,
              ),
            ),
          ),
          const SizedBox(height: NeTokens.spacing10),
          ...features.map((feat) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                const Icon(Icons.check, size: 13, color: NeTokens.mossGreen),
                const SizedBox(width: 6),
                Text(
                  feat,
                  style: const TextStyle(
                    fontFamily: NeTokens.fontFamilySans,
                    fontSize: 12,
                    color: NeTokens.slateMuted,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: NeTokens.spacing12),
          InkWell(
            onTap: () => context.push('/research?q=$query'),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.biotech_rounded, size: 14, color: NeTokens.botanicalEvergreen),
                SizedBox(width: 4),
                Text(
                  'View Peer-Reviewed Verification in Workspace →',
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
    );
  }
}
