import 'package:flib/db/kv/kv_storage.dart';
import 'package:flib/db/kv/sp/kv_storage_mock.dart' as SpKVStorage;

///sp实现 [KvStorage] 的方式 隔离平台的区别
class SharedPreferenceKv implements KvStorage {
  late final SpKvOptions _options;

  SharedPreferenceKv._(this._options);

  ///生成[SharedPreferenceKV]实例
  factory SharedPreferenceKv(List<SpKvOpt>? opts) {
    var options = SpKvOptions();
    if (opts != null && opts.isNotEmpty) {
      for (var opt in opts) {
        opt(options);
      }
    }
    if (options.identityId.isEmpty) {
      throw Exception("必须指定identityId");
    }
    return SharedPreferenceKv._(options);
  }

  final _sp = SpKVStorage.createKvStorage();

  @override
  Future<void> clear(List<String> keyPrefix) async {
    var allKeys = await getKeys(keyPrefix);
    return Future.forEach(allKeys, (element) async {
      await _sp.remove(key: element);
    });
  }

  @override
  Future<T?> read<T>({required String key}) {
    return _sp.read(key: _wrapKey(key));
  }

  @override
  Future<void> remove({required String key}) {
    return _sp.remove(key: _wrapKey(key));
  }

  @override
  Future<void> write({required String key, required value}) {
    return _sp.write(key: _wrapKey(key), value: value);
  }

  @override
  Future<Set<String>> getKeys(List<String> keyPrefix) async {
    var allKeys = await _sp.getKeys();
    var preTag = _options.identityId;
    allKeys.retainWhere((element) {
      if (keyPrefix.isEmpty) {
        //如果未传递keyPrefix，则返回所有key
        return element.startsWith(_options.identityId);
      }
      for (String keyPre in keyPrefix) {
        var isMatch = element.startsWith(_wrapKey(keyPre));
        if (isMatch) {
          return true;
        }
      }
      return false;
    });
    print("getKeys identityId: $preTag size:${allKeys.length}");
    return allKeys;
  }

  String _wrapKey(String key) {
    var preTag = _options.identityId;
    return "$preTag$key";
  }

  @override
  Future<T?> readGlobal<T>({required String key}) {
    return _sp.read<T>(key: key);
  }

  @override
  Future<void> removeGlobal({required String key}) {
    return _sp.remove(key: key);
  }

  @override
  Future<void> writeGlobal({required String key, required value}) {
    return _sp.write(key: key, value: value);
  }
}

class SpKvOptions {
  String identityId = "";
}

typedef SpKvOpt = Function(SpKvOptions);

///所有key的前面都会添加这个字符串
SpKvOpt withIdentityId(String identityId) {
  return (options) {
    options.identityId = identityId;
  };
}
