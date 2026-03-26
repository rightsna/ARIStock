import 'package:flutter/foundation.dart';

/// AriFramework 규격을 준수하는 글로벌 로그 서비스입니다.
class LogProvider {
  static void info(String tag, String message) {
    debugPrint('[$tag] 🟢 INFO: $message');
  }

  static void debug(String tag, String message) {
    debugPrint('[$tag] 🔵 DEBUG: $message');
  }

  static void error(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[$tag] 🔴 ERROR: $message');
    if (error != null) debugPrint('Error detail: $error');
    if (stackTrace != null) debugPrint(stackTrace.toString());
  }

  static void warn(String tag, String message) {
    debugPrint('[$tag] 🟠 WARN: $message');
  }
}
