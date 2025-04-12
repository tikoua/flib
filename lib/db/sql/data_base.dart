abstract class DbStorage {
  ///打开数据库,以及升级等
  Future<void> openDatabase();
  //关闭数据库连接，释放资源
  Future<void> close();
}
