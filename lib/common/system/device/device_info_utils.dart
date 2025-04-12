import 'package:flib/common/system/device/device_info.dart';
import 'package:flib/common/system/device/device_info_dart.dart'
    if (dart.library.ui) 'package:flib/common/system/device/device_info_flutter.dart';
import 'package:flib/db/db_kit.dart';

//获取deviceInfo的工具类
class DeviceInfoUtils {
  static const String keyDeviceId = "ime_lib.device.device_id";

  DeviceInfoUtils._();

  ///调用方法之前需要先调用 init
  static Future<DeviceInfo> getDeviceInfo(DbKit dbKit) async {
    return DeviceInfoUtilsSub.readDeviceInfo(dbKit);
  }
}
