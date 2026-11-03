// ==============================================================================
// Nutrient Earth — Blockchain Anchoring Provider Interface
// Chain-independent abstraction layer for submitting Merkle roots & provenance commitments.
// Supports Ethereum Sepolia testnet, EVM rollups, and local verifiable simulators.
// ==============================================================================

import 'merkle_tree.dart';

enum AnchorStatus {
  pending,
  submitted,
  anchored,
  verified,
  failed;

  String get displayName {
    switch (this) {
      case AnchorStatus.pending:
        return 'Pending Verification Batch';
      case AnchorStatus.submitted:
        return 'Submitted to Mempool';
      case AnchorStatus.anchored:
        return 'Anchored on Blockchain';
      case AnchorStatus.verified:
        return 'Cryptographically Verified';
      case AnchorStatus.failed:
        return 'Anchoring Failed (Fallback Active)';
    }
  }

  static AnchorStatus fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'submitted':
        return AnchorStatus.submitted;
      case 'anchored':
        return AnchorStatus.anchored;
      case 'verified':
        return AnchorStatus.verified;
      case 'failed':
        return AnchorStatus.failed;
      case 'pending':
      default:
        return AnchorStatus.pending;
    }
  }
}

class AnchorTransactionResult {
  final bool isSuccess;
  final String? txHash;
  final int? blockNumber;
  final String chainId;
  final String? contractAddress;
  final DateTime? anchoredAt;
  final String? errorMessage;

  const AnchorTransactionResult({
    required this.isSuccess,
    this.txHash,
    this.blockNumber,
    required this.chainId,
    this.contractAddress,
    this.anchoredAt,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() => {
        'is_success': isSuccess,
        'tx_hash': txHash,
        'block_number': blockNumber,
        'chain_id': chainId,
        'contract_address': contractAddress,
        'anchored_at': anchoredAt?.toIso8601String(),
        'error_message': errorMessage,
      };

  factory AnchorTransactionResult.fromJson(Map<String, dynamic> json) {
    return AnchorTransactionResult(
      isSuccess: json['is_success'] as bool? ?? false,
      txHash: json['tx_hash'] as String?,
      blockNumber: json['block_number'] as int?,
      chainId: json['chain_id'] as String? ?? 'sepolia-testnet',
      contractAddress: json['contract_address'] as String?,
      anchoredAt: json['anchored_at'] != null ? DateTime.tryParse(json['anchored_at'].toString()) : null,
      errorMessage: json['error_message'] as String?,
    );
  }
}

class ProofVerificationResult {
  final bool isValid;
  final bool merkleRootMatches;
  final bool manifestHashMatches;
  final bool onChainConfirmation;
  final String details;

  const ProofVerificationResult({
    required this.isValid,
    required this.merkleRootMatches,
    required this.manifestHashMatches,
    required this.onChainConfirmation,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'is_valid': isValid,
        'merkle_root_matches': merkleRootMatches,
        'manifest_hash_matches': manifestHashMatches,
        'on_chain_confirmation': onChainConfirmation,
        'details': details,
      };
}

abstract class BlockchainAnchorProvider {
  String get chainId;
  String get contractAddress;

  /// Submits a Merkle root representing a batch of research manifests to the ledger.
  Future<AnchorTransactionResult> submitBatchAnchor({
    required String merkleRoot,
    required List<String> manifestHashes,
    Map<String, dynamic>? metadata,
  });

  /// Verifies a specific manifest's Merkle proof against the on-chain or confirmed root.
  Future<ProofVerificationResult> verifyOnChainProof({
    required String merkleRoot,
    required MerkleProof proof,
    required String manifestHash,
    String? txHash,
  });
}
