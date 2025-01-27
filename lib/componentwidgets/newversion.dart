import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewVersionPage extends StatefulWidget {
  const NewVersionPage({super.key});
  @override
  State<NewVersionPage> createState() => _NewVersionPageState();
}

class _NewVersionPageState extends State<NewVersionPage> {
  @override
  Widget build(BuildContext context) {
    EasyRefreshController controller = EasyRefreshController(
        controlFinishLoad: true, controlFinishRefresh: true);
    return Scaffold(
      headers: [
        AppBar(
          title: Text('Check updates'.tr),
        ),
      ],
      child: Obx(() => EasyRefresh(
          controller: controller,
          onRefresh: () async {
            await updateController.check();
            controller.finishRefresh();
          },
          refreshOnStart: updateController.hasNewVersion.value,
          child: ListView(
            children: [
              Basic(
                title: Text('Current Version'.tr),
                subtitle: Text(updateController.getVersion()),
              ),
              if (updateController.hasNewVersion.value)
                Basic(
                  title: Text('Latest Version'.tr),
                  subtitle: Text(updateController.updateVersion),
                ),
              if (updateController.hasNewVersion.value)
                Basic(
                  title: Text('Release Date'.tr),
                  subtitle: Text(updateController.updateDate.isNotEmpty
                      ? DateTime.parse(updateController.updateDate)
                          .toShortTime()
                      : ""),
                ),
              if (updateController.hasNewVersion.value)
                Basic(
                  title: Text('Release Notes'.tr),
                  subtitle: Text(updateController.updateDescription),
                ),
              if (updateController.hasNewVersion.value)
                InkWell(
                  onTap: () async {
                    if (updateController.updateUrl.isEmpty) {
                      Leader.showTextToast('No download link'.tr);
                      return;
                    }
                    await launchUrlString(updateController.updateUrl);
                  },
                  child: Basic(
                    title: Text('Download'.tr),
                  ),
                ),
              InkWell(
                onTap: () async {
                  await updateController.check();
                },
                child: Basic(
                  title: Text('Check for updates'.tr),
                ),
              ),
            ],
          ))),
    );
  }
}
