
import 'package:flib/common/system/connect/connectivity_result.dart';

///用于支持非flutter
class ConnectivityUtilsSub {
  static Future<List<ConnectResult>> getConnectivity() async {
    return [ConnectResult.wifi];
  }

  static Stream<List<ConnectResult>> connectivityStream() {
    return Stream.value([ConnectResult.wifi]);
  }

  static Future<bool> hasInternet() async {
    return true;
  }

  static Stream<bool> internetStream() {
    return Stream.value(true);
  }
}
