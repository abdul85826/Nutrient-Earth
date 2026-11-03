// ==============================================================================
// Nutrient Earth — Merkle Proof Verification Modal
// Interactive cryptographic audit modal that reveals leaf hashing, Merkle audit path,
// and step-by-step root recomputation for complete scientific transparency.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/blockchain/evidence_integrity_service.dart';

class MerkleProofVerificationModal extends StatelessWidget {
  final ResearchProvenanceDossier dossier;

  const MerkleProofVerificationModal({
    super.key,
    required this.dossier,
  });

  static void show(BuildContext context, ResearchProvenanceDossier dossier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MerkleProofVerificationModal(dossier: dossier),
    );
  }

  @override
  Widget build(BuildContext context) {
    final proof = dossier.merkleProof;
    final leafMatches = proof.leafHash.trim().toLowerCase() == dossier.manifestHash.trim().toLowerCase();
    final computedRoot = proof.computeRoot();
    final rootMatches = computedRoot.isNotEmpty && computedRoot == proof.expectedRoot.trim().toLowerCase();
    final isMathematicallyValid = leafMatches && rootMatches && proof.verify();

    return Container(
      decoration: const BoxDecoration(
        color: NETokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NETokens.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: NETokens.emerald, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cryptographic Proof Audit',
                          style: GoogleFonts.newsreader(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: NETokens.primary,
                          ),
                        ),
                        Text(
                          'Merkle Inclusion Audit Path (RFC-6962)',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            color: NETokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: NETokens.borderSubtle, height: 24),

              // Mathematical Validity Status Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isMathematicallyValid
                      ? NETokens.emerald.withValues(alpha: 0.1)
                      : NETokens.errorContainer,
                  borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  border: Border.all(
                    color: isMathematicallyValid ? NETokens.emerald : NETokens.error,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isMathematicallyValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: isMathematicallyValid ? NETokens.emerald : NETokens.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMathematicallyValid
                                ? 'Merkle Proof Path Verified Valid'
                                : (!leafMatches ? "Proof Leaf Mismatch" : "Merkle Proof Evaluation Failed"),
                            style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isMathematicallyValid ? NETokens.emerald : NETokens.error,
                            ),
                          ),
                          Text(
                            !leafMatches ? "Proof leaf hash does not match inquiry manifest hash." : "Hash folding from leaf #${proof.leafIndex} evaluates strictly to Merkle Root.",
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              color: NETokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Leaf Hash
              Text(
                '1. LEAF HASH (CANONICAL MANIFEST)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: NETokens.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              _buildCodeBlock(proof.leafHash),

              const SizedBox(height: 14),

              // Audit Steps
              Text(
                '2. MERKLE AUDIT PATH (${proof.auditPath.length} STEPS)',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: NETokens.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              if (proof.auditPath.isEmpty)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NETokens.surfaceContainer,
                    borderRadius: BorderRadius.circular(NETokens.radiusSm),
                  ),
                  child: Text(
                    'Direct single-leaf batch commitment (root == leafHash).',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: NETokens.textSecondary),
                  ),
                )
              else
                ...proof.auditPath.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _buildCodeBlock('Step $idx [sibling: ${step.isRight ? "RIGHT" : "LEFT"}]: ${step.hash}'),
                  );
                }),

              const SizedBox(height: 14),

              // Computed Merkle Root
              Text(
                '3. EVALUATED MERKLE ROOT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: NETokens.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              _buildCodeBlock(computedRoot.isNotEmpty ? computedRoot : proof.expectedRoot),

              const SizedBox(height: 20),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NETokens.deepGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(NETokens.radiusFull),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close Verification Dossier'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainer,
        borderRadius: BorderRadius.circular(NETokens.radiusSm),
        border: Border.all(color: NETokens.borderDefault),
      ),
      child: SelectableText(
        code,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: NETokens.botanicalTeal,
        ),
      ),
    );
  }
}
