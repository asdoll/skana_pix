import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controller/updater.dart';

class NewVersionPage extends StatefulWidget {
  final bool newVersion;
  const NewVersionPage({super.key, required this.newVersion});
  @override
  _NewVersionPageState createState() => _NewVersionPageState();
}

class _NewVersionPageState extends State<NewVersionPage> {
  bool hasNewVersion = false;
  late EasyRefreshController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    setState(() {
      hasNewVersion = widget.newVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check updates'.i18n),
      ),
      body: buildCheck(context),
    );
  }

  Widget buildCheck(BuildContext context) {
    return EasyRefresh(
        controller: _controller,
        onRefresh: () async {
          await check();
          _controller.finishRefresh();
        },
        refreshOnStart: !hasNewVersion,
        child: ListView(
          children: [
            ListTile(
              title: Text('Current Version'.i18n),
              subtitle: Text(Constants.appVersion),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Latest Version'.i18n),
              subtitle: Text(Updater.updateVersion??""),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Release Date'.i18n),
              subtitle: Text(Updater.updateDate!=null? DateTime.parse(Updater.updateDate!).toShortTime() :""),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Release Notes'.i18n),
              subtitle: Text(Updater.updateDescription??""),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Download'.i18n),
              onTap: () async {
                if(Updater.updateUrl==null) 
                {
                  BotToast.showText(text: 'No download link'.i18n);
                  return;
                }
                await launchUrlString(Updater.updateUrl!);
              },
            ),
            ListTile(
              title: Text('Check for updates'.i18n),
              onTap: () async {
                await check();
              },
            ),
          ],
        ));
  }

  check() async {
    if (Constants.isGooglePlay || DynamicData.isIOS) return;
    if (Updater.result != Result.timeout) {
      bool hasNew = Updater.result == Result.yes;
      if (mounted)
        setState(() {
          hasNewVersion = hasNew;
        });
      return;
    }
    Result result = await Updater.check();
    switch (result) {
      case Result.yes:
        if (mounted) {
          setState(() {
            hasNewVersion = true;
          });
        }
        break;
      default:
        if (mounted) {
          setState(() {
            hasNewVersion = false;
          });
        }
    }
  }
}
