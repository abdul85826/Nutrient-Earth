// ==============================================================================
// Nutrient Earth — Merkle Proof & Cryptographic Integrity Service
// Strict isolation: Zero personal health data; computes cryptographic digests
// of scientific evidence items for decentralized attestation.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

class MerkleNode {
  final String hash;
  final MerkleNode? left;
  final MerkleNode? right;

  const MerkleNode({
    required this.hash,
    this.left,
    this.right,
  });
}

class MerkleProofService {
  MerkleProofService._();

  /// Computes SHA-256 leaf hash from canonical JSON representation of scientific claim
  static String computeLeafHash(Map<String, dynamic> evidenceItem) {
    // Sort keys deterministically
    final sortedKeys = evidenceItem.keys.toList()..sort();
    final canonicalMap = <String, dynamic>{};
    for (final key in sortedKeys) {
      canonicalMap[key] = evidenceItem[key];
    }
    final rawBytes = utf8.encode(json.encode(canonicalMap));
    return sha256.convert(rawBytes).toString();
  }

  /// Builds a complete Merkle tree over a list of leaf hashes and returns the Merkle Root
  static String buildMerkleRoot(List<String> leafHashes) {
    if (leafHashes.isEmpty) {
      return sha256.convert(utf8.encode('EMPTY_MERKLE_ROOT')).toString();
    }
    if (leafHashes.length == 1) {
      return leafHashes.first;
    }

    var currentLevel = List<String>.from(leafHashes);

    while (currentLevel.length > 1) {
      final nextLevel = <String>[];
      for (int i = 0; i < currentLevel.length; i += 2) {
        if (i + 1 < currentLevel.length) {
          nextLevel.add(_hashPair(currentLevel[i], currentLevel[i + 1]));
        } else {
          // Odd element is balanced by pairing with itself
          nextLevel.add(_hashPair(currentLevel[i], currentLevel[i]));
        }
      }
      currentLevel = nextLevel;
    }

    return currentLevel.first;
  }

  /// Verifies a leaf against a known Merkle Root using sibling hashes
  static bool verifyProof({
    required String leafHash,
    required List<String> proofSiblings,
    required String expectedRoot,
  }) {
    var computed = leafHash;
    for (final sibling in proofSiblings) {
      computed = _hashPair(computed, sibling);
    }
    return computed == expectedRoot;
  }

  static String _hashPair(String a, String b) {
    // Order pairs lexicographically for deterministic commutativity
    final combined = a.compareTo(b) <= 0 ? '$a$b' : '$b$a';
    return sha256.convert(utf8.encode(combined)).toString();
  }
}

