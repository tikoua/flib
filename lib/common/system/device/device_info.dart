class DeviceInfo {
  final String? deviceName;

  final String? deviceType;

  final String? deviceSystemVersion;

  //目前是Android特有的字段
  final String? sdkVersion;
  final String? deviceId;
  final String? display;

  DeviceInfo(
      {this.deviceName,
      this.deviceType,
      this.deviceSystemVersion,
      this.deviceId,
      this.sdkVersion,
      this.display});

  Map<String, dynamic> toJson() {
    return {
      "model": deviceName,
      "system": deviceType,
      "version": deviceSystemVersion,
      "device_id": deviceId,
      "sdk_version": sdkVersion,
      "display": display,
    };
  }

  copyWith({
    String? deviceName,
    String? deviceType,
    String? deviceSystemVersion,
    String? deviceId,
    String? display,
  }) {
    return DeviceInfo(
      deviceName: deviceName ?? this.deviceName,
      deviceType: deviceType ?? this.deviceType,
      deviceSystemVersion: deviceSystemVersion ?? this.deviceSystemVersion,
      deviceId: deviceId ?? this.deviceId,
      display: display ?? this.display,
    );
  }
}