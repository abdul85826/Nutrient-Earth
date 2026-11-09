// ==============================================================================
// Nutrient Earth — Web3 Notarization Adapter
// Strict boundary: Encapsulates all RPC and smart contract communication.
// Guaranteed zero app crash if blockchain network is partitioned or unreachable.
// ==============================================================================

import 'dart:async';
import 'package:crypto/crypto.dart';

enum NotarizationStatus {
  pending,
  anchored,
  networkOffline,
  failed,
}

class AttestationReceipt {
  final String transactionHash;
  final int blockNumber;
  final String merkleRoot;
  final DateTime anchoredAt;
  final NotarizationStatus status;
  final String? errorMessage;

  const AttestationReceipt({
    required this.transactionHash,
    required this.blockNumber,
    required this.merkleRoot,
    required this.anchoredAt,
    required this.status,
    this.errorMessage,
  });
}

abstract class Web3NotarizationAdapter {
  Future<AttestationReceipt> anchorMerkleRoot({
    required String merkleRoot,
    required int batchSize,
    required String manifestUri,
  });

  Future<bool> isNetworkReachable();
}

/// Resilient adapter for offline simulation and isolated testing
class MockWeb3NotarizationAdapter implements Web3NotarizationAdapter {
  bool forceOffline = false;
  int currentBlock = 18542000;

  MockWeb3NotarizationAdapter({this.forceOffline = false});

  @override
  Future<bool> isNetworkReachable() async {
    return !forceOffline;
  }

  @override
  Future<AttestationReceipt> anchorMerkleRoot({
    required String merkleRoot,
    required int batchSize,
    required String manifestUri,
  }) async {
    if (forceOffline) {
      return AttestationReceipt(
        transactionHash: '',
        blockNumber: 0,
        merkleRoot: merkleRoot,
        anchoredAt: DateTime.now(),
        status: NotarizationStatus.networkOffline,
        errorMessage: 'Blockchain RPC unreachable: Network partition simulated.',
      );
    }

    currentBlock++;
    final txHash = '0x${sha256.convert(DateTime.now().toIso8601String().codeUnits).toString()}';

    return AttestationReceipt(
      transactionHash: txHash,
      blockNumber: currentBlock,
      merkleRoot: merkleRoot,
      anchoredAt: DateTime.now(),
      status: NotarizationStatus.anchored,
    );
  }
}

