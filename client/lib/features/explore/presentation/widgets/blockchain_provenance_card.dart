// ==============================================================================
// Nutrient Earth — Blockchain Provenance & Evidence Integrity Card
// Displays the cryptographic manifest hash, Merkle root, transaction receipt,
// and enables one-click client-side Merkle proof verification.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/design_system/tokens/ne_tokens.dart';
import '../../../../core/domain/blockchain/blockchain_anchor_provider.dart';
import '../../../../core/domain/blockchain/evidence_integrity_service.dart';

class BlockchainProvenanceCard extends StatelessWidget {
  final ResearchProvenanceDossier dossier;
  final bool isVerifying;
  final ProofVerificationResult? verificationResult;
  final VoidCallback onVerifyTap;

  const BlockchainProvenanceCard({
    super.key,
    required this.dossier,
    required this.isVerifying,
    this.verificationResult,
    required this.onVerifyTap,
  });

  void _copyToClipboard(BuildContext context, String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard.'),
        duration: const Duration(seconds: 2),
        backgroundColor: NETokens.deepGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anchor = dossier.anchorResult;
    final isVerified = verificationResult?.isValid ?? (dossier.status == AnchorStatus.verified);

    return Container(
      padding: const EdgeInsets.all(NETokens.space16),
      decoration: BoxDecoration(
        color: NETokens.surfaceContainerLow,
        borderRadius: BorderRadius.circular(NETokens.radiusLg),
        border: Border.all(
          color: isVerified ? NETokens.emerald.withValues(alpha: 0.4) : NETokens.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: NETokens.secondaryContainer,
                        borderRadius: BorderRadius.circular(NETokens.radiusSm),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 16,
                        color: NETokens.emerald,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EVIDENCE PROVENANCE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: NETokens.primary,
                            ),
                          ),
                          Text(
                            'RFC-8785 Canonical • Zero PII',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: NETokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isVerified
                      ? NETokens.emerald.withValues(alpha: 0.12)
                      : NETokens.paleMint,
                  borderRadius: BorderRadius.circular(NETokens.radiusFull),
                  border: Border.all(
                    color: isVerified ? NETokens.emerald : NETokens.botanicalTeal,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isVerified ? NETokens.emerald : NETokens.botanicalTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isVerified ? 'VERIFIED' : dossier.status.name.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isVerified ? NETokens.emerald : NETokens.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: NETokens.space14),

          // Manifest Hash Row
          _buildHashRow(
            context,
            label: 'Manifest SHA-256',
            hash: dossier.manifestHash,
            tooltip: 'Cryptographic hash of the canonical inquiry manifest',
          ),

          const SizedBox(height: NETokens.space8),

          // Merkle Root Row
          _buildHashRow(
            context,
            label: 'Merkle Root',
            hash: dossier.merkleRoot,
            tooltip: 'Batch root committed to the blockchain evidence ledger',
          ),

          const SizedBox(height: NETokens.space8),

          // Chain & Block Info
          Container(
            padding: const EdgeInsets.all(NETokens.space10),
            decoration: BoxDecoration(
              color: NETokens.surfaceContainer,
              borderRadius: BorderRadius.circular(NETokens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NETWORK',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: NETokens.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        anchor.chainId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: NETokens.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (anchor.blockNumber != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BLOCK #',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: NETokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '#${anchor.blockNumber}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: NETokens.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (anchor.txHash != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'TX RECEIPT',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: NETokens.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        InkWell(
                          onTap: () => _copyToClipboard(context, 'Transaction Hash', anchor.txHash!),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '${anchor.txHash!.substring(0, 6)}...',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: NETokens.botanicalTeal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.copy_rounded, size: 10, color: NETokens.botanicalTeal),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: NETokens.space14),

          // Verification Action Banner or Result
          if (verificationResult != null)
            Container(
              padding: const EdgeInsets.all(NETokens.space10),
              decoration: BoxDecoration(
                color: verificationResult!.isValid
                    ? NETokens.emerald.withValues(alpha: 0.08)
                    : NETokens.errorContainer,
                borderRadius: BorderRadius.circular(NETokens.radiusMd),
                border: Border.all(
                  color: verificationResult!.isValid
                      ? NETokens.emerald.withValues(alpha: 0.3)
                      : NETokens.error,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    verificationResult!.isValid
                        ? Icons.check_circle_rounded
                        : Icons.error_outline_rounded,
                    color: verificationResult!.isValid ? NETokens.emerald : NETokens.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      verificationResult!.details,
                      style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: verificationResult!.isValid
                            ? NETokens.primary
                            : NETokens.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: NETokens.primary,
                  side: const BorderSide(color: NETokens.botanicalTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NETokens.radiusMd),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: isVerifying ? null : onVerifyTap,
                icon: isVerifying
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: NETokens.primary),
                      )
                    : const Icon(Icons.verified_outlined, size: 16),
                label: Text(
                  isVerifying ? 'Verifying Merkle Path...' : 'Verify Cryptographic Proof',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHashRow(
    BuildContext context, {
    required String label,
    required String hash,
    required String tooltip,
  }) {
    final displayHash = hash.length > 14
        ? '${hash.substring(0, 5)}...${hash.substring(hash.length - 4)}'
        : hash;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: NETokens.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _copyToClipboard(context, label, hash),
          borderRadius: BorderRadius.circular(NETokens.radiusSm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayHash,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: NETokens.botanicalTeal,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.copy_rounded, size: 11, color: NETokens.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
