import 'package:flutter/material.dart';
import 'package:moon_design/moon_design.dart';
import 'package:skana_pix/controller/settings_controller.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';

class PreferenceSettings extends StatefulWidget {
  const PreferenceSettings({super.key});

  @override
  State<PreferenceSettings> createState() => _PreferenceSettingsState();
}

class _PreferenceSettingsState extends State<PreferenceSettings> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<PrefsController>();
  }

  @override
  Widget build(BuildContext context) {
    PrefsController controller = Get.put(PrefsController());

    return Scaffold(
      appBar: appBar(title: 'Preference Settings'.tr),
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: moonListTile(
              title: 'Language'.tr,
              trailing: MoonDropdown(
                show: controller.langMenu.value,
                constrainWidthToChild: true,
                onTapOutside: () => controller.langMenu.value = false,
                content: Column(
                  children: [
                    MoonMenuItem(
                      onTap: () {
                        controller.langMenu.value = false;
                        controller.changeLanguage('system');
                      },
                      label: Text("System".tr),
                    ),
                    MoonMenuItem(
                      onTap: () {
                        controller.langMenu.value = false;
                        controller.changeLanguage('en_US');
                      },
                      label: Text("English"),
                    ),
                    MoonMenuItem(
                      onTap: () {
                        controller.langMenu.value = false;
                        controller.changeLanguage('zh_CN');
                      },
                      label: Text("简体中文"),
                    ),
                    MoonMenuItem(
                      onTap: () {
                        controller.langMenu.value = false;
                        controller.changeLanguage('zh_TW');
                      },
                      label: Text("繁體中文"),
                    ),
                  ],
                ),
                child: MoonFilledButton(
                  width: 120,
                  onTap: () =>
                      controller.langMenu.value = !controller.langMenu.value,
                  label: controller.language.value == 'system'
                      ? Text('System'.tr)
                      : controller.language.value == 'en_US'
                          ? Text('English')
                          : controller.language.value == 'zh_CN'
                              ? Text("简体中文")
                              : Text("繁體中文"),
                ),
              ),
            )),
            SliverToBoxAdapter(
              child: moonListTile(
                title: 'Dark Mode'.tr,
                trailing: MoonDropdown(
                  show: tc.dmMenu.value,
                  constrainWidthToChild: true,
                  onTapOutside: () => tc.dmMenu.value = false,
                  content: Column(
                    children: [
                      MoonMenuItem(
                        onTap: () {
                          tc.dmMenu.value = false;
                          tc.changeDarkMode('0');
                        },
                        label: Text("System".tr),
                      ),
                      MoonMenuItem(
                        onTap: () {
                          tc.dmMenu.value = false;
                          tc.changeDarkMode('1');
                        },
                        label: Text("Light".tr),
                      ),
                      MoonMenuItem(
                        onTap: () {
                          tc.dmMenu.value = false;
                          tc.changeDarkMode('2');
                        },
                        label: Text("Dark".tr),
                      ),
                    ],
                  ),
                  child: MoonFilledButton(
                    width: 120,
                    onTap: () => tc.dmMenu.value = !tc.dmMenu.value,
                    label: tc.darkMode.value == '0'
                        ? Text('System'.tr)
                        : tc.darkMode.value == '1'
                            ? Text('Light'.tr)
                            : Text("Dark".tr),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                title: 'Prefer types to display'.tr,
                trailing: MoonDropdown(
                  show: controller.awMenu.value,
                  constrainWidthToChild: true,
                  onTapOutside: () => controller.awMenu.value = false,
                  content: Column(
                    children: [
                      MoonMenuItem(
                        onTap: () {
                          controller.awMenu.value = false;
                          controller.changeAwPrefer('illust');
                        },
                        label: Text("Illust".tr),
                      ),
                      MoonMenuItem(
                        onTap: () {
                          controller.awMenu.value = false;
                          controller.changeAwPrefer('manga');
                        },
                        label: Text("Manga".tr),
                      ),
                      MoonMenuItem(
                        onTap: () {
                          controller.awMenu.value = false;
                          controller.changeAwPrefer('novel');
                        },
                        label: Text("Novel".tr),
                      ),
                    ],
                  ),
                  child: MoonFilledButton(
                    width: 120,
                    onTap: () =>
                        controller.awMenu.value = !controller.awMenu.value,
                    label: controller.awPrefer.value == 'illust'
                        ? Text('Illust'.tr)
                        : controller.awPrefer.value == 'manga'
                            ? Text('Manga'.tr)
                            : Text("Novel".tr),
                  ),
                ),
              ),
            ),
            if (GetPlatform.isAndroid)
              SliverToBoxAdapter(
                child: moonListTile(
                  title: 'Main orientation'.tr,
                  trailing: MoonDropdown(
                    show: controller.orientationMenu.value,
                    constrainWidthToChild: true,
                    onTapOutside: () =>
                        controller.orientationMenu.value = false,
                    content: Column(
                      children: [
                        MoonMenuItem(
                          onTap: () {
                            controller.orientationMenu.value = false;
                            controller.setOrientation('0');
                          },
                          label: Text("Portrait".tr),
                        ),
                        MoonMenuItem(
                          onTap: () {
                            controller.orientationMenu.value = false;
                            controller.setOrientation('1');
                          },
                          label: Text("Landscape".tr),
                        ),
                        MoonMenuItem(
                          onTap: () {
                            controller.orientationMenu.value = false;
                            controller.setOrientation('2');
                          },
                          label: Text("Auto".tr),
                        ),
                      ],
                    ),
                    child: MoonFilledButton(
                      width: 120,
                      onTap: () => controller.orientationMenu.value =
                          !controller.orientationMenu.value,
                      label: controller.orientation.value == '0'
                          ? Text('Portrait'.tr)
                          : controller.orientation.value == '1'
                              ? Text('Landscape'.tr)
                              : Text("Auto".tr),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: moonListTile(
                title: 'Show Original in detail page'.tr,
                trailing: MoonSwitch(
                    value: controller.showOriginal.value,
                    onChanged: controller.setShowOriginal),
              ),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  title: 'Blur R18 Image'.tr,
                  trailing: MoonSwitch(
                      value: controller.hideR18.value,
                      onChanged: controller.setHideR18)),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  title: 'Hide AI Image'.tr,
                  trailing: MoonSwitch(
                      value: controller.hideAI.value,
                      onChanged: controller.setHideAI)),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  title: 'Show AI Badge'.tr,
                  trailing: MoonSwitch(
                      value: controller.feedAIBadge.value,
                      onChanged: controller.setAIBadge)),
            ),
            SliverToBoxAdapter(
                child: moonListTile(
                    title: 'Long press image card to save'.tr,
                    trailing: MoonSwitch(
                        value: controller.longPressSaveConfirm.value,
                        onChanged: controller.setLongPressConfirm))),
            SliverToBoxAdapter(
              child: moonListTile(
                  title: 'Enter novel page directly'.tr,
                  trailing: MoonSwitch(
                      value: controller.novelDirectEntry.value,
                      onChanged: controller.setNovelDirectEntry)),
            ),
            SliverToBoxAdapter(
              child: moonListTile(
                  title: 'Check updates on start'.tr,
                  trailing: MoonSwitch(
                      value: controller.checkUpdate.value,
                      onChanged: controller.setCheckUpdate)),
            ),
            if (GetPlatform.isAndroid)
              SliverToBoxAdapter(
                child: moonListTile(
                    title: "High Refresh mode".tr,
                    trailing: MoonSwitch(
                        value: controller.isHighRefreshRate.value,
                        onChanged: controller.setHighRefreshRate)),
              ),
          ],
        ),
      ),
    );
  }
}
