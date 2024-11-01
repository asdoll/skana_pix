import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';

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
        title: Text('Preference Settings'.i18n),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Language'.i18n),
            trailing: DropdownButton<String>(
              value: settings.language,
              onChanged: (String? newValue) {
                setState(() {
                  settings.set("language", newValue!);
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'system',
                  child: Text('System'.i18n),
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
            title: Text("Prefer types to display".i18n),
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
                  child: Text('Illust'.i18n),
                ),
                DropdownMenuItem(
                  value: 'manga',
                  child: Text('Manga'.i18n),
                ),
                DropdownMenuItem(
                  value: 'novel',
                  child: Text('Novel'.i18n),
                ),
              ],
            ),
          ),
          Divider(),
          SwitchListTile(
            title: Text("Show Original in detail page".i18n),
            onChanged: (value) {
              setState(() {
                settings.set("showOriginal", value);
              });
            },
            value: settings.showOriginal,
          ),
          SwitchListTile(
            title: Text("Blur R18 Image".i18n),
            onChanged: (value) {
              setState(() {
                settings.set("hideR18", value);
              });
            },
            value: settings.hideR18,
          ),
          SwitchListTile(
            title: Text("Hide AI Image".i18n),
            onChanged: (value) {
              setState(() {
                settings.set("hideAI", value);
              });
            },
            value: settings.hideAI,
          ),
          SwitchListTile(
            title: Text("Show AI Badge".i18n),
            onChanged: (value) {
              setState(() {
                settings.set("feedAIBadge", value);
              });
            },
            value: settings.feedAIBadge,
          ),
          SwitchListTile(
            title: Text("Long press image card to save".i18n),
            value: settings.longPressSaveConfirm,
            onChanged: (value) {
              setState(() {
                settings.set("longPressSaveConfirm", value);
              });
            },
          ),
        ],
      ),
    );
  }
}
