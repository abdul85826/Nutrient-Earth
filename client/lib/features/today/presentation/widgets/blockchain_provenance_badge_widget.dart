// ==============================================================================
// Nutrient Earth — Blockchain Cryptographic Provenance Badge Widget
// Displays verified integrity status, Merkle roots, BaseScan block explorer links,
// and audit proofs without requiring a cryptocurrency wallet or exposing jargon.
// Adheres strictly to Nutrient Earth palette: #FAF8F5 cream, #EAF0EC sage, #00251D text.
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/domain/blockchain/blockchain_trust_models.dart';
import '../../../../core/services/blockchain/independent_verification_api_service.dart';

class BlockchainProvenanceBadgeWidget extends ConsumerWidget {
  final CryptographicCommitment commitment;
  final String? batchId;
  final String? merkleRoot;
  final String? txHash;

  const BlockchainProvenanceBadgeWidget({
    super.key,
    required this.commitment,
    this.batchId,
    this.merkleRoot,
    this.txHash,
  });

  void _showProofInspectionModal(BuildContext context, WidgetRef ref) async {
    final verificationService = ref.read(independentVerificationApiServiceProvider);
    final result = await verificationService.verifyCommitment(
      recordType: commitment.recordType,
      recordId: commitment.recordId,
      leafHash: commitment.leafHash,
      batchId: batchId ?? 'BATCH-2026-SEPOLIA',
      merkleProof: commitment.merkleProof,
      expectedRoot: merkleRoot,
    );

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: Color(0xFF00251D), size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Cryptographic Provenance Audit',
                    style: TextStyle(
                      fontFamily: 'Serif',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00251D),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: result.isValid ? Colors.green.shade50 : Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: result.isValid ? Colors.green.shade300 : Colors.amber.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.isValid ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: result.isValid ? Colors.green.shade800 : Colors.amber.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.explanation,
                      style: TextStyle(
                        fontSize: 12,
                        color: result.isValid ? Colors.green.shade900 : Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Record Type', commitment.recordType.toUpperCase()),
            _buildDetailRow('Record Identifier', commitment.recordId),
            _buildDetailRow('Protocol Version', result.protocolVersion),
            _buildDetailRow('Leaf Hash (Keccak-256)', commitment.leafHash),
            if (result.rootHash != null) _buildDetailRow('Anchored Merkle Root', result.rootHash!),
            if (result.transactionHash != null)
              _buildDetailRow('BaseScan TX Hash', result.transactionHash!),
            _buildDetailRow('Network', 'Base Sepolia (Chain ID 84532)'),
            _buildDetailRow('Proof Path Depth', '${commitment.merkleProof.length} sibling hashes'),
            const SizedBox(height: 12),
            const Text(
              'Zero-PII Compliance: No personal health records, identifiers, or conversation data are ever stored on-chain. Verification is mathematical and cryptographic.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w500,
              color: Color(0xFF00251D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAnchored = commitment.isAnchored;

    return InkWell(
      onTap: () => _showProofInspectionModal(context, ref),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAnchored ? const Color(0xFFEAF0EC) : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAnchored ? const Color(0xFFBACBC0) : Colors.amber.shade200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAnchored ? Icons.shield_outlined : Icons.hourglass_top,
              size: 14,
              color: isAnchored ? const Color(0xFF00251D) : Colors.amber.shade900,
            ),
            const SizedBox(width: 6),
            Text(
              isAnchored ? 'Base Sepolia Verified' : 'Cryptographic Commitment Generated',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isAnchored ? const Color(0xFF00251D) : Colors.amber.shade900,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF00251D)),
          ],
        ),
      ),
    );
  }
}
