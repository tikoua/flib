import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flib/common/system/connect/connectivity_result.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

///用于支持flutter平台
class ConnectivityUtilsSub {
  static Future<List<ConnectResult>> getConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return _mapInfo(connectivityResult);
  }

  static Stream<List<ConnectResult>> connectivityStream() {
    return Connectivity()
        .onConnectivityChanged
        .map((source) => _mapInfo(source));
  }

  static List<ConnectResult> _mapInfo(List<ConnectivityResult> source) {
    return source.map((e) {
      switch (e) {
        case ConnectivityResult.wifi:
          return ConnectResult.wifi;
        case ConnectivityResult.mobile:
          return ConnectResult.mobile;
        case ConnectivityResult.ethernet:
          return ConnectResult.ethernet;
        case ConnectivityResult.bluetooth:
          return ConnectResult.bluetooth;
        case ConnectivityResult.none:
          return ConnectResult.none;
        case ConnectivityResult.vpn:
          return ConnectResult.vpn;
        default:
          return ConnectResult.none;
      }
    }).toList();
  }

  static Future<bool> hasInternet() async {
    if (Platform.isIOS) {
      return InternetConnection().hasInternetAccess;
    }
    return getConnectivity().then((result) =>
        result.contains(ConnectResult.mobile) ||
        result.contains(ConnectResult.wifi));
  }

  static Stream<bool> internetStream() {
    if (Platform.isIOS) {
      return InternetConnection()
          .onStatusChange
          .map((e) => e == InternetStatus.connected);
    }
    return connectivityStream().map((event) =>
        event.contains(ConnectResult.mobile) ||
        event.contains(ConnectResult.wifi));
  }
}
