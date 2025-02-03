import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/settings_controller.dart';
import 'package:get/get.dart';

class PreferenceSettings extends StatefulWidget {
  const PreferenceSettings({super.key});

  @override
  State<PreferenceSettings> createState() => _PreferenceSettingsState();
}

class _PreferenceSettingsState extends State<PreferenceSettings> {
  @override
  Widget build(BuildContext context) {
    PrefsController controller = Get.put(PrefsController());

    return Scaffold(
        headers: [
          AppBar(
            title: Text('Preference Settings'.tr),
           padding: EdgeInsets.all(10),
            leading: [
              const NormalBackButton(),
            ],
          ),
          const Divider()
        ],
        child: Obx(
          () => CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                  title: Text('Language'.tr),
                  trailing: Select<String>(
                    value: controller.language.value,
                    itemBuilder: (context, item) {
                      switch (item) {
                        case "zh_CN":
                          return Text("简体中文");
                        case 'zh_TW':
                          return Text('繁體中文');
                        case 'system':
                          return Text("System".tr);
                        case _:
                          return Text("English");
                      }
                    },
                    onChanged: (value) => controller.changeLanguage(value),
                    children: [
                      SelectItemButton(
                          value: 'system', child: Text("System".tr)),
                      SelectItemButton(value: 'en_US', child: Text("English")),
                      SelectItemButton(value: 'zh_CN', child: Text("简体中文")),
                      SelectItemButton(value: 'zh_TW', child: Text('繁體中文'))
                    ],
                  ),
                )),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                  title: Text("Prefer types to display".tr),
                  trailing: Select<String>(
                    value: controller.awPrefer.value,
                    itemBuilder: (context, item) {
                      switch (item) {
                        case 'novel':
                          return Text('Novel'.tr);
                        case 'manga':
                          return Text("Manga".tr);
                        case _:
                          return Text('Illust'.tr);
                      }
                    },
                    onChanged: (value) => controller.changeAwPrefer(value),
                    children: [
                      SelectItemButton(
                          value: 'illust', child: Text('Illust'.tr)),
                      SelectItemButton(value: 'manga', child: Text('Manga'.tr)),
                      SelectItemButton(value: 'novel', child: Text('Novel'.tr))
                    ],
                  ),
                )),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Show Original in detail page".tr),
                        trailing: Switch(
                            value: controller.showOriginal.value,
                            onChanged: controller.setShowOriginal))),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Blur R18 Image".tr),
                        trailing: Switch(
                            value: controller.hideR18.value,
                            onChanged: controller.setHideR18))),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Hide AI Image".tr),
                        trailing: Switch(
                            value: controller.hideAI.value,
                            onChanged: controller.setHideAI))),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Show AI Badge".tr),
                        trailing: Switch(
                            value: controller.feedAIBadge.value,
                            onChanged: controller.setAIBadge))),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Long press image card to save".tr),
                        trailing: Switch(
                            value: controller.longPressSaveConfirm.value,
                            onChanged: controller.setLongPressConfirm))),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Enter novel page directly".tr),
                        trailing: Switch(
                            value: controller.novelDirectEntry.value,
                            onChanged: controller.setNovelDirectEntry))),
              ),
              SliverToBoxAdapter(
                child: Card(
                    child: Basic(
                        title: Text("Check updates on start".tr),
                        trailing: Switch(
                            value: controller.checkUpdate.value,
                            onChanged: controller.setCheckUpdate))),
              ),
              if (GetPlatform.isAndroid)
                SliverToBoxAdapter(
                  child: Card(
                      child: Basic(
                          title: Text("High Refresh mode".tr),
                          trailing: Switch(
                              value: controller.isHighRefreshRate.value,
                              onChanged: controller.setHighRefreshRate))),
                ),
            ],
          ),
        ));
  }
}
