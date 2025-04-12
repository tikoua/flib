
import 'package:flib/db/kv/sp/sp.dart';

///在非flutter平台下，使用这个类,比如运行测试代码时

SharedPreferencesKv createKvStorage() {
  return SharedPreferencesKv._instance;
}

class SharedPreferencesKv implements Sp {
  static final SharedPreferencesKv _instance = SharedPreferencesKv();
  final _map = <String, Object?>{};

  @override
  Future<bool> clear() async {
    _map.clear();
    return true;
  }

  @override
  Future<T?> read<T>({required String key}) async {
    return _map[key] as T?;
  }

  @override
  Future<void> write({required String key, required value}) async {
    _map[key] = value;
  }

  @override
  Future<void> remove({required String key}) async {
    _map.remove(key);
  }

  @override
  Future<Set<String>> getKeys() async {
    return _map.keys.toSet();
  }
}
