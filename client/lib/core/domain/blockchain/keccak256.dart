// ==============================================================================
// Nutrient Earth — Ethereum Keccak-256 Cryptographic Hash Engine
// Pure Dart implementation of Keccak[r=1088, c=512] with Ethereum padding (0x01).
// Provides 100% byte-for-byte compatibility with EVM keccak256() and Solidity.
// ==============================================================================

import 'dart:convert';
import 'dart:typed_data';

class Keccak256 {
  Keccak256._();

  static const int _rateInBytes = 136; // (1600 - 512) / 8 = 136 bytes
  static const int _outputBytes = 32;

  // Round constants for Keccak-f[1600]
  static final List<BigInt> _roundConstants = [
    BigInt.parse('0000000000000001', radix: 16),
    BigInt.parse('0000000000008082', radix: 16),
    BigInt.parse('800000000000808A', radix: 16),
    BigInt.parse('8000000080008000', radix: 16),
    BigInt.parse('000000000000808B', radix: 16),
    BigInt.parse('0000000080000001', radix: 16),
    BigInt.parse('8000000080008081', radix: 16),
    BigInt.parse('8000000000008009', radix: 16),
    BigInt.parse('000000000000008A', radix: 16),
    BigInt.parse('0000000000000088', radix: 16),
    BigInt.parse('0000000080008009', radix: 16),
    BigInt.parse('000000008000000A', radix: 16),
    BigInt.parse('000000008000808B', radix: 16),
    BigInt.parse('800000000000008B', radix: 16),
    BigInt.parse('8000000000008089', radix: 16),
    BigInt.parse('8000000000008003', radix: 16),
    BigInt.parse('8000000000008002', radix: 16),
    BigInt.parse('8000000000000080', radix: 16),
    BigInt.parse('000000000000800A', radix: 16),
    BigInt.parse('800000008000000A', radix: 16),
    BigInt.parse('8000000080008081', radix: 16),
    BigInt.parse('8000000000008080', radix: 16),
    BigInt.parse('0000000080000001', radix: 16),
    BigInt.parse('8000000080008008', radix: 16),
  ];

  static final List<int> _rotationOffsets = [
    0, 1, 62, 28, 27, 36, 44, 6, 55, 20, 3, 10, 43, 25, 39, 41, 45, 15, 21, 8, 18, 2, 61, 56, 14
  ];

  static final List<int> _piLaneMapping = [
    0, 10, 20, 5, 15, 16, 1, 11, 21, 6, 7, 17, 2, 12, 22, 23, 8, 18, 3, 13, 14, 24, 9, 19, 4
  ];

  static final BigInt _mask64 = BigInt.parse('FFFFFFFFFFFFFFFF', radix: 16);

  static BigInt _rotL64(BigInt val, int shift) {
    shift = shift % 64;
    if (shift == 0) return val;
    final left = (val << shift) & _mask64;
    final right = (val >> (64 - shift)) & _mask64;
    return (left | right) & _mask64;
  }

  /// Hashes arbitrary raw bytes using Ethereum Keccak-256 and returns a 32-byte Uint8List.
  static Uint8List hash(Uint8List input) {
    final state = List<BigInt>.filled(25, BigInt.zero);

    // Padding: Keccak standard uses 0x01 padding byte, NOT NIST SHA3's 0x06
    final padLength = _rateInBytes - (input.length % _rateInBytes);
    final padded = Uint8List(input.length + padLength);
    padded.setRange(0, input.length, input);

    if (padLength == 1) {
      padded[input.length] = 0x81;
    } else {
      padded[input.length] = 0x01;
      padded[padded.length - 1] = 0x80;
    }

    // Absorb phase
    for (int blockOffset = 0; blockOffset < padded.length; blockOffset += _rateInBytes) {
      for (int lane = 0; lane < 17; lane++) {
        final byteOffset = blockOffset + (lane * 8);
        var laneVal = BigInt.zero;
        for (int b = 0; b < 8; b++) {
          laneVal |= BigInt.from(padded[byteOffset + b]) << (b * 8);
        }
        state[lane] = state[lane] ^ laneVal;
      }
      _keccakF1600(state);
    }

    // Squeeze phase (32 bytes = 4 lanes of 8 bytes)
    final output = Uint8List(_outputBytes);
    for (int lane = 0; lane < 4; lane++) {
      final laneVal = state[lane];
      for (int b = 0; b < 8; b++) {
        output[(lane * 8) + b] = ((laneVal >> (b * 8)) & BigInt.from(0xFF)).toInt();
      }
    }

    return output;
  }

  /// Returns 0x-prefixed hex string of Keccak-256
  static String hashHex(Uint8List input) {
    final bytes = hash(input);
    final buffer = StringBuffer('0x');
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// Convenience wrapper for UTF-8 string input
  static String hashStringHex(String input) {
    return hashHex(Uint8List.fromList(utf8.encode(input)));
  }

  static void _keccakF1600(List<BigInt> a) {
    for (int round = 0; round < 24; round++) {
      // Theta step
      final c = List<BigInt>.filled(5, BigInt.zero);
      for (int x = 0; x < 5; x++) {
        c[x] = a[x] ^ a[x + 5] ^ a[x + 10] ^ a[x + 15] ^ a[x + 20];
      }
      final d = List<BigInt>.filled(5, BigInt.zero);
      for (int x = 0; x < 5; x++) {
        d[x] = c[(x + 4) % 5] ^ _rotL64(c[(x + 1) % 5], 1);
      }
      for (int x = 0; x < 5; x++) {
        for (int y = 0; y < 5; y++) {
          final idx = x + (5 * y);
          a[idx] = a[idx] ^ d[x];
        }
      }

      // Rho and Pi steps
      final b = List<BigInt>.filled(25, BigInt.zero);
      for (int i = 0; i < 25; i++) {
        b[_piLaneMapping[i]] = _rotL64(a[i], _rotationOffsets[i]);
      }

      // Chi step
      for (int y = 0; y < 5; y++) {
        for (int x = 0; x < 5; x++) {
          final idx = x + (5 * y);
          a[idx] = b[idx] ^ ((~b[((x + 1) % 5) + (5 * y)]) & b[((x + 2) % 5) + (5 * y)]);
          a[idx] = a[idx] & _mask64;
        }
      }

      // Iota step
      a[0] = a[0] ^ _roundConstants[round];
      a[0] = a[0] & _mask64;
    }
  }
}
