import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skana_pix/controller/histories.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class DataExport extends StatefulWidget {
  DataExport({super.key});

  @override
  _DataExportState createState() => _DataExportState();
}

class _DataExportState extends State<DataExport> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("App Data".i18n),
      ),
      body: ListView(children: [
        Text(
          "Import".i18n,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        ListTile(
            title: Text("Import settings,blocks and bookmarked tags".i18n),
            onTap: () {
              importSettings();
            }),
        ListTile(
            title: Text("Import Illust History".i18n),
            onTap: () {
              historyManager.importIllustData();
            }),
        ListTile(
            title: Text("Import Novel History".i18n),
            onTap: () {
              historyManager.importNovelData();
            }),
        Divider(),
        Text(
          "Export".i18n,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        ListTile(title: Text("Export settings,blocks and bookmarked tags".i18n), onTap: () {
          exportSettings();
        }),
        ListTile(title: Text("Export Illust History".i18n), onTap: () {
          historyManager.exportIllustData();
        }),
        ListTile(title: Text("Export Novel History".i18n), onTap: () {
          historyManager.exportNovelData();
        }),
        Divider(),
        Text(
          "Reset".i18n,
          overflow: TextOverflow.clip,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24.0),
        ).paddingHorizontal(16),
        ListTile(title: Text("Reset settings,blocks and bookmarked tags".i18n), onTap: () {
          resetSettings();

        }),
        ListTile(title: Text("Clear Illust History".i18n), onTap: () {
          historyManager.clearIllusts();
          BotToast.showText(text: "Cleared".i18n);
        }),
        ListTile(title: Text("Clear Novel History".i18n), onTap: () {
          historyManager.clearNovels();
          BotToast.showText(text: "Cleared".i18n);
        }),
        ListTile(title: Text("Clear Cache".i18n), onTap: () {
          _showClearCacheDialog(context);
        }),
      ]).paddingAll(8),
    );
  }

  Future _showClearCacheDialog(BuildContext context) async {
    final result = await showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Clear All Cache".i18n),
            actions: <Widget>[
              TextButton(
                child: Text("Cancel".i18n),
                onPressed: () {
                  Navigator.of(context).pop("CANCEL");
                },
              ),
              TextButton(
                child: Text("Ok".i18n),
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
