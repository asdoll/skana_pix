import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/utils/io_extension.dart';
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
      appBar: appBar(title: "App Data".tr),
      body: ListView(padding: EdgeInsets.zero, children: [
        Text("Import".tr).header().paddingAll(4),
        moonListTile(
          onTap: importSettings,
          title: "Import settings,blocks and bookmarked tags".tr,
        ),
        moonListTile(
          onTap: M.importIllustData,
          title: "Import Illust History".tr,
        ),
        moonListTile(
          onTap: M.importNovelData,
          title: "Import Novel History".tr,
        ),
        Text("Export".tr).header().paddingAll(4),
        moonListTile(
          onTap: exportSettings,
          title: "Export settings,blocks and bookmarked tags".tr,
        ),
        moonListTile(
          onTap: M.exportIllustData,
          title: "Export Illust History".tr,
        ),
        moonListTile(
          onTap: M.exportNovelData,
          title: "Export Novel History".tr,
        ),
        Text("Reset".tr).header().paddingAll(4),
        moonListTile(
          onTap: resetSettings,
          title: "Reset settings,blocks and bookmarked tags".tr,
        ),
        moonListTile(
          onTap: () {
            M.clearIllusts();
            Leader.showToast("Cleared".tr);
          },
          title: "Clear Illust History".tr,
        ),
        moonListTile(
          onTap: () {
            M.clearNovels();
            Leader.showToast("Cleared".tr);
          },
          title: "Clear Novel History".tr,
        ),
        moonListTile(
          onTap: () {
            _showClearCacheDialog(context);
          },
          title: "Clear Cache".tr,
        ),
      ]).paddingAll(8),
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await alertDialog(context, "Clear All Cache".tr, "", [
      outlinedButton(
        label: "Cancel".tr,
        onPressed: () {
          Get.back(result: "CANCEL");
        },
      ),
      filledButton(
        label: "Ok".tr,
        onPressed: () {
          Get.back(result: "OK");
        },
      )
    ]);
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
