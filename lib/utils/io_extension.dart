import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:skana_pix/componentwidgets/message.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';


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
    } else if (this is Directory) {
      var size = 0;
      for (var file in (this as Directory).listSync()) {
        size += file.size;
      }
      return size;
    }
    return 0;
  }
}

extension DirectoryExt on Directory {
  bool havePermission() {
    if (!existsSync()) return false;
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

extension TimeExts on DateTime {
    String toShortTime() {
    try {
      var formatter = DateFormat('yyyy-MM-dd HH:mm');
      return formatter.format(toLocal());
    } catch (e) {
      return toString();
    }
  }
}

String bytesToText(int bytes) {
  if (bytes < 1024) {
    return "$bytes B";
  } else if (bytes < 1024 * 1024) {
    return "${(bytes / 1024).toStringAsFixed(2)} KB";
  } else if (bytes < 1024 * 1024 * 1024) {
    return "${(bytes / 1024 / 1024).toStringAsFixed(2)} MB";
  } else {
    return "${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB";
  }
}

bool isDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

ThemeData getTheme(BuildContext context) {
  return isDarkMode(context) ? DynamicData.darkTheme : DynamicData.themeData;
}

void moveUserData() {
  var dataFile = File(BasePath.accountJsonPath);
  if (dataFile.existsSync()) {
    dataFile.renameSync("${BasePath.dataPath}/account2.json");
  }
}

void putBackUserData() {
  var dataFile = File("${BasePath.dataPath}/account2.json");
  if (dataFile.existsSync()) {
    dataFile.renameSync(BasePath.accountJsonPath);
  }
}

void saveFile(File file, [String? name]) async {
  if (!DynamicData.isMobile) {
    var fileName = file.path.split('/').last;
    final FileSaveLocation? result =
        await getSaveLocation(suggestedName: name ?? fileName);
    if (result == null) {
      return;
    }

    final Uint8List fileData = await file.readAsBytes();
    String mimeType = 'image/${fileName.split('.').last}';
    final XFile textFile =
        XFile.fromData(fileData, mimeType: mimeType, name: name ?? fileName);
    await textFile.saveTo(result.path);
  } else {
    final params =
        SaveFileDialogParams(sourceFilePath: file.path, fileName: name);
    await FlutterFileDialog.saveFile(params: params);
  }
}

String getExtensionName(String url) {
  var fileName = url.split('/').last;
  if (fileName.contains('.')) {
    return '.${fileName.split('.').last}';
  }
  return '.jpg';
}

void saveImage(Illust illust,
    {List<bool>? indexes, BuildContext? context, String? quality}) async {
  if (DynamicData.isIOS && (await Permission.photosAddOnly.status.isDenied)) {
    if (await Permission.storage.request().isDenied && context != null) {
      showToast(context, message: "Permission denied".i18n);
      return;
    }
  }
  for (int i = 0; i < illust.images.length; i++) {
    if(indexes!=null && !indexes[i]) {
      continue;
    }
    var image = illust.images[i];
    String url = "";
    switch (quality) {
      case "original":
        url = (image.original);
        break;
      case "large":
        url = (image.large);
        break;
      case "medium":
        url = (image.medium);
        break;
      case "square_medium":
        url = (image.squareMedium);
        break;
      default:
        url = (image.original);
    }
    if (url.isEmpty) {
      continue;
    }
    var file = await imagesCacheManager.getSingleFile(url);
    if (file.existsSync()) {
      var fileName = url.split('/').last;
      if (!fileName.contains('.')) {
        fileName += getExtensionName(url);
      }
      await ImageGallerySaverPlus.saveImage(await file.readAsBytes(),
          quality: 100, name: fileName);
      if (context!=null) {
        showToast(context, message: "${illust.title} ${"Saved".i18n}");
      }
    }
  }
}
