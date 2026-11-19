// ==============================================================================
// Nutrient Earth — EIP-712 Structured Digital Signatures
// Types for typed attestation signatures, domain separation, and EVM digest hashing.
// ==============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'keccak256.dart';

class Eip712Domain {
  final String name;
  final String version;
  final int chainId;
  final String verifyingContract;

  const Eip712Domain({
    this.name = 'NutrientEarthEvidence',
    this.version = '1',
    this.chainId = 84532, // Base Sepolia
    required this.verifyingContract,
  });

  // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
  static final String typeHashHex = Keccak256.hashStringHex(
    'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)',
  );

  String computeDomainSeparator() {
    final buffer = BytesBuilder();
    buffer.add(_hexToBytes(typeHashHex));
    buffer.add(Keccak256.hash(Uint8List.fromList(utf8.encode(name))));
    buffer.add(Keccak256.hash(Uint8List.fromList(utf8.encode(version))));
    buffer.add(_uint256ToBytes(BigInt.from(chainId)));
    buffer.add(_addressToBytes(verifyingContract));

    return Keccak256.hashHex(buffer.toBytes());
  }

  static Uint8List _hexToBytes(String hex) {
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    final bytes = Uint8List(clean.length ~/ 2);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = int.parse(clean.substring(i * 2, (i * 2) + 2), radix: 16);
    }
    return bytes;
  }

  static Uint8List _uint256ToBytes(BigInt value) {
    final bytes = Uint8List(32);
    var temp = value;
    for (int i = 31; i >= 0; i--) {
      bytes[i] = (temp & BigInt.from(0xFF)).toInt();
      temp = temp >> 8;
    }
    return bytes;
  }

  static Uint8List _addressToBytes(String address) {
    final clean = address.startsWith('0x') ? address.substring(2) : address;
    final padded = clean.padLeft(64, '0');
    return _hexToBytes(padded);
  }
}

class EvidenceAttestationPayload {
  final String recordHash; // bytes32 hex
  final String recordType; // e.g. "SCIENTIFIC_EVIDENCE", "PRODUCT_VERIFICATION"
  final String protocolVersion;
  final int timestampSeconds;

  const EvidenceAttestationPayload({
    required this.recordHash,
    required this.recordType,
    required this.protocolVersion,
    required this.timestampSeconds,
  });

  // keccak256("EvidenceAttestation(bytes32 recordHash,string recordType,string protocolVersion,uint256 timestamp)")
  static final String typeHashHex = Keccak256.hashStringHex(
    'EvidenceAttestation(bytes32 recordHash,string recordType,string protocolVersion,uint256 timestamp)',
  );

  String computeStructHash() {
    final buffer = BytesBuilder();
    buffer.add(Eip712Domain._hexToBytes(typeHashHex));
    buffer.add(Eip712Domain._hexToBytes(recordHash));
    buffer.add(Keccak256.hash(Uint8List.fromList(utf8.encode(recordType))));
    buffer.add(Keccak256.hash(Uint8List.fromList(utf8.encode(protocolVersion))));
    buffer.add(Eip712Domain._uint256ToBytes(BigInt.from(timestampSeconds)));

    return Keccak256.hashHex(buffer.toBytes());
  }

  /// Computes EIP-712 signable digest: keccak256("\x19\x01" || domainSeparator || structHash)
  String computeEip712Digest(Eip712Domain domain) {
    final domainSeparator = domain.computeDomainSeparator();
    final structHash = computeStructHash();

    final buffer = BytesBuilder();
    buffer.add([0x19, 0x01]);
    buffer.add(Eip712Domain._hexToBytes(domainSeparator));
    buffer.add(Eip712Domain._hexToBytes(structHash));

    return Keccak256.hashHex(buffer.toBytes());
  }
}
