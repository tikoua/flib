import 'dart:async';
import 'dart:convert';

import 'package:flib/account/base_account.dart';
import 'package:flib/common/iterable_ext.dart';
import 'package:flib/common/logger.dart';
import 'package:flib/common/system/path/path_util.dart';
import 'package:flib/db/db_kit.dart';
import 'package:flib/db/kv/sp/shared_preference_kv.dart';
import 'package:flib/db/sql/sqflite/sqflite.dart';

///管理账号信息
class AccountManager {
  static final _logger = Logger('AccountManager');

  //DbKit中kv的 IdentityId
  static final _accountInfoIdentityId = "imlib_account_manager";

  //账号列表的key
  static final _keyLoggedInfoList = "logged_info_list";

  static final instance = AccountManager._();

  AccountManager._();

  late AccountManagerOptions _options;
  late List<BaseAccountOpt> _defaultAccountOpts;

  //保存账号列表的 DbKit
  late final DbKit _accountListDbKit;

  final List<BaseAccount> _loggedAccounts = [];
  final StreamController<List<BaseAccount>> _loggedAccountStreamController =
      StreamController.broadcast();

  Stream<List<BaseAccount>> get loggedAccountStream =>
      _loggedAccountStreamController.stream;

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

    _accountListDbKit = await createSqfliteDbKit([
      withKvOpts([withIdentityId(_accountInfoIdentityId)]),
      withDbOpts([
        withIsInMemory(options.isDbKitInMemory),
        withDBPath(
          PathUtil.getApplicationDocumentsDirectory().then(
            (dbFolder) => PathUtil.join(dbFolder, 'db/global/imlib.db'),
          ),
        ),
      ]),
    ]);
    //加载本地账号信息
    var accounts = await _loadLoggedAccounts();
    _logger.debug("缓存的账号数量: ${accounts?.length}");
    if (accounts != null && accounts.isNotEmpty) {
      _loggedAccounts.addAll(accounts);
    }
  }

  ///登录成功后将账号交给manager管理
  Future<BaseAccount> addAccount({required List<BaseAccountOpt> opts}) async {
    _logger.debug("addAccount start");
    var account = await _createAccountByAccountOpts(opts);
    var serialization = _options.toSerialization!;
    var serializationInfo = await serialization.call(account);
    _logger.debug("addAccount serializationInfo: $serializationInfo");
    List<SerializationInfo> infoList = await _loadLoggedInfoList() ?? [];
    infoList.add(serializationInfo);
    await _updateLoggedAccountList(infoList);
    _loggedAccounts.add(account);
    return account;
  }

  ///清除登录信息，释放资源
  Future<void> disposeAccount(BaseAccount account) async {
    _logger.debug("disposeAccount start");
    //释放账号资源
    await account.dispose();
    //将账号信息从保存的cmd列表中移除
    var localInfoList = await _loadLoggedInfoList();
    if (localInfoList == null || localInfoList.isEmpty) {
      throw Exception("local online cmd list is empty");
    }
    var accountInfo = await _options.toSerialization!(account);
    var accountCmd = localInfoList.firstOrNullWhere(
      (info) => info.uniqueId == accountInfo.uniqueId,
    );
    if (accountCmd == null) {
      throw Exception("account online cmd not found");
    }
    localInfoList.remove(accountCmd);
    await _updateLoggedAccountList(localInfoList);
    _loggedAccounts.remove(account);
  }

  ///更新本地保存的已登录账号信息
  Future<void> _updateLoggedAccountList(
    List<SerializationInfo> loggedInfoList,
  ) async {
    _logger.debug("_updateLoggedAccountList start ${loggedInfoList.length}");
    List<String> onlineStr =
        loggedInfoList.map((info) => info.toString()).toList();
    var str = jsonEncode(onlineStr);
    _logger.debug("_updateLoggedAccountList str: $str");
    await _accountListDbKit.put(_keyLoggedInfoList, str);
    var str2 = await _accountListDbKit.get<String>(_keyLoggedInfoList);
    _logger.debug("写入后直接读_updateLoggedAccountList str2: $str2");
  }

  ///在线账户列表；不可修改；
  Future<List<BaseAccount>> getAllLoggedAccounts() async {
    _logger.debug("getAllLoggedAccounts start");
    return List.unmodifiable(_loggedAccounts);
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

  ///从保存的登录信息中加载已登录账号
  Future<List<BaseAccount>?> _loadLoggedAccounts() async {
    _logger.debug("_loadLoggedAccounts start");
    return _loadLoggedInfoList().then((infoList) async {
      if (infoList == null || infoList.isEmpty) {
        return null;
      }
      List<BaseAccount> loggedAccountsLocal = [];
      await Future.forEach(infoList, (info) async {
        final account = await _recoverAccountByInfo(info);
        loggedAccountsLocal.insert(0, account);
      });
      return loggedAccountsLocal;
    });
  }

  ///从本地加载已登录账户登录序列化结果列表
  Future<List<SerializationInfo>?> _loadLoggedInfoList() async {
    _logger.debug("_loadLoggedInfoList start");
    var onlineStr = await _accountListDbKit.get<String>(_keyLoggedInfoList);
    _logger.debug("_loadLoggedInfoList onlineStr: $onlineStr");
    if (onlineStr == null) {
      return null;
    }
    List<dynamic> loggedList = jsonDecode(onlineStr);
    var infoList =
        loggedList.map((s) {
          return SerializationInfo.fromString(s);
        }).toList();
    return infoList;
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
