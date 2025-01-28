import 'dart:io';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';
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
      headers: [
        AppBar(
          title: Text("App Data".tr),
        ),
      ],
      child: ListView(children: [
        Text(
          "Import".tr,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        InkWell(
          onTap: () {
            importSettings();
          },
          child: Basic(
            title: Text("Import settings,blocks and bookmarked tags".tr),
          ),
        ),
        InkWell(
          onTap: () {
            historyManager.importIllustData();
          },
          child: Basic(
            title: Text("Import Illust History".tr),
          ),
        ),
        InkWell(
          onTap: () {
            historyManager.importNovelData();
          },
          child: Basic(
            title: Text("Import Novel History".tr),
          ),
        ),
        Divider(),
        Text(
          "Export".tr,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        InkWell(
          onTap: () {
            exportSettings();
          },
          child: Basic(
            title: Text("Export settings,blocks and bookmarked tags".tr),
          ),
        ),
        InkWell(
          onTap: () {
            historyManager.exportIllustData();
          },
          child: Basic(
            title: Text("Export Illust History".tr),
          ),
        ),
        InkWell(
          onTap: () {
            historyManager.exportNovelData();
          },
          child: Basic(
            title: Text("Export Novel History".tr),
          ),
        ),
        Divider(),
        Text(
          "Reset".tr,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        InkWell(
          onTap: () {
            resetSettings();
          },
          child: Basic(
            title: Text("Reset settings,blocks and bookmarked tags".tr),
          ),
        ),
        InkWell(
          onTap: () {
            historyManager.clearIllusts();
            Leader.showToast("Cleared".tr);
          },
          child: Basic(
            title: Text("Clear Illust History".tr),
          ),
        ),
        InkWell(
          onTap: () {
            historyManager.clearNovels();
            Leader.showToast("Cleared".tr);
          },
          child: Basic(
            title: Text("Clear Novel History".tr),
          ),
        ),
        InkWell(
          onTap: () {
            _showClearCacheDialog(context);
          },
          child: Basic(
            title: Text("Clear Cache".tr),
          ),
        ),
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
                  Get.back(result: "CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".tr),
                onPressed: () {
                  Get.back(result: "OK");
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
