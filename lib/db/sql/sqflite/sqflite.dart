import 'dart:async';

import 'package:flib/db/sql/base_dao.dart';
import 'package:flib/db/sql/data_base.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

///基于sqflite实现的 [DbStorage]
class SqfLiteDb implements DbStorage {
  ///创建[SqfLiteDb]实例的静态方法
  static SqfLiteDb createDb(List<SqfliteOpt> opts) {
    var options = SqfliteOptions();
    for (var opt in opts) {
      opt(options);
    }
    final instance = SqfLiteDb._(options);
    return instance;
  }

  SqfLiteDb._(this._options);

  final SqfliteOptions _options;

  late Database db;

  @override
  Future<void> openDatabase() async {
    String path;
    if (_options.isInMemory) {
      path = inMemoryDatabasePath;
    } else {
      var optPath = await _options.dbPath;
      if (optPath == null || optPath.isEmpty) {
        throw Exception("dbPath is null or empty");
      }
      path = optPath;
    }

    var dbOptions = OpenDatabaseOptions();
    // Init ffi loader if needed.
    sqfliteFfiInit();
    db = await databaseFactoryFfi.openDatabase(path, options: dbOptions);
    var tables = _options.tables;
    for (var table in tables) {
      await table.createTable(db);
    }
  }

  @override
  Future<void> close() async {
    db.close();
  }
}

class SqfliteOptions {
  ///@param[dbPath] 如果不同用户的数据都存在同一个db文件里，则dbPath不需要按照uid区分;如果不同用户分开db存储，则需要不同用户传递不同的dbPath；
  FutureOr<String?>? dbPath;

  ///是否使用内存数据库，如果为true,则数据只保存在内存中，重启app后清除。
  bool isInMemory = false;

  ///是否开启wal模式
  bool walMode = false;

  ///是否通过日志输出执行的语句
  bool logStatements = false;

  ///需要创建的表
  List<BaseDao> tables = [];

  SqfliteOptions();
}

typedef SqfliteOpt = Function(SqfliteOptions);

SqfliteOpt withDBPath(FutureOr<String?> dbPath) {
  return (options) {
    options.dbPath = dbPath;
  };
}

SqfliteOpt withIsInMemory(bool isInMemory) {
  return (options) {
    options.isInMemory = isInMemory;
  };
}

//暂未实现
SqfliteOpt withWalMode(bool walMode) {
  return (options) {
    options.walMode = walMode;
  };
}

//暂未实现
SqfliteOpt withLogStatements(bool logStatements) {
  return (options) {
    options.logStatements = logStatements;
  };
}

SqfliteOpt withTable(BaseDao dao) {
  return (options) {
    options.tables.add(dao);
  };
}
