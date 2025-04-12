
import 'package:flib/db/kv/sp/sp.dart';

import 'kv_storage_mock.dart'
    if (dart.library.ui) 'shared_preferences_kv_flutter.dart' as kv;

///获取 [KvStorage] 实例的方式
class SpKVStorage {
  static Sp createKvStorage() {
    return kv.createKvStorage();
  }
}
