/// Clean Architecture cache boundary interface supporting low-latency biological records.
abstract class DistributedCache {
  /// Write biological data to the cache layer with custom eviction.
  Future<void> write(String key, String value, {required Duration timeToLive});

  /// Retrieve biological payload from the cache layer.
  Future<String?> read(String key);

  /// Evict entry immediately from index.
  Future<void> evict(String key);

  /// Clear all dynamic session variables.
  Future<void> flushAll();
}

/// Dynamic in-memory local caching implementation.
class LocalMemoryCache implements DistributedCache {
  final Map<String, _CacheEntry> _store = {};

  @override
  Future<void> write(String key, String value, {required Duration timeToLive}) async {
    _store[key] = _CacheEntry(
      payload: value,
      expiresAt: DateTime.now().add(timeToLive),
    );
  }

  @override
  Future<String?> read(String key) async {
    final entry = _store[key];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiresAt)) {
      _store.remove(key); // Evict expired entry
      return null;
    }

    return entry.payload;
  }

  @override
  Future<void> evict(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> flushAll() async {
    _store.clear();
  }
}

class _CacheEntry {
  final String payload;
  final DateTime expiresAt;

  const _CacheEntry({required this.payload, required this.expiresAt});
}
