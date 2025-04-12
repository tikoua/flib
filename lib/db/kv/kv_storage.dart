/// key-value storage
// 定义 SecureStorageProvider
abstract class KvStorage {
  /// 写入数据
  ///@param value: String | int | double | bool | List<String>
  Future<void> write({required String key, required dynamic value});

  /// 保存全局变量
  Future<void> writeGlobal({required String key, required dynamic value});

  /// 读取数据
  Future<T?> read<T>({required String key});

  /// 读取全局变量
  Future<T?> readGlobal<T>({required String key});

  /// 删除数据
  Future<void> remove({required String key});

  ///删除全局变量
  Future<void> removeGlobal({required String key});

  ///获取所有指定前缀匹配的key
  ///如果keyPrefix为空，则返回所有key
  Future<Set<String>> getKeys(List<String> keyPrefix);

  /// 删除所有指定前缀的数据
  /// 如果 keyPrefix 空，则删除所有数据
  Future<void> clear(List<String> keyPrefix);
}
