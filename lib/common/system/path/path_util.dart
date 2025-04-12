import 'package:flib/common/system/path/path_util_dart.dart'
    if (dart.library.ui) 'package:flib/common/system/path/path_util_flutter.dart';

class PathUtil {
  static String join(
    String part1,
    String part2,
  ) {
    return PathUtilSub.join(part1, part2);
  }

  static Future<String> getApplicationDocumentsDirectory() {
    return PathUtilSub.getApplicationDocumentsDirectory();
  }
}
