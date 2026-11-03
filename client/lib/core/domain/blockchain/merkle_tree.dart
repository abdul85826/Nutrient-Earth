// ==============================================================================
// Nutrient Earth — Merkle Tree & Inclusion Proof Engine
// Implements standard binary cryptographic Merkle trees (RFC-6962 standard)
// for batch verification and transparent on-chain evidence anchoring.
// ==============================================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';

List<int> _safeHexToBytes(String str) {
  final clean = str.replaceAll(' ', '').trim();
  // Valid hex string with even length: decode raw bytes
  final evenHexRegex = RegExp(r'^[0-9a-fA-F]+$');
  if (clean.isNotEmpty && clean.length % 2 == 0 && evenHexRegex.hasMatch(clean)) {
    final result = <int>[];
    for (int i = 0; i < clean.length; i += 2) {
      result.add(int.parse(clean.substring(i, i + 2), radix: 16));
    }
    return result;
  }
  // Fallback for non-hex or arbitrary strings: encode with UTF-8
  return utf8.encode(clean);
}

String _bytesToHex(List<int> bytes) {
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

class MerkleAuditStep {
  final String hash;
  final bool isRight; // true if this sibling hash is to the right of the current node

  const MerkleAuditStep({
    required this.hash,
    required this.isRight,
  });

  Map<String, dynamic> toJson() => {
        'hash': hash,
        'is_right': isRight,
      };

  factory MerkleAuditStep.fromJson(Map<String, dynamic> json) {
    return MerkleAuditStep(
      hash: json['hash'] as String? ?? '',
      isRight: json['is_right'] as bool? ?? true,
    );
  }
}

class MerkleProof {
  final String leafHash;
  final int leafIndex;
  final List<MerkleAuditStep> auditPath;
  final String expectedRoot;

  const MerkleProof({
    required this.leafHash,
    required this.leafIndex,
    required this.auditPath,
    required this.expectedRoot,
  });

  /// Evaluates and computes the Merkle Root by sequentially folding the leafHash
  /// through each step in the auditPath according to RFC-6962 binary rules.
  String computeRoot() {
    if (leafHash.isEmpty) return '';
    if (auditPath.isEmpty) return leafHash.toLowerCase();

    String currentHash = leafHash.toLowerCase();

    try {
      for (final step in auditPath) {
        final sibling = step.hash.toLowerCase();
        if (step.isRight) {
          currentHash = MerkleTree.hashNode(currentHash, sibling);
        } else {
          currentHash = MerkleTree.hashNode(sibling, currentHash);
        }
      }
      return currentHash.toLowerCase();
    } catch (_) {
      return '';
    }
  }

  /// Verifies that leafHash combined with auditPath matches expectedRoot.
  bool verify() {
    if (leafHash.isEmpty || expectedRoot.isEmpty) return false;
    final evaluated = computeRoot();
    return evaluated.isNotEmpty && evaluated == expectedRoot.toLowerCase();
  }

  Map<String, dynamic> toJson() => {
        'leaf_hash': leafHash,
        'leaf_index': leafIndex,
        'audit_path': auditPath.map((s) => s.toJson()).toList(),
        'expected_root': expectedRoot,
      };

  factory MerkleProof.fromJson(Map<String, dynamic> json) {
    return MerkleProof(
      leafHash: json['leaf_hash'] as String? ?? '',
      leafIndex: json['leaf_index'] as int? ?? 0,
      auditPath: (json['audit_path'] as List<dynamic>?)
              ?.map((s) => MerkleAuditStep.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      expectedRoot: json['expected_root'] as String? ?? '',
    );
  }
}

class MerkleTree {
  final List<String> leaves;
  final String root;

  const MerkleTree._({
    required this.leaves,
    required this.root,
  });

  /// Hashes two interior nodes per RFC-6962 Section 2.1:
  /// Interior node hash = SHA-256(0x01 || leftBytes || rightBytes)
  static String hashNode(String leftHex, String rightHex) {
    final leftBytes = _safeHexToBytes(leftHex);
    final rightBytes = _safeHexToBytes(rightHex);

    final payload = <int>[
      0x01, // RFC-6962 internal node domain separation byte
      ...leftBytes,
      ...rightBytes,
    ];

    return _bytesToHex(sha256.convert(payload).bytes);
  }

  /// Returns the largest power of 2 less than [n], where k < n <= 2k.
  static int largestPowerOfTwoLessThan(int n) {
    if (n < 2) return 0;
    int k = 1;
    while ((k << 1) < n) {
      k <<= 1;
    }
    return k;
  }

  /// Computes Merkle Tree Hash (MTH) for sublist [0:n] per RFC-6962:
  /// MTH({}) = SHA-256()
  /// MTH({d[0]}) = d[0] (since leaves are already SHA-256 digests)
  /// MTH(D[n]) = H(0x01 || MTH(D[0:k]) || MTH(D[k:n]))
  static String computeMth(List<String> leavesList) {
    if (leavesList.isEmpty) {
      return 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
    }
    if (leavesList.length == 1) {
      return leavesList.first;
    }

    final k = largestPowerOfTwoLessThan(leavesList.length);
    final leftRoot = computeMth(leavesList.sublist(0, k));
    final rightRoot = computeMth(leavesList.sublist(k));

    return hashNode(leftRoot, rightRoot);
  }

  /// Constructs a MerkleTree from an arbitrary list of SHA-256 leaf hashes.
  factory MerkleTree.compute(List<String> rawLeaves) {
    if (rawLeaves.isEmpty) {
      const emptyHash = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      return const MerkleTree._(
        leaves: [],
        root: emptyHash,
      );
    }

    final sanitizedLeaves = rawLeaves.map((l) => l.trim().toLowerCase()).toList();
    final treeRoot = computeMth(sanitizedLeaves);

    return MerkleTree._(
      leaves: sanitizedLeaves,
      root: treeRoot,
    );
  }

  /// Generates a cryptographic inclusion proof for the leaf at [leafIndex]
  /// following RFC-6962 audit path rules.
  MerkleProof generateProof(int leafIndex) {
    if (leafIndex < 0 || leafIndex >= leaves.length) {
      throw RangeError('leafIndex $leafIndex out of bounds for tree with ${leaves.length} leaves');
    }

    final auditPath = _buildAuditPath(leafIndex, leaves);

    return MerkleProof(
      leafHash: leaves[leafIndex],
      leafIndex: leafIndex,
      auditPath: auditPath,
      expectedRoot: root,
    );
  }

  static List<MerkleAuditStep> _buildAuditPath(int index, List<String> currentLeaves) {
    if (currentLeaves.length <= 1) {
      return const [];
    }

    final k = largestPowerOfTwoLessThan(currentLeaves.length);
    final steps = <MerkleAuditStep>[];

    if (index < k) {
      // Leaf is in the left subtree
      final leftLeaves = currentLeaves.sublist(0, k);
      final rightLeaves = currentLeaves.sublist(k);
      final rightSiblingMth = computeMth(rightLeaves);

      // Recurse down left subtree
      steps.addAll(_buildAuditPath(index, leftLeaves));
      // Sibling is the right subtree root
      steps.add(MerkleAuditStep(hash: rightSiblingMth, isRight: true));
    } else {
      // Leaf is in the right subtree
      final leftLeaves = currentLeaves.sublist(0, k);
      final rightLeaves = currentLeaves.sublist(k);
      final leftSiblingMth = computeMth(leftLeaves);

      // Recurse down right subtree with adjusted index
      steps.addAll(_buildAuditPath(index - k, rightLeaves));
      // Sibling is the left subtree root
      steps.add(MerkleAuditStep(hash: leftSiblingMth, isRight: false));
    }

    return steps;
  }

  /// Validates an arbitrary Merkle proof independently.
  static bool verifyProof(MerkleProof proof) {
    return proof.verify();
  }
}
