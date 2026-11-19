// ==============================================================================
// Nutrient Earth — EVM-Compatible Keccak-256 Merkle Tree & Proof Generator
// Byte-for-byte identical to OpenZeppelin MerkleProof.sol and EvidenceAnchorRegistry.sol.
// Uses sorted-pair Keccak-256 concatenation: keccak256(min(a,b) || max(a,b)).
// ==============================================================================

import 'dart:typed_data';
import 'keccak256.dart';

class MerkleInclusionProof {
  final String leafHex;
  final List<String> proofHexElements;
  final String rootHex;
  final int leafIndex;

  const MerkleInclusionProof({
    required this.leafHex,
    required this.proofHexElements,
    required this.rootHex,
    required this.leafIndex,
  });

  Map<String, dynamic> toJson() => {
        'leaf': leafHex,
        'proof': proofHexElements,
        'root': rootHex,
        'leaf_index': leafIndex,
      };
}

class EvmMerkleTree {
  final List<Uint8List> _leaves;
  late final List<List<Uint8List>> _levels;

  EvmMerkleTree(List<Uint8List> leaves) : _leaves = List.unmodifiable(leaves) {
    if (leaves.isEmpty) {
      throw ArgumentError('Cannot build Merkle tree from empty leaf collection.');
    }
    _buildTree();
  }

  factory EvmMerkleTree.fromHexStrings(List<String> hexLeaves) {
    final byteLeaves = hexLeaves.map(_hexToBytes).toList();
    return EvmMerkleTree(byteLeaves);
  }

  Uint8List get rootBytes => _levels.last.first;

  String get rootHex => _bytesToHex(rootBytes);

  void _buildTree() {
    _levels = [];
    var currentLevel = List<Uint8List>.from(_leaves);
    _levels.add(currentLevel);

    while (currentLevel.length > 1) {
      final nextLevel = <Uint8List>[];
      for (int i = 0; i < currentLevel.length; i += 2) {
        if (i + 1 < currentLevel.length) {
          nextLevel.add(hashPair(currentLevel[i], currentLevel[i + 1]));
        } else {
          // Odd element is duplicated/paired with itself
          nextLevel.add(hashPair(currentLevel[i], currentLevel[i]));
        }
      }
      _levels.add(nextLevel);
      currentLevel = nextLevel;
    }
  }

  /// Generates OpenZeppelin-compatible inclusion proof for leaf at index.
  MerkleInclusionProof getProof(int leafIndex) {
    if (leafIndex < 0 || leafIndex >= _leaves.length) {
      throw RangeError('Leaf index out of bounds: $leafIndex');
    }

    final proof = <String>[];
    int currentIndex = leafIndex;

    for (int level = 0; level < _levels.length - 1; level++) {
      final currentLevel = _levels[level];
      final isRightSibling = currentIndex % 2 == 1;
      final siblingIndex = isRightSibling ? currentIndex - 1 : currentIndex + 1;

      if (siblingIndex < currentLevel.length) {
        proof.add(_bytesToHex(currentLevel[siblingIndex]));
      } else {
        // Paired with self
        proof.add(_bytesToHex(currentLevel[currentIndex]));
      }

      currentIndex = currentIndex ~/ 2;
    }

    return MerkleInclusionProof(
      leafHex: _bytesToHex(_leaves[leafIndex]),
      proofHexElements: proof,
      rootHex: rootHex,
      leafIndex: leafIndex,
    );
  }

  /// Verifies an inclusion proof off-chain with exact EVM logic.
  static bool verifyProof({
    required String leafHex,
    required List<String> proofHex,
    required String rootHex,
  }) {
    var computed = _hexToBytes(leafHex);
    for (final elementHex in proofHex) {
      final sibling = _hexToBytes(elementHex);
      computed = hashPair(computed, sibling);
    }
    return _bytesToHex(computed).toLowerCase() == rootHex.toLowerCase();
  }

  /// Sorted-pair Keccak-256 hash matching OpenZeppelin MerkleProof.sol:
  /// `computedHash <= proofElement ? keccak256(computed, proof) : keccak256(proof, computed)`
  static Uint8List hashPair(Uint8List a, Uint8List b) {
    final aLessThanOrEqualB = _compareBytes(a, b) <= 0;
    final combined = Uint8List(64);
    if (aLessThanOrEqualB) {
      combined.setRange(0, 32, a);
      combined.setRange(32, 64, b);
    } else {
      combined.setRange(0, 32, b);
      combined.setRange(32, 64, a);
    }
    return Keccak256.hash(combined);
  }

  static int _compareBytes(Uint8List a, Uint8List b) {
    for (int i = 0; i < 32; i++) {
      final diff = a[i].compareTo(b[i]);
      if (diff != 0) return diff;
    }
    return 0;
  }

  static Uint8List _hexToBytes(String hexStr) {
    var clean = hexStr.startsWith('0x') ? hexStr.substring(2) : hexStr;
    if (clean.length % 2 != 0) clean = '0$clean';
    final result = Uint8List(clean.length ~/ 2);
    for (int i = 0; i < result.length; i++) {
      result[i] = int.parse(clean.substring(i * 2, (i * 2) + 2), radix: 16);
    }
    return result;
  }

  static String _bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer('0x');
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
