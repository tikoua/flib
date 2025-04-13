// AppInfo 使用 JSON 存储
// "app_info": {"app": "yuni_talk", "platform": "Android", "version": "0.9.0"}
class AppInfo {
  final String appName;
  final String packageName;
  final String appPlatform;

  final String appVersion;
  final String buildNumber;
  AppInfo(
      {required this.appName,
      required this.packageName,
      required this.appPlatform,
      required this.appVersion,
      required this.buildNumber});

  toJson() {
    return {
      "app_name": appName,
      "app_platform": appPlatform,
      "app_version": appVersion,
      "build_number": buildNumber
    };
  }
}
