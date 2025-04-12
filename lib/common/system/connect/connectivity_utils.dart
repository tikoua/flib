import 'package:flib/common/system/connect/connectivity_result.dart';
import 'package:flib/common/system/connect/connectivity_utils_dart.dart'
    if (dart.library.ui) 'package:flib/common/system/connect/connectivity_utils_flutter.dart';

///封装网络信息
class ConnectivityUtils {
  ///获取当前网络连接状态
  static Future<List<ConnectResult>> getConnectivity() async {
    return ConnectivityUtilsSub.getConnectivity();
  }

  ///订阅网络变化
  static Stream<List<ConnectResult>> connectivityStream() {
    return ConnectivityUtilsSub.connectivityStream();
  }

  static Future<bool> hasInternet() async {
    return ConnectivityUtilsSub.hasInternet();
  }

  static Stream<bool> internetStream() {
    return ConnectivityUtilsSub.internetStream();
  }
}
