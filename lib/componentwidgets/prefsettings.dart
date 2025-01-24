import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/view/defaults.dart';

class PreferenceSettings extends StatefulWidget {
  @override
  _PreferenceSettingsState createState() => _PreferenceSettingsState();
}

class _PreferenceSettingsState extends State<PreferenceSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preference Settings'.tr),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Language'.tr),
            trailing: DropdownButton<String>(
              value: settings.getLocale(),
              onChanged: (String? newValue) async {
                setState(() {
                  settings.set("language", newValue!);
                });
                BotToast.showText(text:"Please reboot to take effect".tr);
              },
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text('System'.tr),
                ),
                const DropdownMenuItem(
                  value: 'en_US',
                  child: Text('English'),
                ),
                const DropdownMenuItem(
                  value: 'zh_CN',
                  child: Text('简体中文'),
                ),
                const DropdownMenuItem(
                  value: 'zh_TW',
                  child: Text('繁體中文'),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text("Prefer types to display".tr),
            trailing: DropdownButton<String>(
              value: settings.awPrefer,
              onChanged: (String? newValue) {
                setState(() {
                  settings.set("awPrefer", newValue!);
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'illust',
                  child: Text('Illust'.tr),
                ),
                DropdownMenuItem(
                  value: 'manga',
                  child: Text('Manga'.tr),
                ),
                DropdownMenuItem(
                  value: 'novel',
                  child: Text('Novel'.tr),
                ),
              ],
            ),
          ),
          Divider(),
          SwitchListTile(
            title: Text("Show Original in detail page".tr),
            onChanged: (value) {
              setState(() {
                settings.set("showOriginal", value);
              });
            },
            value: settings.showOriginal,
          ),
          SwitchListTile(
            title: Text("Blur R18 Image".tr),
            onChanged: (value) {
              setState(() {
                settings.set("hideR18", value);
              });
            },
            value: settings.hideR18,
          ),
          SwitchListTile(
            title: Text("Hide AI Image".tr),
            onChanged: (value) {
              setState(() {
                settings.set("hideAI", value);
              });
            },
            value: settings.hideAI,
          ),
          SwitchListTile(
            title: Text("Show AI Badge".tr),
            onChanged: (value) {
              setState(() {
                settings.set("feedAIBadge", value);
              });
            },
            value: settings.feedAIBadge,
          ),
          SwitchListTile(
            title: Text("Long press image card to save".tr),
            value: settings.longPressSaveConfirm,
            onChanged: (value) {
              setState(() {
                settings.set("longPressSaveConfirm", value);
              });
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text("Enter novel page directly".tr),
            value: settings.novelDirectEntry,
            onChanged: (value) {
              setState(() {
                settings.set("novelDirectEntry", value);
              });
            },
          ),
          Divider(),
          SwitchListTile(
            title: Text("Check updates on start".tr),
            value: settings.checkUpdate,
            onChanged: (value) {
              setState(() {
                settings.set("checkUpdate", value);
              });
            },
          ),
          if(DynamicData.isAndroid)
            Divider(),
          if(DynamicData.isAndroid)
            SwitchListTile(
            title: Text("High Refresh mode".tr),
            value: settings.isHighRefreshRate,
            onChanged: (value) {
              setState(() {
                settings.set("highRefreshRate", value);
              });
            },
          ),
        ],
      ),
    );
  }
}
