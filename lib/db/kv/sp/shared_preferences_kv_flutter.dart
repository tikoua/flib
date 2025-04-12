import 'package:flib/db/kv/sp/sp.dart';
import 'package:shared_preferences/shared_preferences.dart' as flutter_sp;

///使用 shared_preferences 实现的 [KvStorage] ；
SharedPreferencesKv createKvStorage() {
  return SharedPreferencesKv._();
}

class SharedPreferencesKv implements Sp {
  SharedPreferencesKv._();

  final _prefs = flutter_sp.SharedPreferences.getInstance();

  @override
  Future<bool> clear() async {
    var sp = await _prefs;
    sp.getKeys();
    return sp.clear();
  }

  @override
  Future<T?> read<T>({required String key}) async {
    return _prefs.then((sp) => sp.get(key) as T?);
  }

  @override
  Future<void> write({required String key, required value}) {
    return _prefs.then((sp) {
      if (value is int) {
        sp.setInt(key, value);
      } else if (value is double) {
        sp.setDouble(key, value);
      } else if (value is bool) {
        sp.setBool(key, value);
      } else if (value is String) {
        sp.setString(key, value);
      } else if (value is List<String>) {
        sp.setStringList(key, value);
      }
    });
  }

  @override
  Future<void> remove({required String key}) {
    return _prefs.then((sp) => sp.remove(key));
  }

  @override
  Future<Set<String>> getKeys() {
    return _prefs.then((sp) => sp.getKeys());
  }
}
