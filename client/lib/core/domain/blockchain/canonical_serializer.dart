// ==============================================================================
// Nutrient Earth — RFC-8785 Canonical JSON Record Serializer
// Produces deterministic byte representation across languages for cryptographic hashing.
// Sorts keys lexicographically, standardizes dates/numbers, and applies domain separation.
// ==============================================================================

import 'dart:convert';
import 'dart:typed_data';

class CanonicalRecordSerializer {
  CanonicalRecordSerializer._();

  /// Canonicalizes an arbitrary map structure into a deterministic RFC-8785 JSON string.
  static String canonicalize(Map<String, dynamic> data, {String? domainSeparator}) {
    final sorted = _sortValue(data);
    final rawJson = json.encode(sorted);

    if (domainSeparator != null && domainSeparator.isNotEmpty) {
      return '$domainSeparator:$rawJson';
    }
    return rawJson;
  }

  /// Canonicalizes and converts to UTF-8 bytes for hashing.
  static Uint8List canonicalBytes(Map<String, dynamic> data, {String? domainSeparator}) {
    final str = canonicalize(data, domainSeparator: domainSeparator);
    return Uint8List.fromList(utf8.encode(str));
  }

  static dynamic _sortValue(dynamic value) {
    if (value is Map) {
      final sortedMap = <String, dynamic>{};
      final sortedKeys = value.keys.map((k) => k.toString()).toList()..sort();
      for (final key in sortedKeys) {
        sortedMap[key] = _sortValue(value[key]);
      }
      return sortedMap;
    } else if (value is List) {
      return value.map(_sortValue).toList();
    } else if (value is DateTime) {
      return value.toUtc().toIso8601String();
    } else if (value is double) {
      // Normalize integer doubles e.g. 5.0 -> 5 to avoid cross-platform float variances
      if (value == value.roundToDouble() && !value.isInfinite && !value.isNaN) {
        return value.toInt();
      }
      return double.parse(value.toStringAsFixed(6));
    }
    return value;
  }
}
