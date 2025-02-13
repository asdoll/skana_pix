import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/settings_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class NetworkSettings extends StatefulWidget {
  const NetworkSettings({super.key});

  @override
  State<NetworkSettings> createState() => _NetworkSettingsState();
}

class _NetworkSettingsState extends State<NetworkSettings> {
  @override
  void dispose() {
    Get.delete<HostController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HostController controller = Get.put(HostController());
    TextEditingController input = TextEditingController();

    return Scaffold(
        appBar: appBar(title: 'Network Settings'.tr),
        body: Obx(
          () => CustomScrollView(
            slivers: [
              SliverPadding(padding: EdgeInsets.all(20)),
              SliverToBoxAdapter(
                  child: moonListTile(
                title: 'Reverse Proxy'.tr,
                subtitle:
                    "Used to retrieve images from pixiv when using the app through the reverse proxy"
                        .tr,
                trailing: MoonDropdown(
                  show: controller.showMenu.value,
                  constrainWidthToChild: true,
                  onTapOutside: () => controller.showMenu.value = false,
                  content: Column(
                    children: [
                      MoonMenuItem(
                        onTap: () {
                          controller.showMenu.value = false;
                          controller.hostIndex.value = 0;
                        },
                        label: Text("Default".tr),
                      ),
                      MoonMenuItem(
                        onTap: () {
                          controller.showMenu.value = false;
                          controller.hostIndex.value = 1;
                        },
                        label: Text(controller.getPixreHost()),
                      ),
                      MoonMenuItem(
                        onTap: () {
                          controller.showMenu.value = false;
                          controller.hostIndex.value = 2;
                        },
                        label: Text("Custom".tr),
                      ),
                    ],
                  ),
                  child: MoonFilledButton(
                    width: 120,
                    onTap: () =>
                        controller.showMenu.value = !controller.showMenu.value,
                    label: controller.hostIndex.value == 0
                        ? Text("Default".tr)
                        : controller.hostIndex.value == 1
                            ? Text(controller.getPixreHost())
                            : Text("Custom".tr),
                  ),
                ),
              )),
              if (controller.hostIndex.value == 2)
                SliverToBoxAdapter(
                  child: moonListTileWidgets(
                    onTap: () {
                      input.text = controller.customProxyHost.value;
                      showMoonModal<void>(
                          context: context,
                          builder: (context) {
                            return Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                     MoonAlert(
                              borderColor: Get.context?.moonTheme?.buttonTheme
                                  .colors.borderColor
                                  .withValues(alpha: 0.5),
                              showBorder: true,
                              label: Text('Custom Proxy'.tr).header(),
                              verticalGap: 16,
                              content: MoonFormTextInput(
                                controller: input,
                                trailing: MoonButton.icon(
                                  icon: Icon(Icons.done),
                                  onTap: () {
                                    controller.setCustomProxyHost(input.text);
                                    Get.back();
                                  },
                                ),
                              ).paddingBottom(16),
                            )
                                  ],
                                ));
                          });
                    },
                    label: Text('Custom Proxy'.tr),
                    content: Text(controller.customProxyHost.value),
                    trailing: MoonButton.icon(
                      icon: Icon(Icons.edit),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.all(16),
              ),
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    filledButton(
                      label: 'Reset'.tr,
                      onPressed: () => controller.reset(),
                      color: context.moonTheme?.tokens.colors.dodoria,
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
