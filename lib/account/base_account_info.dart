class BaseAccountInfo {
  static const String logStateLogged = 'logged';
  static const String logStateLoggedOut = 'logged_out';
  final String uid;
  String logState;
  final String rawData;

  BaseAccountInfo({
    required this.uid,
    required this.logState,
    required this.rawData,
  });

  factory BaseAccountInfo.fromDb(Map<String, dynamic> map) {
    return BaseAccountInfo(
      uid: map['uid'],
      logState: map['log_state'],
      rawData: map['raw_data'],
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'uid': uid,
      'log_state': logState,
      'raw_data': rawData,
    };
  }

  bool isLogged() {
    return logState == logStateLogged;
  }

  bool isLoggedOut() {
    return logState == logStateLoggedOut;
  }
}
