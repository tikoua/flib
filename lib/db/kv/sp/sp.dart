//抽象sp接口，为了隔离平台
abstract class Sp {
  /// key-value storage
// 定义 SecureStorageProvider
  /// 写入数据
  ///@param value: String | int | double | bool | List<String>
  Future<void> write({required String key, required dynamic value});

  /// 读取数据
  Future<T?> read<T>({required String key});

  /// 删除数据
  Future<void> remove({required String key});

  //获取所有的key
  Future<Set<String>> getKeys();

  /// 清除所有数据
  Future<void> clear();
}
