class BaseAccountInfo {
  static const _logStateLogged = 'logged';
  static const _logStateLoggedOut = 'logged_out';
  String uid;
  String logState;
  String rawData;

  BaseAccountInfo({
    required this.uid,
    required this.logState,
    required this.rawData,
  });

  factory BaseAccountInfo.fromDb(Map<String, dynamic> json) {
    return BaseAccountInfo(
      uid: json['uid'],
      logState: json['logState'],
      rawData: json['rawData'],
    );
  }

  Map<String, dynamic> toDb() {
    return {'uid': uid, 'logState': logState, 'rawData': rawData};
  }

  bool isLogged() {
    return logState == _logStateLogged;
  }

  bool isLoggedOut() {
    return logState == _logStateLoggedOut;
  }
}
