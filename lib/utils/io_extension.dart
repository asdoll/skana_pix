import 'dart:io';

import 'package:flutter/material.dart';

import '../controller/bases.dart';
import '../view/defaults.dart';

extension FSExt on FileSystemEntity {
  Future<void> deleteIfExists() async {
    if (await exists()) {
      await delete();
    }
  }

  Future<void> deleteIgnoreError() async {
    try {
      await delete();
    } catch (e) {
      // ignore
    }
  }

  int get size {
    if (this is File) {
      return (this as File).lengthSync();
    } else if(this is Directory){
      var size = 0;
      for(var file in (this as Directory).listSync()){
        size += file.size;
      }
      return size;
    }
    return 0;
  }
}

extension DirectoryExt on Directory {
  bool havePermission() {
    if(!existsSync()) return false;
    // if(App.isMacOS) {
    //   return true;
    // }
    try {
      listSync();
      return true;
    } catch (e) {
      return false;
    }
  }
}

String bytesToText(int bytes) {
  if(bytes < 1024) {
    return "$bytes B";
  } else if(bytes < 1024 * 1024) {
    return "${(bytes / 1024).toStringAsFixed(2)} KB";
  } else if(bytes < 1024 * 1024 * 1024) {
    return "${(bytes / 1024 / 1024).toStringAsFixed(2)} MB";
  } else {
    return "${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB";
  }
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

ThemeData getTheme(BuildContext context) {
  return isDarkMode(context)?DynamicData.darkTheme:DynamicData.themeData;
}

void moveUserData(){
  var dataFile = File(BasePath.accountJsonPath);
  if(dataFile.existsSync()) {
    dataFile.renameSync("${BasePath.dataPath}/account2.json");
  }
}

void putBackUserData(){
  var dataFile = File("${BasePath.dataPath}/account2.json");
  if(dataFile.existsSync()) {
    dataFile.renameSync(BasePath.accountJsonPath);
  }
}