import 'package:flib/common/dispose.dart';
import 'package:flib/db/kv/kv_storage.dart';
import 'package:flib/db/kv/sp/shared_preference_kv.dart';
import 'package:flib/db/sql/data_base.dart';
import 'package:flib/db/sql/sqflite/sqflite.dart';

///创建默认的DBKit实例
///创建基于sqflite+ SP 实现的DBKit
Future<DbKit<SharedPreferenceKv, SqfLiteDb>> createSqfliteDbKit(
  List<DbKitOpt> opts,
) async {
  var dbIktOptions = DbKitOptions();
  for (var opt in opts) {
    opt(dbIktOptions);
  }
  var dbKit = DbKit(
    SharedPreferenceKv(dbIktOptions._kvOpts),
    SqfLiteDb.createDb(dbIktOptions._dbOpts),
  );
  await dbKit.start();
  return dbKit;
}

///配置DBKit,通过 [DbKitOpt] 配置
class DbKitOptions {
  final List<SpKvOpt> _kvOpts = [];
  final List<SqfliteOpt> _dbOpts = [];
}

typedef DbKitOpt = Function(DbKitOptions);

///配置kv
DbKitOpt withKvOpts(List<SpKvOpt> kvOpts) {
  return (options) {
    options._kvOpts.addAll(kvOpts);
  };
}

///配置db
DbKitOpt withDbOpts(List<SqfliteOpt> dbOpts) {
  return (options) {
    options._dbOpts.addAll(dbOpts);
  };
}

class DbKit<KV extends KvStorage, DB extends DbStorage> implements Disposable {
  final DB _db;
  final KV _kv;

  DbKit(this._kv, this._db);
  Future<void> start() async {
    await _db.openDatabase();
  }

  ///插入、更新、查询、删除等操作
  Future<T> withDataBase<T>(Future<T> Function(DB) action) {
    return action(_db);
  }

  ///如果类型转换失败，调用方需要处理异常;
  Future<T?> get<T>(String key) async {
    return _kv.read<T>(key: key);
  }

  ///目前只支持部分类型的存储，包含：int ,double ,bool,String ,List<String> ;
  ///方法内部会做类型检查，如果传入不支持类型，会抛错.
  Future<void> put(String key, Object value) async {
    return _kv.write(key: key, value: value);
  }

  ///保存全局变量
  Future<void> putGlobal(String key, Object value) async {
    return _kv.writeGlobal(key: key, value: value);
  }

  ///读取全局变量
  Future<T?> getGlobal<T>(String key) async {
    return _kv.readGlobal<T>(key: key);
  }

  ///删除指定key的数据
  Future<void> remove(String key) async {
    return _kv.remove(key: key);
  }

  ///删除指定key的数据
  Future<void> removeGlobal(String key) async {
    return _kv.remove(key: key);
  }

  ///清除Kv存贮中的所有数据
  Future<void> clearKV(List<String> keyPrefix) async {
    return _kv.clear(keyPrefix);
  }

  ///获取所有的key
  Future<Set<String>> getKeys(List<String> keyPrefix) {
    return _kv.getKeys(keyPrefix);
  }

  ///关闭数据库连接，释放资源
  @override
  Future<void> dispose() async {
    return _db.close();
  }
}
