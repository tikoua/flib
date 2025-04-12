import 'package:flib/common/dispose.dart';
import 'package:flib/db/db_kit.dart';

class BaseAccount implements Disposable {
  late final AccountOptions options;
  String get uid => options.uid;

  BaseAccount(List<AccountOpt> opts) {
    options = AccountOptions();
    for (var opt in opts) {
      opt(options);
    }
  }

  @override
  Future<void> dispose() async {}
}

class AccountOptions {
  String uid = "";
  List<DbKitOptions> dbKitOptions = [];
}

typedef AccountOpt = Function(AccountOptions);
