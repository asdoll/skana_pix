import 'package:easy_refresh/easy_refresh.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' show InkWell;
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/componentwidgets/headerfooter.dart';
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
          padding: EdgeInsets.all(10),
          leading: [
            const NormalBackButton(),
          ],
        ),
        const Divider()
      ],
      child: Obx(() => EasyRefresh(
          controller: controller,
          onRefresh: () async {
            await updateController.check();
            controller.finishRefresh();
          },
          header: DefaultHeaderFooter.header(context),
          refreshOnStart: updateController.hasNewVersion.value,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Card(
                  child: Basic(
                title: Text('Current Version'.tr),
                subtitle: Text(updateController.getVersion()),
              )),
              Card(
                child: Basic(
                  title: Text('Latest Version'.tr),
                  subtitle: Text(updateController.updateVersion),
                ),
              ),
              if (updateController.hasNewVersion.value)
                Card(
                    child: Basic(
                  title: Text('Release Date'.tr),
                  subtitle: Text(updateController.updateDate.isNotEmpty
                      ? DateTime.parse(updateController.updateDate)
                          .toShortTime()
                      : ""),
                )),
              if (updateController.hasNewVersion.value)
                Card(
                    child: Basic(
                  title: Text('Release Notes'.tr),
                  subtitle: Text(updateController.updateDescription),
                )),
              if (updateController.hasNewVersion.value)
                Card(
                    child: InkWell(
                  onTap: () async {
                    if (updateController.updateUrl.isEmpty) {
                      Leader.showToast('No download link'.tr);
                      return;
                    }
                    await launchUrlString(updateController.updateUrl);
                  },
                  child: Basic(
                    title: Text('Download'.tr),
                  ),
                )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                      onPressed: () async {
                        await controller.callRefresh();
                      },
                      child: Text('Check for updates'.tr)),
                ],
              ).paddingSymmetric(vertical: 10),
            ],
          ))),
    );
  }
}
