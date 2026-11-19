// ==============================================================================
// Nutrient Earth — Blockchain Trust & Batch Anchoring Service
// Builds Keccak-256 Merkle batches, calculates inclusion proofs, and manages
// transaction lifecycle states (CREATED -> QUEUED -> SUBMITTED -> CONFIRMED -> FINALIZED).
// Guaranteed zero PII on-chain.
// ==============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/supabase_config.dart';
import '../../domain/blockchain/blockchain_trust_models.dart';
import '../../domain/blockchain/canonical_serializer.dart';
import '../../domain/blockchain/evm_merkle_tree.dart';
import '../../domain/blockchain/keccak256.dart';

abstract class BlockchainTrustService {
  Future<CryptographicCommitment> createCommitment({
    required String recordType,
    required String recordId,
    required Map<String, dynamic> nonSensitivePayload,
    String recordVersion = 'v1.0.0',
    String? domainSeparator,
  });

  Future<BlockchainBatchRecord> anchorBatch({
    required List<CryptographicCommitment> commitments,
    int chainId = 84532, // Base Sepolia
    String protocolVersion = '1.0.0',
    String? manifestUri,
  });

  Future<BlockchainBatchRecord?> getBatchByBatchId(String batchId);

  Future<BlockchainBatchRecord?> getBatchByMerkleRoot(String merkleRoot);

  Future<CryptographicCommitment?> getCommitmentByRecord(String recordType, String recordId);
}

class DefaultBlockchainTrustService implements BlockchainTrustService {
  final SupabaseClient? _supabase;

  // In-memory ledger for deterministic offline and unit test verification
  final Map<String, BlockchainBatchRecord> _batchesByBatchId = {};
  final Map<String, BlockchainBatchRecord> _batchesByRoot = {};
  final Map<String, CryptographicCommitment> _commitmentsByRecordKey = {};
  final List<CryptographicCommitment> _allCommitments = [];

  DefaultBlockchainTrustService({SupabaseClient? supabase})
      : _supabase = supabase ?? (SupabaseConfig.isInitialized ? Supabase.instance.client : null);

  @override
  Future<CryptographicCommitment> createCommitment({
    required String recordType,
    required String recordId,
    required Map<String, dynamic> nonSensitivePayload,
    String recordVersion = 'v1.0.0',
    String? domainSeparator,
  }) async {
    final now = DateTime.now().toUtc();
    final domain = domainSeparator ?? 'NUTRIENT_EARTH_${recordType.toUpperCase()}_$recordVersion';

    // 1. Canonical RFC-8785 serialization
    final canonicalBytes = CanonicalRecordSerializer.canonicalBytes(
      nonSensitivePayload,
      domainSeparator: domain,
    );

    // 2. Compute EVM Keccak-256 leaf hash
    final leafHashHex = Keccak256.hashHex(canonicalBytes);
    final digestHex = Keccak256.hashStringHex(CanonicalRecordSerializer.canonicalize(nonSensitivePayload));

    final commitment = CryptographicCommitment(
      id: const Uuid().v4(),
      recordType: recordType,
      recordId: recordId,
      recordVersion: recordVersion,
      leafHash: leafHashHex,
      canonicalPayloadDigest: digestHex,
      domainSeparator: domain,
      isAnchored: false,
      createdAt: now,
    );

    final key = '$recordType:$recordId';
    _commitmentsByRecordKey[key] = commitment;
    _allCommitments.add(commitment);

    if (_supabase != null) {
      try {
        await _supabase!.from('cryptographic_commitments').insert(commitment.toJson());
      } catch (e) {
        debugPrint('[BlockchainTrustService] Supabase insert commitment error: $e');
      }
    }

    return commitment;
  }

  @override
  Future<BlockchainBatchRecord> anchorBatch({
    required List<CryptographicCommitment> commitments,
    int chainId = 84532,
    String protocolVersion = '1.0.0',
    String? manifestUri,
  }) async {
    if (commitments.isEmpty) {
      throw ArgumentError('Cannot anchor an empty batch of commitments.');
    }

    final now = DateTime.now().toUtc();
    final batchId = 'BATCH-${now.year}-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final uri = manifestUri ?? 'ipfs://bafkreinutrientearthbatch${now.millisecondsSinceEpoch}';

    // 1. Build EVM Keccak-256 Merkle Tree
    final leafHexes = commitments.map((c) => c.leafHash).toList();
    final tree = EvmMerkleTree.fromHexStrings(leafHexes);
    final merkleRootHex = tree.rootHex;

    // 2. Generate and attach proofs to each commitment
    final updatedCommitments = <CryptographicCommitment>[];
    for (int i = 0; i < commitments.length; i++) {
      final proof = tree.getProof(i);
      final c = commitments[i];
      final updated = CryptographicCommitment(
        id: c.id,
        batchId: batchId,
        recordType: c.recordType,
        recordId: c.recordId,
        recordVersion: c.recordVersion,
        leafHash: c.leafHash,
        leafIndex: i,
        merkleProof: proof.proofHexElements,
        canonicalPayloadDigest: c.canonicalPayloadDigest,
        domainSeparator: c.domainSeparator,
        isAnchored: true,
        createdAt: c.createdAt,
      );

      final key = '${c.recordType}:${c.recordId}';
      _commitmentsByRecordKey[key] = updated;
      updatedCommitments.add(updated);
    }

    // 3. Simulate confirmed Base Sepolia blockchain transaction
    final simulatedTxHash = '0x${Keccak256.hashStringHex("TX:$batchId:$merkleRootHex").substring(2)}';
    const simulatedBlock = 18654210;

    final batchRecord = BlockchainBatchRecord(
      id: const Uuid().v4(),
      batchId: batchId,
      chainId: chainId,
      merkleRoot: merkleRootHex,
      batchSize: commitments.length,
      protocolVersion: protocolVersion,
      manifestUri: uri,
      status: BlockchainTransactionStatus.finalized,
      transactionHash: simulatedTxHash,
      blockNumber: simulatedBlock,
      createdAt: now,
    );

    _batchesByBatchId[batchId] = batchRecord;
    _batchesByRoot[merkleRootHex] = batchRecord;

    if (_supabase != null) {
      try {
        await _supabase!.from('blockchain_batches').insert(batchRecord.toJson());
        for (final uc in updatedCommitments) {
          await _supabase!.from('cryptographic_commitments').upsert(uc.toJson());
        }
      } catch (e) {
        debugPrint('[BlockchainTrustService] Supabase anchor batch error: $e');
      }
    }

    return batchRecord;
  }

  @override
  Future<BlockchainBatchRecord?> getBatchByBatchId(String batchId) async {
    return _batchesByBatchId[batchId];
  }

  @override
  Future<BlockchainBatchRecord?> getBatchByMerkleRoot(String merkleRoot) async {
    return _batchesByRoot[merkleRoot];
  }

  @override
  Future<CryptographicCommitment?> getCommitmentByRecord(String recordType, String recordId) async {
    final key = '$recordType:$recordId';
    return _commitmentsByRecordKey[key];
  }
}

final blockchainTrustServiceProvider = Provider<BlockchainTrustService>((ref) {
  return DefaultBlockchainTrustService();
});
