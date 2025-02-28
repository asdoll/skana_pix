import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/io_extension.dart';
import 'package:skana_pix/utils/leaders.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
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
      appBar: appBar(title: 'Check updates'.tr),
      body: Obx(() => EasyRefresh(
          controller: controller,
          onRefresh: () async {
            await updateController.check();
            controller.finishRefresh();
          },
          header: DefaultHeaderFooter.header(context),
          refreshOnStartHeader: DefaultHeaderFooter.refreshHeader(context),
          refreshOnStart: updateController.hasNewVersion.value,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              moonListTile(
                title: 'Current Version'.tr,
                subtitle: updateController.getVersion(),
              ),
              moonListTile(
                title: 'Latest Version'.tr,
                subtitle: updateController.updateVersion,
              ),
              if (updateController.hasNewVersion.value)
                moonListTile(
                  title: 'Release Date'.tr,
                  subtitle: updateController.updateDate.isNotEmpty
                      ? DateTime.parse(updateController.updateDate)
                          .toShortTime()
                      : "",
                ),
              if (updateController.hasNewVersion.value)
                moonListTile(
                  title: 'Release Notes'.tr,
                  subtitle: updateController.updateDescription,
                ),
              if (updateController.hasNewVersion.value)
                moonListTile(
                  title: 'Download'.tr,
                  onTap: () async {
                    if (updateController.updateUrl.isEmpty) {
                      Leader.showToast('No download link'.tr);
                      return;
                    }
                    await launchUrlString(updateController.updateUrl);
                  },
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  filledButton(
                      onPressed: () async {
                        await controller.callRefresh();
                      },
                      label: 'Check for updates'.tr),
                ],
              ).paddingSymmetric(vertical: 10),
            ],
          ))),
    );
  }
}
