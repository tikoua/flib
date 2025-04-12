import 'package:flib/common/dispose.dart';
import 'package:flib/db/db_kit.dart';

class BaseAccount implements Disposable {
  late final BaseAccountOptions options;
  String get uid => options.uid;

  BaseAccount(List<BaseAccountOpt> opts) {
    options = BaseAccountOptions();
    for (var opt in opts) {
      opt(options);
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
