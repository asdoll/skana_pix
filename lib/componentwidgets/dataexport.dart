import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class DataExport extends StatefulWidget {
  const DataExport({super.key});

  @override
  State<DataExport> createState() => _DataExportState();
}

class _DataExportState extends State<DataExport> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Data".tr),
      ),
      body: ListView(children: [
        Text(
          "Import".tr,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        ListTile(
            title: Text("Import settings,blocks and bookmarked tags".tr),
            onTap: () {
              importSettings();
            }),
        ListTile(
            title: Text("Import Illust History".tr),
            onTap: () {
              historyManager.importIllustData();
            }),
        ListTile(
            title: Text("Import Novel History".tr),
            onTap: () {
              historyManager.importNovelData();
            }),
        Divider(),
        Text(
          "Export".tr,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        ListTile(title: Text("Export settings,blocks and bookmarked tags".tr), onTap: () {
          exportSettings();
        }),
        ListTile(title: Text("Export Illust History".tr), onTap: () {
          historyManager.exportIllustData();
        }),
        ListTile(title: Text("Export Novel History".tr), onTap: () {
          historyManager.exportNovelData();
        }),
        Divider(),
        Text(
          "Reset".tr,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        ListTile(title: Text("Reset settings,blocks and bookmarked tags".tr), onTap: () {
          resetSettings();

        }),
        ListTile(title: Text("Clear Illust History".tr), onTap: () {
          historyManager.clearIllusts();
          BotToast.showText(text: "Cleared".tr);
        }),
        ListTile(title: Text("Clear Novel History".tr), onTap: () {
          historyManager.clearNovels();
          BotToast.showText(text: "Cleared".tr);
        }),
        ListTile(title: Text("Clear Cache".tr), onTap: () {
          _showClearCacheDialog(context);
        }),
      ]).paddingAll(8),
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Clear All Cache".tr),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".tr),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".tr),
                onPressed: () {
                  Navigator.of(context).pop("OK");
                },
              ),
            ],
          );
        },
        context: context);
    switch (result) {
      case "OK":
        {
          try {
            Directory tempDir = await getTemporaryDirectory();
            tempDir.deleteSync(recursive: true);
          } catch (e) {}
        }
        break;
    }
  }
}
