import 'package:flib/account/base_account_info.dart';
import 'package:flib/flib.dart';

class AccountDao extends BaseDao<BaseAccountInfo> {
  AccountDao(super.db, super.tableName);

  @override
  Future<void> createTable() async {
    var sql = '''
      CREATE TABLE IF NOT EXISTS $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT NOT NULL UNIQUE,
        log_state TEXT NOT NULL,
        serialization TEXT NOT NULL
      );
      CREATE INDEX IF NOT EXISTS idx_${tableName}_uid ON $tableName (uid);
      CREATE INDEX IF NOT EXISTS idx_${tableName}_log_state ON $tableName (log_state);
    ''';
    await db.execute(sql);
  }

  @override
  Future<int> delete(String id) async {
    return await db.delete(tableName, where: 'uid = ?', whereArgs: [id]);
  }

  @override
  Future<List<BaseAccountInfo>> getAll() async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return BaseAccountInfo.fromDb(maps[i]);
    });
  }

  @override
  Future<BaseAccountInfo?> getById(String id) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'uid = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BaseAccountInfo.fromDb(maps.first);
  }

  @override
  Future<int> insert(BaseAccountInfo item) async {
    return await db.insert(
      tableName,
      item.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<int> update(BaseAccountInfo item) async {
    return await db.update(
      tableName,
      item.toDb(),
      where: 'uid = ?',
      whereArgs: [item.uid],
    );
  }

  /// 根据登录状态查询账号
  Future<List<BaseAccountInfo>> getByLogState(String logState) async {
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'log_state = ?',
      whereArgs: [logState],
    );
    return List.generate(maps.length, (i) {
      return BaseAccountInfo.fromDb(maps[i]);
    });
  }

  /// 只更新账号的登录状态
  Future<int> updateLogState(String uid, String logState) async {
    return await db.update(
      tableName,
      {'log_state': logState},
      where: 'uid = ?',
      whereArgs: [uid],
    );
  }
}
