import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flib/common/system/device/device_info.dart';
import 'package:flib/db/db_kit.dart';
import 'package:uuid/uuid.dart';

//获取deviceInfo的工具类
//获取deviceInfo的工具类
class DeviceInfoUtilsSub {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  //切换到imlib之后，deviceId保存于dbKit中，使用这个key
  static const String _deviceIdKey = "imlib.cache.device_id";

  //iod video 0.22版本之前，将DeviceId缓存在 [FlutterSecureStorage] 中
  static const _secureStorage = FlutterSecureStorage();

  //与你视频中0.22之后的版本中，将DeviceId缓存在这个key中的
  static const String _videoDeviceIdKeyAfter022 = "upx.cache.device_id";

  //在ios0.22之前的版本中是将DeviceId缓存在这个key中的
  static const _videoIosDeviceIdKeyBefore022 = 'device_id_key';

  static Future<DeviceInfo> readDeviceInfo(DbKit dbKIt) async {
    DeviceInfo deviceInfo;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        deviceInfo =
            await _readAndroidInfo(dbKIt, await deviceInfoPlugin.androidInfo);
        break;
      case TargetPlatform.iOS:
        deviceInfo = await _readIosInfo(dbKIt, await deviceInfoPlugin.iosInfo);
        break;
      case TargetPlatform.macOS:
        deviceInfo =
            await _readMacOsInfo(dbKIt, await deviceInfoPlugin.macOsInfo);
        break;
      case TargetPlatform.windows:
        deviceInfo =
            await _readWindowsInfo(dbKIt, await deviceInfoPlugin.windowsInfo);
        break;

      default:
        if (kIsWeb) {
          var webInfo = await deviceInfoPlugin.webBrowserInfo;
          deviceInfo = await _readWebInfo(dbKIt, webInfo);
        } else {
          deviceInfo = DeviceInfo(
              deviceType: "Unknown",
              deviceSystemVersion: "Unknown",
              deviceName: "Unknown",
              deviceId: "Unknown");
        }
        break;
    }
    return Future.value(deviceInfo);
  }

  //从 AndroidDeviceInfo 中读取设备信息
  static Future<DeviceInfo> _readAndroidInfo(
      DbKit dbKIt, AndroidDeviceInfo androidDeviceInfo) async {
    var system = "ANDROID";
    var version = androidDeviceInfo.version;
    return DeviceInfo(
      deviceType: system,
      deviceSystemVersion: version.release,
      deviceName: androidDeviceInfo.model,
      deviceId: await _makeDeviceId(dbKIt, androidDeviceInfo.id),
      display: version.incremental,
      sdkVersion: version.sdkInt.toString(),
    );
  }

  //从 IosDeviceInfo 中读取设备信息
  static Future<DeviceInfo> _readIosInfo(
      DbKit dbKIt, IosDeviceInfo iosDeviceInfo) async {
    var deviceId =
        await _makeDeviceId(dbKIt, iosDeviceInfo.identifierForVendor);
    return DeviceInfo(
      deviceType: "IOS",
      deviceSystemVersion: iosDeviceInfo.systemVersion,
      deviceName: iosDeviceInfo.utsname.machine,
      display: "${iosDeviceInfo.systemName}.${iosDeviceInfo.systemVersion}",
      deviceId: deviceId,
    );
  }

  // 从 MacOsDeviceInfo 中读取设备信息
  static Future<DeviceInfo> _readMacOsInfo(
      DbKit dbKIt, MacOsDeviceInfo macOsDeviceInfo) async {
    return DeviceInfo(
      deviceType: "MAC",
      deviceSystemVersion:
          "${macOsDeviceInfo.majorVersion}.${macOsDeviceInfo.minorVersion}.${macOsDeviceInfo.patchVersion}",
      deviceName: macOsDeviceInfo.model,
      deviceId: await _makeDeviceId(dbKIt, macOsDeviceInfo.systemGUID),
    );
  }

  // 从 WindowsDeviceInfo 中读取设备信息
  static Future<DeviceInfo> _readWindowsInfo(
      DbKit dbKIt, WindowsDeviceInfo windowsDeviceInfo) async {
    return DeviceInfo(
        deviceType: "WINDOWS",
        deviceSystemVersion:
            "${windowsDeviceInfo.majorVersion}.${windowsDeviceInfo.minorVersion}",
        deviceName: windowsDeviceInfo.deviceId,
        deviceId: await _makeDeviceId(dbKIt, windowsDeviceInfo.deviceId));
  }

  //从 WebBrowserInfo 中读取设备信息
  static _readWebInfo(DbKit dbKIt, WebBrowserInfo webInfo) async {
    return DeviceInfo(
      deviceName: webInfo.browserName.name, // 浏览器名称
      deviceType: webInfo.userAgent?.toUpperCase(), // 浏览器的 userAgent 字符串
      deviceSystemVersion: webInfo.appVersion, // 浏览器的版本信息
      deviceId: await _makeDeviceId(dbKIt, webInfo.vendor), // 浏览器厂商信息
    );
  }

  ///根据设备id获取 device id;
  ///优先使用上次生成的。
  ///需注意兼容之前使用upx获取deviceId的各个版本
  static Future<String> _makeDeviceId(
      DbKit dbKit, String? originDeviceId) async {
    ///尝试获取缓存的device_id
    var cacheDeviceId = await _readCacheDeviceId(dbKit);
    if (cacheDeviceId != null && cacheDeviceId.isNotEmpty) {
      //如果有缓存的deviceId，则使用缓存的deviceId
      return cacheDeviceId;
    }
    //如果没有读取到缓存的deviceId，则尝试从keyChain中读取之前版本保存的deviceId
    var deviceId =
        await _secureStorage.read(key: _videoIosDeviceIdKeyBefore022);
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = await _secureStorage.read(key: _videoDeviceIdKeyAfter022);
    }
    if (deviceId != null) {
      await _saveDeviceId(dbKit, deviceId); //将0.22之前版本保存的deviceId保存到debKit中
      await _secureStorage.delete(
          key: _videoIosDeviceIdKeyBefore022); //删除0.22之前版本保存的deviceId
      await _secureStorage.delete(
          key: _videoDeviceIdKeyAfter022); //删除0.22之后版本保存的deviceId
      return deviceId;
    }

    ///根据可能读取到设备的device id,生成与你使用的device id，确保唯一.
    var createdDeviceId = _createAndSaveDeviceId(dbKit, originDeviceId);
    return createdDeviceId;
  }

  ///读取保存的deviceId
  static Future<String?> _readCacheDeviceId(DbKit dbKit) async {
    return dbKit.getGlobal<String>(_deviceIdKey);
  }

  ///生成并保存deviceId
  static Future<String> _createAndSaveDeviceId(
      DbKit dbKit, String? originDeviceId) async {
    var createdDeviceId = "${originDeviceId ?? 'unknown'}_${Uuid().v4()}";
    await _saveDeviceId(dbKit, createdDeviceId);
    return createdDeviceId;
  }

  ///保存deviceId
  static Future<void> _saveDeviceId(DbKit dbKit, String deviceId) async {
    await dbKit.putGlobal(_deviceIdKey, deviceId);
  }
}
