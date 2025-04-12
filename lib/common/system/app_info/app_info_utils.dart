import 'package:flib/common/system/app_info/app_info_dart.dart'
    if (dart.library.ui) 'package:flib/common/system/app_info/app_info_flutter.dart';

///获取App信息
Future<AppInfo> getAppInfo() async {
  PackageInfo packageInfo = await getPackage();
  return AppInfo(
      packageName: packageInfo.packageName,
      appName: packageInfo.appName,
      appPlatform: packageInfo.platform,
      buildNumber: packageInfo.buildNumber,
      appVersion: packageInfo.version);
}

class PackageInfo {
  final String appName;
  final String packageName;
  final String version;
  final String buildNumber;
  final String buildSignature;
  final String? installerStore;
  final String platform;
  PackageInfo({
    required this.appName,
    required this.packageName,
    required this.version,
    required this.buildNumber,
    required this.platform,
    this.buildSignature = '',
    this.installerStore,
  });
}
