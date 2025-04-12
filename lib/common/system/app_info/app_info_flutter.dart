import 'dart:io';

import 'package:flib/common/system/app_info/app_info_utils.dart';
import 'package:package_info_plus/package_info_plus.dart' as fl_package;

Future<PackageInfo> getPackage() async {
  fl_package.PackageInfo packageInfo =
      await fl_package.PackageInfo.fromPlatform();
  String platform;
  if (Platform.isAndroid) {
    platform = "Android";
  } else if (Platform.isIOS) {
    platform = "iOS";
  } else if (Platform.isMacOS) {
    platform = "Mac";
  } else if (Platform.isWindows) {
    platform = "Windows";
  } else {
    platform = "Unknown";
  }
  return PackageInfo(
      appName: packageInfo.appName,
      packageName: packageInfo.packageName,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      buildSignature: packageInfo.buildSignature,
      installerStore: packageInfo.installerStore,
      platform: platform);
}
