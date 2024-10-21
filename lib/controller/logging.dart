import 'dart:io';

import 'package:flutter/foundation.dart';

import 'bases.dart';

class LogItem {
  final LogLevel level;
  final String title;
  final String content;
  final DateTime time = DateTime.now();

  @override
  toString() => "${level.name} $title $time \n$content\n\n";

  LogItem(this.level, this.title, this.content);
}

enum LogLevel {
  error(0),
  warning(1),
  info(2),
  ;

  final int value;

  const LogLevel(this.value);
}

class Log {
  static final List<LogItem> _logs = <LogItem>[];

  static List<LogItem> get logs => _logs;

  static const maxLogLength = 5000;

  static const maxLogNumber = 500;

  static bool ignoreLimitation = false;

  static LogLevel dFlag = LogLevel.error;

  /// only for debug
  static String? logFile;

  static Future<void> init() async {
    Log.dFlag = LogLevel.warning;
    logFile = "${BasePath.dataPath}/log.txt";
    var file = File(logFile!);
    if (!await file.exists()) {
      await file.create();
    }
  }

  static void printWarning(String text) {
    if (kDebugMode) {
      print('\x1B[33m$text\x1B[0m');
    }
  }

  static void printError(String text) {
    if (kDebugMode) {
      print('\x1B[31m$text\x1B[0m');
    }
  }

  static void addLog(LogLevel level, String title, String content) {
    if (!ignoreLimitation && content.length > maxLogLength) {
      content = "${content.substring(0, maxLogLength)}...";
    }

    if (dFlag.value >= level.value) {
      switch (level) {
        case LogLevel.error:
          printError(content);
        case LogLevel.warning:
          printWarning(content);
        case LogLevel.info:
          if (kDebugMode) {
            print(content);
          }
      }
    }

    var newLog = LogItem(level, title, content);

    if (newLog == _logs.lastOrNull) {
      return;
    }

    _logs.add(newLog);
    if (logFile != null) {
      File(logFile!).writeAsString(newLog.toString(), mode: FileMode.append);
    }
    if (_logs.length > maxLogNumber) {
      var res = _logs.remove(
          _logs.firstWhere((element) => element.level == LogLevel.info));
      if (!res) {
        _logs.removeAt(0);
      }
    }
  }

  static info(String title, String content) {
    addLog(LogLevel.info, title, content);
  }

  static warning(String title, String content) {
    addLog(LogLevel.warning, title, content);
  }

  static error(String title, String content) {
    addLog(LogLevel.error, title, content);
  }

  static void clear() => _logs.clear();

  @override
  String toString() {
    var res = "Logs\n\n";
    for (var log in _logs) {
      res += log.toString();
    }
    return res;
  }
}

void logger(String msg) => Log.info("App", msg);
void loggerError(String msg) => Log.error("App", msg);

void netErrLog(String msg) => Log.error("Network", msg);

void netInfoLog(String msg) => Log.info("Network", msg);
