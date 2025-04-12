import 'package:flib/common/dispose.dart';
import 'package:flib/db/db_kit.dart';
import 'package:flib/db/kv/sp/shared_preference_kv.dart';
import 'package:flib/db/sql/sqflite/sqflite.dart';

class BaseAccount implements Disposable {
  late final BaseAccountOptions _options;
  String get uid => _options.uid;
  late final DbKit<SharedPreferenceKv, SqfLiteDb> dbKit;
  BaseAccount(List<BaseAccountOpt> opts) {
    _options = BaseAccountOptions();
    for (var opt in opts) {
      opt(_options);
    }
  }

  Future<void> start() async {
    var dbKitOpts = _options.dbKitOpts;
    dbKit = await createSqfliteDbKit(dbKitOpts);
    await dbKit.start();
  }

  @override
  Future<void> dispose() async {}
}

class BaseAccountOptions {
  String uid = "";
  List<DbKitOpt> dbKitOpts = [];
}

typedef BaseAccountOpt = Function(BaseAccountOptions);
BaseAccountOpt withUid(String uid) {
  return (options) {
    options.uid = uid;
  };
}

BaseAccountOpt withDbKitOpts(List<DbKitOpt> dbKitOpts) {
  return (options) {
    options.dbKitOpts.addAll(dbKitOpts);
  };
}

