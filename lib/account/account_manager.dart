import 'dart:async';
import 'dart:convert';

import 'package:flib/account/account_dao.dart';
import 'package:flib/account/base_account.dart';
import 'package:flib/account/base_account_info.dart';
import 'package:flib/common/logger.dart';
import 'package:flib/common/system/path/path_util.dart';
import 'package:flib/db/db_kit.dart';
import 'package:flib/db/kv/sp/shared_preference_kv.dart';
import 'package:flib/db/sql/sqflite/sqflite.dart';

///管理账号信息
class AccountManager {
  static final _logger = Logger('AccountManager');

  static final instance = AccountManager._();

  AccountManager._();

  late AccountManagerOptions _options;
  late List<BaseAccountOpt> _defaultAccountOpts;

  //保存账号列表的 DAO
  late final AccountDao _accountDao;

  final List<BaseAccount> _loggedAccounts = [];
  final List<BaseAccount> _loggedOutAccounts = [];
  final StreamController<AccountList> _accountListStreamController =
      StreamController.broadcast();

  Stream<AccountList> get accountListStream =>
      _accountListStreamController.stream;

  ///初始化
  ///[globalOpts] 全局账号配置
  Future<void> init(List<AccountManagerOpt> opts) async {
    _logger.debug("init start ");
    var options = AccountManagerOptions();
    for (var opt in opts) {
      opt(options);
    }
    _options = options;
    var accountInitial = options.accountInitial;
    if (accountInitial == null) {
      throw Exception("accountInitial is null");
    }
    var toSerialization = options.toSerialization;
    if (toSerialization == null) {
      throw Exception("toSerialization is null");
    }
    //目前没有需要额外配置的
    _defaultAccountOpts = [];

    // 初始化数据库和DAO
    var dbKit = await createSqfliteDbKit([
      withKvOpts([withIdentityId("imlib_account_manager")]),
      withDbOpts([
        withIsInMemory(options.isDbKitInMemory),
        withDBPath(
          PathUtil.getApplicationDocumentsDirectory().then(
            (dbFolder) => PathUtil.join(dbFolder, 'db/global/imlib.db'),
          ),
        ),
      ]),
    ]);
    await dbKit.start();
    await dbKit.withDataBase((db) async {
      _accountDao = AccountDao(db.db, 'account');
      await _accountDao.createTable();
    });

    //加载本地账号信息
    await _loadAllAccounts();
  }

  ///登录成功后将账号交给manager管理
  Future<BaseAccount> addAccount({required List<BaseAccountOpt> opts}) async {
    _logger.debug("addAccount start");
    var account = await _createAccountByAccountOpts(opts);
    var serialization = _options.toSerialization!;
    var serializationInfo = await serialization.call(account);
    _logger.debug("addAccount serializationInfo: $serializationInfo");
    
    // 检查账号是否已存在
    var existingAccountInfo = await _accountDao.getById(account.uid);
    if (existingAccountInfo != null) {
      // 更新账号状态为已登录
      await _accountDao.updateLogState(account.uid, BaseAccountInfo.logStateLogged);
      
      // 如果账号在已登出列表中，则移动到已登录列表
      var loggedOutAccount = _loggedOutAccounts.firstWhere(
        (a) => a.uid == account.uid,
        orElse: () => account,
      );
      if (loggedOutAccount != account) {
        _loggedOutAccounts.remove(loggedOutAccount);
        _loggedAccounts.add(loggedOutAccount);
      } else {
        _loggedAccounts.add(account);
      }
    } else {
      // 保存新账号信息到数据库
      var accountInfo = BaseAccountInfo(
        uid: account.uid,
        logState: BaseAccountInfo.logStateLogged,
        rawData: serializationInfo.serialization,
      );
      await _accountDao.insert(accountInfo);
      _loggedAccounts.add(account);
    }
    
    _notifyAccountListChanged();
    return account;
  }

  ///清除登录信息，释放资源
  Future<void> disposeAccount(BaseAccount account) async {
    _logger.debug("disposeAccount start");
    //释放账号资源
    await account.dispose();
    
    // 更新账号状态为已登出
    await _accountDao.updateLogState(account.uid, BaseAccountInfo.logStateLoggedOut);
    
    _loggedAccounts.remove(account);
    _loggedOutAccounts.add(account);
    _notifyAccountListChanged();
  }

  ///在线账户列表；不可修改；
  Future<List<BaseAccount>> getAllLoggedAccounts() async {
    _logger.debug("getAllLoggedAccounts start");
    return List.unmodifiable(_loggedAccounts);
  }

  ///获取所有已登出账号
  Future<List<BaseAccount>> getAllLoggedOutAccounts() async {
    _logger.debug("getAllLoggedOutAccounts start");
    return List.unmodifiable(_loggedOutAccounts);
  }

  ///根据保存的账号信息恢复账号
  Future<BaseAccount> _recoverAccountByInfo(SerializationInfo info) async {
    _logger.debug("_recoverAccountByInfo start");
    var initial = _options.accountInitial!;
    var customOpts = await initial(info);
    return _createAccountByAccountOpts(customOpts);
  }

  ///根据账号配置创建账号
  Future<BaseAccount> _createAccountByAccountOpts(
    List<BaseAccountOpt> customOpts,
  ) async {
    _logger.debug("_createAccountByAccountOpts start");
    var accountOpts = <BaseAccountOpt>[];
    accountOpts
      ..addAll(_defaultAccountOpts)
      ..addAll(_options.globalOpts)
      ..addAll(customOpts);
    final account = BaseAccount(accountOpts);
    return account;
  }

  ///加载所有账号信息
  Future<void> _loadAllAccounts() async {
    _logger.debug("_loadAllAccounts start");
    var allAccounts = await _accountDao.getAll();
    
    for (var accountInfo in allAccounts) {
      var serializationInfo = SerializationInfo(
        uniqueId: accountInfo.uid,
        serialization: accountInfo.rawData,
      );
      final account = await _recoverAccountByInfo(serializationInfo);
      
      if (accountInfo.isLogged()) {
        _loggedAccounts.add(account);
      } else if (accountInfo.isLoggedOut()) {
        _loggedOutAccounts.add(account);
      }
    }
    
    _notifyAccountListChanged();
  }

  ///通知账号列表变更
  void _notifyAccountListChanged() {
    _accountListStreamController.add(AccountList(
      loggedAccounts: List.unmodifiable(_loggedAccounts),
      loggedOutAccounts: List.unmodifiable(_loggedOutAccounts),
    ));
  }
}

class AccountManagerOptions {
  ///客户端根据 [toSerialization] 序列化之后的信息，决定如何配置账号，序列化信息也是由客户端自己决定保存哪些内容
  FutureOr<List<BaseAccountOpt>> Function(SerializationInfo)? accountInitial;

  ///根据[BaseAccount] ，定义如何保存这个登录成功的账号信息,在还原时会将这个字符串交给[_accountInitial]来还原
  Future<SerializationInfo> Function(BaseAccount)? toSerialization;

  ///全局的账号配置
  List<BaseAccountOpt> globalOpts = [];

  ///账号信息是否只保存在内存中
  bool isDbKitInMemory = false;
}

typedef AccountManagerOpt = Function(AccountManagerOptions);

AccountManagerOpt withAccountInitial(
  FutureOr<List<BaseAccountOpt>> Function(SerializationInfo) accountInitial,
) {
  return (options) {
    options.accountInitial = accountInitial;
  };
}

AccountManagerOpt withSerialization(
  Future<SerializationInfo> Function(BaseAccount)? toSerialization,
) {
  return (options) {
    options.toSerialization = toSerialization;
  };
}

AccountManagerOpt withGlobalOpts(List<BaseAccountOpt> globalOpts) {
  return (options) {
    options.globalOpts = globalOpts;
  };
}

AccountManagerOpt withDbKitInMemory(bool isDbKitInMemory) {
  return (options) {
    options.isDbKitInMemory = isDbKitInMemory;
  };
}

class SerializationInfo {
  ///需保证全局唯一，[AccountManager] 会根据这个id来做删除。
  String uniqueId;

  //账号序列化结果
  String serialization;

  SerializationInfo({required this.uniqueId, required this.serialization});

  factory SerializationInfo.fromString(String info) {
    var json = jsonDecode(info);
    return SerializationInfo(
      uniqueId: json['uniqueId'],
      serialization: json['serialization'],
    );
  }

  @override
  String toString() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['uniqueId'] = uniqueId;
    json['serialization'] = serialization;
    return jsonEncode(json);
  }
}

class AccountList {
  final List<BaseAccount> loggedAccounts;
  final List<BaseAccount> loggedOutAccounts;

  AccountList({required this.loggedAccounts, required this.loggedOutAccounts});
}
