import 'package:flib/common/system/app_info/app_info_utils.dart';

Future<PackageInfo> getPackage() async {
  return PackageInfo(
      appName: "yunitalk",
      packageName: "com.uneed.yunitalk",
      version: "1.0",
      buildNumber: "",
      buildSignature: "",
      platform: "flutter",
      installerStore: "");
}

