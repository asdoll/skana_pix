import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:skana_pix/view/defaults.dart';

import '../controller/logging.dart';

class BoardInfo {
  BoardInfo({
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
  });

  String title;
  String content;
  String startDate;
  String? endDate;

  factory BoardInfo.fromJson(Map<String, dynamic> json) =>BoardInfo(
      title: json['title'] as String,
      content: json['content'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String?,
    );
  Map<String, dynamic> toJson() => <String, dynamic>{
      'title': title,
      'content': content,
      'startDate': startDate,
      'endDate': endDate,
    };
  
  static bool boardDataLoaded = false;
  
  static List<BoardInfo> boardList = [];

  static String path() {
    if (kDebugMode) {
      return "android.json";
    }
    if (DynamicData.isAndroid) {
      if (Constants.isGooglePlay) {
        return "android_play.json";
      }
      return "android.json";
    } else if (DynamicData.isIOS) {
      return "ios.json";
    }
    return "";
  }

  static Future<List<BoardInfo>> load() async {
    log.d(path());
    final request = await Dio().get(
        'https://raw.githubusercontent.com/asdoll/skana_pix/refs/heads/main/.github/board/${path()}');
    final list = (jsonDecode(request.data) as List)
        .map((e) => BoardInfo.fromJson(e))
        .toList();
    boardList = list;
    return list;
  }
}