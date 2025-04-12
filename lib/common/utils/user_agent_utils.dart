

import 'package:flib/common/system/app_info/app_info_utils.dart';
import 'package:flib/common/system/device/device_info_utils.dart';
import 'package:flib/db/db_kit.dart';

class UserAgentUtils {
  UserAgentUtils._();

  //UneedGroup/4.7.7.11 ANDROID/14 Channel/Xiaomi (2211133C;Release;Build250103;Rom_MIUI.V816)
  // 3cacc853b6c13284
  static String? _ua;

  static Future<String> getUserAgent(DbKit dbKit) async {
    var cacheUa = _ua;
    if (cacheUa != null) {
      return cacheUa;
    }
    var appInfo = await getAppInfo();
    var deviceInfo = await DeviceInfoUtils.getDeviceInfo(dbKit);
    var packageName = appInfo.packageName;
    String appName;
    if (packageName.contains('.')) {
      appName = packageName.substring(packageName.lastIndexOf('.') + 1);
    } else {
      appName = packageName;
    }
    var ua =
        "${appName.toUpperCase()}/${appInfo.appVersion} ${deviceInfo.deviceType}/${deviceInfo.deviceSystemVersion} Channel/Yuni (${deviceInfo.deviceName};Release;Build${appInfo.buildNumber};Rom_${deviceInfo.display})";
    _ua = ua;
    return ua;
  }
}
