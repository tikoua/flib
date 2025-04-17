import 'package:flib/common/dispose.dart';
import 'package:flib/db/db_kit.dart';
import 'package:flib/db/kv/sp/shared_preference_kv.dart';
import 'package:flib/db/sql/sqflite/sqflite.dart';

class BaseAccount implements Disposable {
  late final BaseAccountOptions _options;
  String get uid => _options.uid;
  String get logState => _options.logState;
  String get rawData => _options.rawData;
  late final DbKit<SharedPreferenceKv, SqfLiteDb> dbKit;
  dynamic get extra => _options.extra;
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
  String logState = "";
  String rawData = "";
  List<DbKitOpt> dbKitOpts = [];
  dynamic extra;
}

typedef BaseAccountOpt = Function(BaseAccountOptions);

BaseAccountOpt withUid(String uid) {
  return (options) {
    options.uid = uid;
  };
}

BaseAccountOpt withLogState(String logState) {
  return (options) {
    options.logState = logState;
  };
}

BaseAccountOpt withRawData(String rawData) {
  return (options) {
    options.rawData = rawData;
  };
}

BaseAccountOpt withDbKitOpts(List<DbKitOpt> dbKitOpts) {
  return (options) {
    options.dbKitOpts.addAll(dbKitOpts);
  };
}

BaseAccountOpt withExtra(dynamic extra) {
  return (options) {
    options.extra = extra;
  };
}
