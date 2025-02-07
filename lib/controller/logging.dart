import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logger = Logger();
final loggerNoStack = Logger(printer: PrettyPrinter(methodCount: 0));

// ignore: camel_case_types
class log {
  static void d(dynamic message) {
    logger.d(message);
  }

  static void i(dynamic message) {
    loggerNoStack.i(message);
  }

  static void w(dynamic message) {
    loggerNoStack.w(message);
  }

  static void e(dynamic message, {String? error}) {
    logger.e(message, error: error);
  }

  static void t(dynamic message) {
    loggerNoStack.t(message);
  }
}

void initLogger() {
  if (kDebugMode) {
    Logger.level = Level.debug;
  } else 
  {
    Logger.level = Level.warning;
  }
}
