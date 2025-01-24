import 'package:bot_toast/bot_toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/view/defaults.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:skana_pix/controller/updater.dart';

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
        title: Text('Check updates'.tr),
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
              title: Text('Current Version'.tr),
              subtitle: Text(Constants.appVersion),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Latest Version'.tr),
              subtitle: Text(updater.updateVersion),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Release Date'.tr),
              subtitle: Text(updater.updateDate.isNotEmpty? DateTime.parse(updater.updateDate).toShortTime() :""),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Release Notes'.tr),
              subtitle: Text(updater.updateDescription),
            ),
            if(hasNewVersion)
            ListTile(
              title: Text('Download'.tr),
              onTap: () async {
                if(updater.updateUrl.isEmpty) 
                {
                  BotToast.showText(text: 'No download link'.tr);
                  return;
                }
                await launchUrlString(updater.updateUrl);
              },
            ),
            ListTile(
              title: Text('Check for updates'.tr),
              onTap: () async {
                await check();
              },
            ),
          ],
        ));
  }

  check() async {
    if (Constants.isGooglePlay || DynamicData.isIOS) return;
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
