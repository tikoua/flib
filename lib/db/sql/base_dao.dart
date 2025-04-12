import 'package:sqflite/sqflite.dart';

abstract class BaseDao<T> {
  final Database db;
  final String tableName;

  BaseDao(this.db, this.tableName);
  Future<void> createTable(Database db);
  Future<int> insert(T item);
  Future<T?> getById(int id);
  Future<List<T>> getAll();
  Future<int> update(T item);
  Future<int> delete(int id);
}
