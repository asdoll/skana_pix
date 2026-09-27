import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skana_pix/controller/bases.dart';
import 'package:skana_pix/controller/caches.dart';
import 'package:skana_pix/controller/logging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:skana_pix/controller/settings.dart';
import 'package:skana_pix/model/illust.dart';
import 'package:skana_pix/utils/launch.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/rate_limit.dart';
import 'safplugin.dart';

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

void removeUserData() {
  var dataFile = File(BasePath.accountJsonPath);
  if (dataFile.existsSync()) {
    dataFile.deleteIfExists();
  }
}

void saveFile(File file, [String? name]) async {
  if (!GetPlatform.isMobile) {
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

/// Chain used to serialise saves to the system gallery.
Future<void> _saveChain = Future<void>.value();

/// Saves one image to the system gallery, queueing it behind pending saves.
///
/// The HarmonyOS implementation of image_gallery_saver_plus rejects overlapping
/// calls with a `Busy` PlatformException, and every save may wait for a system
/// confirmation dialog, so saves triggered from the UI are serialised here
/// instead of racing each other.
Future<void> _saveToGallery(Uint8List bytes, String name,
    {String? successMessage}) {
  final Future<void> previous = _saveChain;
  final Future<void> queued = () async {
    await previous;
    try {
      // HarmonyOS treats `name` as the asset *title* and adds its own extension,
      // so the extension has to go (see _galleryTitle).
      final String title = isOhos ? _galleryTitle(name) : name;
      log.w("saving to gallery: $title (from '$name', ${bytes.length} bytes)");
      final dynamic result = await _rawSave(bytes, title)
          // A save waits for a system confirmation dialog. If the platform never
          // answers, report it instead of blocking the queue forever.
          .timeout(const Duration(seconds: 90));
      // Reported shape is {filePath, errorMessage, isSuccess}; a missing
      // isSuccess (e.g. an empty response) is treated as a failure below.
      log.w("gallery save result: $result");
      final bool ok = result is Map && result['isSuccess'] == true;
      Leader.showToast(ok ? (successMessage ?? "Saved".tr) : "Save failed".tr);
    } catch (e, s) {
      log.e("failed to save image to gallery: $e", error: "$s");
      Leader.showToast("Save failed".tr);
    }
  }();
  _saveChain = queued;
  return queued;
}

/// Characters the media library rejects in a [PhotoCreationConfig.title].
const List<String> _invalidTitleChars = [
  r'\',
  '/',
  ':',
  '*',
  '?',
  '"',
  "'",
  '`',
  '<',
  '>',
  '|',
  '{',
  '}',
  '[',
  ']',
];

/// Turns a file name into a title HarmonyOS accepts.
///
/// `PhotoCreationConfig.title` must not contain a file name extension (the
/// extension is passed separately as `fileNameExtension`) and must not contain
/// any of `\ / : * ? " ' ` < > | { } [ ]`. A title that breaks those rules makes
/// `showAssetsCreationDialog` fail silently - no confirmation dialog is shown at
/// all and nothing gets saved.
String _galleryTitle(String fileName) {
  var title = fileName;
  final int dot = title.lastIndexOf('.');
  if (dot > 0) {
    title = title.substring(0, dot);
  }
  for (final String invalid in _invalidTitleChars) {
    title = title.replaceAll(invalid, '_');
  }
  if (title.isEmpty) {
    title = DateTime.now().millisecondsSinceEpoch.toString();
  }
  return title;
}

Future<dynamic> _rawSave(Uint8List bytes, String name) async =>
    ImageGallerySaverPlus.saveImage(bytes, quality: 100, name: name);

/// Images whose save is currently being prepared, so repeated taps on the same
/// image do not re-download it.
final Set<String> _savingUrls = <String>{};

/// Attempts allowed while fetching an image for saving.
///
/// Deliberately small: this is a user triggered action, and pixiv rate limits
/// the image hosts too.
const int _maxSaveDownloadAttempts = 2;

/// Downloads [url] and hands the bytes to the gallery.
Future<void> _saveRemoteImage(String url, String fileName,
    {String? successMessage}) async {
  if (!_savingUrls.add(url)) {
    log.w("a save for $url is already in flight, ignoring duplicate request");
    return;
  }
  try {
    final Uint8List bytes = await _downloadForSave(url);
    await _saveToGallery(bytes, fileName, successMessage: successMessage);
  } catch (e, s) {
    log.e("failed to prepare $url for saving: $e", error: "$s");
    Leader.showToast("Save failed".tr);
  } finally {
    _savingUrls.remove(url);
  }
}

/// Fetches the image bytes with a capped number of attempts.
///
/// A rate limit is never retried - hammering the host while it is throttling
/// only makes the block last longer.
Future<Uint8List> _downloadForSave(String url) async {
  Object? lastError;
  for (int attempt = 1; attempt <= _maxSaveDownloadAttempts; attempt++) {
    try {
      final file = await imagesCacheManager.getSingleFile(url);
      if (file.existsSync()) {
        return file.readAsBytes();
      }
      lastError = Exception("cached file for $url does not exist");
    } catch (e) {
      lastError = e;
    }
    if (looksRateLimited(lastError)) {
      log.w("not retrying $url, the host is rate limiting us");
      break;
    }
    log.w(
        "save: attempt $attempt/$_maxSaveDownloadAttempts for $url failed: $lastError");
    if (attempt < _maxSaveDownloadAttempts) {
      await Future.delayed(Duration(milliseconds: 300 * attempt));
    }
  }
  throw lastError ?? Exception("failed to load $url");
}

void saveUrl(String url, {String? filenm}) async {
  if (GetPlatform.isIOS && (await Permission.photosAddOnly.status.isDenied)) {
    if (await Permission.storage.request().isDenied) {
      Leader.showToast("Permission denied".tr);
      return;
    }
  }
  if (url.isEmpty) {
    return;
  }
  var fileName = filenm ?? url.split('/').last;
  if (!fileName.contains('.')) {
    fileName += getExtensionName(url);
  }
  await _saveRemoteImage(url, fileName);
}

void saveImage(Illust illust, {List<bool>? indexes, String? quality}) async {
  if (GetPlatform.isIOS && (await Permission.photosAddOnly.status.isDenied)) {
    if (await Permission.storage.request().isDenied) {
      Leader.showToast("Permission denied".tr);
      return;
    }
  }
  for (int i = 0; i < illust.images.length; i++) {
    if (indexes != null && !indexes[i]) {
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
    var fileName = url.split('/').last;
    if (!fileName.contains('.')) {
      fileName += getExtensionName(url);
    }
    await _saveRemoteImage(url, fileName,
        successMessage: "${illust.title} ${"Saved".tr}");
  }
}

String trimSize(String? s, [int length = 20]) {
  if (s == null) {
    return "";
  }
  if (s.length > length) {
    return "${s.substring(0, length)}...";
  }
  return s;
}

Future<void> importSettings() async {
  final result = await SAFPlugin.openFile();
  if (result == null) return;
  final json = utf8.decode(result);
  final decoder = JsonDecoder();
  final map = decoder.convert(json);
  settings.setFromMap(map);
  Leader.showToast("Imported".tr);
}

Future<void> exportSettings() async {
  final json = settings.toJson();
  final result =
      await SAFPlugin.createFile("settings.json", "application/json");
  Leader.showToast(result ?? "empty");
  if (result == null) return;
  await SAFPlugin.writeUri(result, utf8.encode(json));
  Leader.showToast("Exported".tr);
}

Future<void> resetSettings() async {
  settings.clearSettings();
  Leader.showToast("Reseted".tr);
}

Uri toTrueUri(Uri uri) {
  if (settings.imageHost == 0) {
    return uri;
  } else {
    if (settings.imageHost == 2 &&
        !imageHost.contains(settings.customProxyHost)) {
      try {
        if (settings.customProxyHost.contains('/')) {
          return Uri.parse(
              uri.toString().replaceAll(uri.host, settings.customProxyHost));
        }
        return uri.replace(host: settings.customProxyHost);
      } catch (e) {}
    }
    if (settings.imageHost == 1) {
      return uri.replace(host: imageHost[1]);
    }
  }
  return uri;
}

const imageHost = ["i.pximg.net", "i.pixiv.re", "s.pximg.net"];
