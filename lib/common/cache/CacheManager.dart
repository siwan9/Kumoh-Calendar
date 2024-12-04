abstract class CacheManager<T, K> {
  final Map<K, T> _cache = {};

  Future<T> get(K key) async {
    if (_cache.containsKey(key)) {
      print("Cache hit for key: $key");
      return _cache[key]!;
    } else {
      print("Cache miss for key: $key");
      final data = await load(key);
      _cache[key] = data;
      return data;
    }
  }

  Future<T> load(K key);

  // 캐시 삭제 메서드
  void remove(K key) {
    _cache.remove(key);
  }

  // 캐시 초기화
  void clear() {
    _cache.clear();
  }
}
