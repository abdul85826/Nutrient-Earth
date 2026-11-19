// ==============================================================================
// Nutrient Earth — Blockchain Trust & Independent Verification Models
// Typed domain contracts for:
// - Merkle Batches & Transaction Lifecycle
// - Cryptographic Commitments & Inclusion Proofs
// - Structured Independent Verification Results
// ==============================================================================

import 'package:uuid/uuid.dart';

enum BlockchainTransactionStatus {
  created,
  queued,
  submitted,
  pending,
  confirmed,
  finalized,
  failed,
  replaced,
  reorged;

  String get value => name.toUpperCase();

  static BlockchainTransactionStatus fromString(String val) {
    return BlockchainTransactionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => BlockchainTransactionStatus.created,
    );
  }
}

enum VerificationVerdict {
  validCommitment,
  invalidCommitment,
  unknownBatch,
  unconfirmedTransaction,
  revokedIssuer,
  unsupportedProtocol,
  insufficientVerificationData;

  String get value {
    switch (this) {
      case VerificationVerdict.validCommitment:
        return 'VALID_COMMITMENT';
      case VerificationVerdict.invalidCommitment:
        return 'INVALID_COMMITMENT';
      case VerificationVerdict.unknownBatch:
        return 'UNKNOWN_BATCH';
      case VerificationVerdict.unconfirmedTransaction:
        return 'UNCONFIRMED_TRANSACTION';
      case VerificationVerdict.revokedIssuer:
        return 'REVOKED_ISSUER';
      case VerificationVerdict.unsupportedProtocol:
        return 'UNSUPPORTED_PROTOCOL';
      case VerificationVerdict.insufficientVerificationData:
        return 'INSUFFICIENT_VERIFICATION_DATA';
    }
  }
}

class CryptographicCommitment {
  final String id;
  final String? batchId;
  final String recordType; // 'scientific_evidence', 'product_verification', 'ai_recommendation', 'consent_audit'
  final String recordId;
  final String recordVersion;
  final String leafHash; // bytes32 hex
  final int leafIndex;
  final List<String> merkleProof;
  final String canonicalPayloadDigest;
  final String domainSeparator;
  final bool isAnchored;
  final DateTime createdAt;

  const CryptographicCommitment({
    required this.id,
    this.batchId,
    required this.recordType,
    required this.recordId,
    this.recordVersion = 'v1.0.0',
    required this.leafHash,
    this.leafIndex = 0,
    this.merkleProof = const [],
    required this.canonicalPayloadDigest,
    required this.domainSeparator,
    this.isAnchored = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'batch_id': batchId,
        'record_type': recordType,
        'record_id': recordId,
        'record_version': recordVersion,
        'leaf_hash': leafHash,
        'leaf_index': leafIndex,
        'merkle_proof': merkleProof,
        'canonical_payload_digest': canonicalPayloadDigest,
        'domain_separator': domainSeparator,
        'is_anchored': isAnchored,
        'created_at': createdAt.toIso8601String(),
      };
}

class BlockchainBatchRecord {
  final String id;
  final String batchId;
  final int chainId;
  final String merkleRoot;
  final int batchSize;
  final String protocolVersion;
  final String manifestUri;
  final BlockchainTransactionStatus status;
  final String? transactionHash;
  final int? blockNumber;
  final DateTime createdAt;

  const BlockchainBatchRecord({
    required this.id,
    required this.batchId,
    required this.chainId,
    required this.merkleRoot,
    required this.batchSize,
    required this.protocolVersion,
    required this.manifestUri,
    required this.status,
    this.transactionHash,
    this.blockNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'batch_id': batchId,
        'chain_id': chainId,
        'merkle_root': merkleRoot,
        'batch_size': batchSize,
        'protocol_version': protocolVersion,
        'manifest_uri': manifestUri,
        'status': status.value,
        'transaction_hash': transactionHash,
        'block_number': blockNumber,
        'created_at': createdAt.toIso8601String(),
      };
}

class IndependentVerificationResult {
  final VerificationVerdict verdict;
  final String recordType;
  final String recordId;
  final String leafHash;
  final String? rootHash;
  final String? batchId;
  final int? chainId;
  final String? contractAddress;
  final String? transactionHash;
  final int? confirmations;
  final String protocolVersion;
  final bool isIssuerAuthorized;
  final String explanation;
  final Map<String, bool> verificationChecks;
  final DateTime verifiedAt;

  const IndependentVerificationResult({
    required this.verdict,
    required this.recordType,
    required this.recordId,
    required this.leafHash,
    this.rootHash,
    this.batchId,
    this.chainId,
    this.contractAddress,
    this.transactionHash,
    this.confirmations,
    required this.protocolVersion,
    required this.isIssuerAuthorized,
    required this.explanation,
    required this.verificationChecks,
    required this.verifiedAt,
  });

  bool get isValid => verdict == VerificationVerdict.validCommitment;

  Map<String, dynamic> toJson() => {
        'verdict': verdict.value,
        'is_valid': isValid,
        'record_type': recordType,
        'record_id': recordId,
        'leaf_hash': leafHash,
        'root_hash': rootHash,
        'batch_id': batchId,
        'chain_id': chainId,
        'contract_address': contractAddress,
        'transaction_hash': transactionHash,
        'confirmations': confirmations,
        'protocol_version': protocolVersion,
        'is_issuer_authorized': isIssuerAuthorized,
        'explanation': explanation,
        'verification_checks': verificationChecks,
        'verified_at': verifiedAt.toIso8601String(),
      };
}
