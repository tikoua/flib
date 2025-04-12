
/// 日志级别枚举
enum LogLevel {
  debug,
  info,
  warning,
  error,
  none,
}

/// 日志配置类
class LoggerConfig {
  /// 全局日志开关
  static bool enabled = true;
  
  /// 全局最小日志级别
  static LogLevel minLevel = LogLevel.debug;
  
  /// 是否显示时间戳
  static bool showTimestamp = true;
  
  /// 是否显示日志级别
  static bool showLevel = true;
}

/// 层级化日志记录类
class Logger {
  final String tag;
  final String? parentTag;
  
  /// 创建一个新的Logger实例
  /// [tag] 当前组件的标签
  /// [parentTag] 父组件的标签（可选）
  Logger(this.tag, {this.parentTag});
  
  /// 创建一个子Logger
  Logger child(String childTag) {
    final fullParentTag = parentTag != null ? '$parentTag.$tag' : tag;
    return Logger(childTag, parentTag: fullParentTag);
  }

  String get _fullTag => parentTag != null ? '$parentTag.$tag' : tag;

  void _log(LogLevel level, String message) {
    if (!LoggerConfig.enabled || level.index < LoggerConfig.minLevel.index) {
      return;
    }

    final buffer = StringBuffer();
    
    if (LoggerConfig.showTimestamp) {
      buffer.write('${DateTime.now().toIso8601String()} ');
    }
    
    if (LoggerConfig.showLevel) {
      buffer.write('${level.toString().toUpperCase()} ');
    }
    
    buffer.write('[$_fullTag] $message');
    print(buffer.toString());
  }

  void debug(String message) {
    _log(LogLevel.debug, message);
  }

  void info(String message) {
    _log(LogLevel.info, message);
  }

  void warning(String message) {
    _log(LogLevel.warning, message);
  }

  void error(String message) {
    _log(LogLevel.error, message);
  }
} 