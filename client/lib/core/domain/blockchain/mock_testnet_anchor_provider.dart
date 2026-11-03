// ==============================================================================
// Nutrient Earth — Verifiable Testnet Blockchain Anchor Provider
// Deterministic implementation for Sepolia testnet simulation and CI/CD verification.
// Produces verifiable cryptographic commitments without requiring live spend or wallet signatures.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'blockchain_anchor_provider.dart';
import 'merkle_tree.dart';

class MockTestnetAnchorProvider implements BlockchainAnchorProvider {
  final String _chainId;
  final String _contractAddress;
  final Map<String, AnchorTransactionResult> _anchoredRoots = {};
  int _currentBlockNumber = 5894200;

  MockTestnetAnchorProvider({
    String chainId = 'sepolia-testnet',
    String contractAddress = '0x71C95911E9a5D330f4D621842EC243EE1343292e', // NutrientEarthEvidenceRegistry testnet proxy
  })  : _chainId = chainId,
        _contractAddress = contractAddress;

  @override
  String get chainId => _chainId;

  @override
  String get contractAddress => _contractAddress;

  @override
  Future<AnchorTransactionResult> submitBatchAnchor({
    required String merkleRoot,
    required List<String> manifestHashes,
    Map<String, dynamic>? metadata,
  }) async {
    final cleanRoot = merkleRoot.trim().toLowerCase();

    // Idempotency: If this exact root was already anchored, return existing confirmation
    if (_anchoredRoots.containsKey(cleanRoot)) {
      return _anchoredRoots[cleanRoot]!;
    }

    _currentBlockNumber += 1;
    final now = DateTime.now().toUtc();

    // Generate deterministic transaction hash from contract address, root, block, and timestamp
    final txSeed = '$_contractAddress:$cleanRoot:$_currentBlockNumber:${now.toIso8601String()}';
    final txHash = '0x${sha256.convert(utf8.encode(txSeed)).toString()}';

    final result = AnchorTransactionResult(
      isSuccess: true,
      txHash: txHash,
      blockNumber: _currentBlockNumber,
      chainId: _chainId,
      contractAddress: _contractAddress,
      anchoredAt: now,
    );

    _anchoredRoots[cleanRoot] = result;
    return result;
  }

  @override
  Future<ProofVerificationResult> verifyOnChainProof({
    required String merkleRoot,
    required MerkleProof proof,
    required String manifestHash,
    String? txHash,
  }) async {
    final cleanRoot = merkleRoot.trim().toLowerCase();
    final cleanManifest = manifestHash.trim().toLowerCase();

    // 1. Verify that the proof's leaf matches the inquiry manifest hash
    final manifestHashMatches = proof.leafHash.trim().toLowerCase() == cleanManifest;

    // 2. Mathematically verify the Merkle inclusion proof
    final merkleValid = proof.verify();
    final merkleRootMatches = merkleValid && (proof.expectedRoot.trim().toLowerCase() == cleanRoot);

    // 3. Verify on-chain presence in the anchor ledger
    final hasAnchor = _anchoredRoots.containsKey(cleanRoot);
    final txMatches = (txHash == null) || (_anchoredRoots[cleanRoot]?.txHash == txHash);
    final onChainConfirmation = hasAnchor && txMatches;

    final isValid = manifestHashMatches && merkleRootMatches && onChainConfirmation;

    final String details;
    if (isValid) {
      final record = _anchoredRoots[cleanRoot]!;
      details = 'Cryptographic inclusion verified. Anchored in block #${record.blockNumber} (tx: ${record.txHash?.substring(0, 10)}...).';
    } else if (!manifestHashMatches) {
      details = 'Verification failed: Proof leaf does not match inquiry manifest hash.';
    } else if (!merkleRootMatches) {
      details = 'Verification failed: Merkle proof audit path does not evaluate to root.';
    } else {
      details = 'Verification failed: Merkle root not found in on-chain ledger records.';
    }

    return ProofVerificationResult(
      isValid: isValid,
      merkleRootMatches: merkleRootMatches,
      manifestHashMatches: manifestHashMatches,
      onChainConfirmation: onChainConfirmation,
      details: details,
    );
  }
}
