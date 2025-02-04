import 'dart:io';

import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/leaders.dart';

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
          padding: EdgeInsets.all(10),
          leading: [
            const NormalBackButton(),
          ],
        ),
        const Divider()
      ],
      child: ListView(padding: EdgeInsets.zero, children: [
        Text("Import".tr).h4().paddingAll(4),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: importSettings,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Import settings,blocks and bookmarked tags".tr),
            )),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: historyManager.importIllustData,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Import Illust History".tr),
            )),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: historyManager.importNovelData,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Import Novel History".tr),
            )),
        Text("Export".tr).h4().paddingAll(4),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: exportSettings,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Export settings,blocks and bookmarked tags".tr),
            )),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: historyManager.exportIllustData,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Export Illust History".tr),
            )),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: historyManager.exportNovelData,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Export Novel History".tr),
            )),
        Text("Reset".tr).h4().paddingAll(4),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: resetSettings,
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Reset settings,blocks and bookmarked tags".tr),
            )),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: () {
              historyManager.clearIllusts();
              Leader.showToast("Cleared".tr);
            },
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Clear Illust History".tr),
            )),
        Button(
            alignment: Alignment.centerLeft,
            onPressed: () {
              historyManager.clearNovels();
              Leader.showToast("Cleared".tr);
            },
            style: ButtonStyle.card(),
            child: Basic(
              title: Text("Clear Novel History".tr),
            )),
        Button(
          alignment: Alignment.centerLeft,
          onPressed: () {
            _showClearCacheDialog(context);
          },
          style: ButtonStyle.card(),
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
