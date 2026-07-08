/// Cache Layer Infrastructure for Nutrient Earth BIOS.
///
/// Purpose: Provide a unified caching abstraction supporting both in-memory
/// (Dart-native) and future Redis/Hive backends through a swappable interface.
///
/// Responsibilities:
/// - TTL-based key-value caching
/// - Cache invalidation and eviction
/// - Namespace isolation per domain
/// - Cache hit/miss telemetry hooks
///
/// Future expansion:
/// - Redis adapter for server-side distributed caching
/// - Hive adapter for offline-first device caching
/// - LRU eviction with configurable max size
/// - Cache warming strategies
library;

import 'dart:collection';

/// Abstract cache contract — swap implementations without changing consumers.
abstract class CacheProvider<K, V> {
  /// Read a value by key. Returns null on cache miss.
  Future<V?> read(K key);

  /// Write a value with an optional TTL.
  Future<void> write(K key, V value, {Duration? ttl});

  /// Remove a specific key.
  Future<void> invalidate(K key);

  /// Remove all keys matching a namespace prefix.
  Future<void> invalidateNamespace(String namespace);

  /// Clear the entire cache.
  Future<void> clear();

  /// Return true if the key exists and has not expired.
  Future<bool> has(K key);
}

/// Internal cache entry with expiry metadata.
class _CacheEntry<V> {
  final V value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// High-performance in-memory cache with TTL support.
/// Uses a LinkedHashMap for O(1) access and FIFO eviction.
class InMemoryCacheProvider<K, V> implements CacheProvider<K, V> {
  final int maxEntries;
  final Duration defaultTtl;
  final LinkedHashMap<K, _CacheEntry<V>> _store = LinkedHashMap();

  int _hits = 0;
  int _misses = 0;

  InMemoryCacheProvider({
    this.maxEntries = 512,
    this.defaultTtl = const Duration(hours: 1),
  });

  double get hitRatio => (_hits + _misses) == 0 ? 0 : _hits / (_hits + _misses);

  @override
  Future<V?> read(K key) async {
    final entry = _store[key];
    if (entry == null) {
      _misses++;
      return null;
    }
    if (entry.isExpired) {
      _store.remove(key);
      _misses++;
      return null;
    }
    _hits++;
    return entry.value;
  }

  @override
  Future<void> write(K key, V value, {Duration? ttl}) async {
    // Evict oldest entry if at capacity
    if (_store.length >= maxEntries && !_store.containsKey(key)) {
      _store.remove(_store.keys.first);
    }
    _store[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
  }

  @override
  Future<void> invalidate(K key) async => _store.remove(key);

  @override
  Future<void> invalidateNamespace(String namespace) async {
    _store.removeWhere((key, _) => key.toString().startsWith(namespace));
  }

  @override
  Future<void> clear() async => _store.clear();

  @override
  Future<bool> has(K key) async {
    final entry = _store[key];
    return entry != null && !entry.isExpired;
  }
}

/// Domain-scoped cache namespaces for consistent key isolation.
class CacheNamespaces {
  static const String biologicalProfile = 'bio_profile';
  static const String environmentalState = 'env_state';
  static const String recommendations = 'recommendations';
  static const String ragChunks = 'rag_chunks';
  static const String llmContext = 'llm_context';
  static const String featureStore = 'feature_store';
  static const String wearableStream = 'wearable_stream';
  static const String aiSession = 'ai_session';

  static String buildKey(String namespace, String id) => '$namespace:$id';
}
