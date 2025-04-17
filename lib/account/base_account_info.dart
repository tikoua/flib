class BaseAccountInfo {
  static const String logStateLogged = 'logged';
  static const String logStateLoggedOut = 'logged_out';
  final int? id;
  final String uid;
  String logState;
  final String serialization;

  BaseAccountInfo({
    this.id,
    required this.uid,
    required this.logState,
    required this.serialization,
  });

  factory BaseAccountInfo.fromDb(Map<String, dynamic> map) {
    return BaseAccountInfo(
      id: map['id'],
      uid: map['uid'],
      logState: map['log_state'],
      serialization: map['serialization'],
    );
  }

  Map<String, dynamic> toDb() {
    return {'uid': uid, 'log_state': logState, 'serialization': serialization};
  }

  bool isLogged() {
    return logState == logStateLogged;
  }

  bool isLoggedOut() {
    return logState == logStateLoggedOut;
  }
}
