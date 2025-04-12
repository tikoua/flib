//获取deviceInfo的工具类(用于纯dart环境使用，比如命令行)

import 'package:flib/common/system/device/device_info.dart';
import 'package:flib/db/db_kit.dart';

class DeviceInfoUtilsSub {
  static Future<DeviceInfo> readDeviceInfo(DbKit dbKIt) async {
    return Future.value(DeviceInfo(
        deviceId: "UKQ1.230804.001",
        deviceName: "2211133C",
        deviceType: "Android",
        sdkVersion: "34",
        deviceSystemVersion: "14"));
  }
}
