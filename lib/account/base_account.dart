import 'package:flib/common/dispose.dart';
import 'package:flib/db/db_kit.dart';

class BaseAccount implements Disposable {
  late final BaseAccountOptions _options;
  String get uid => _options.uid;

  BaseAccount(List<BaseAccountOpt> opts) {
    _options = BaseAccountOptions();
    for (var opt in opts) {
      opt(_options);
    }
  }

  @override
  Future<void> dispose() async {}
}

class BaseAccountOptions {
  String uid = "";
  List<DbKitOptions> dbKitOptions = [];
}

typedef BaseAccountOpt = Function(BaseAccountOptions);
