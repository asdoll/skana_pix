import 'package:get/get.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/settings_controller.dart';
import 'package:flutter/material.dart' as m;

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
        headers: [
          AppBar(
            title: Text('Network Settings'.tr),
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
              SliverPadding(padding: EdgeInsets.all(20)),
              SliverToBoxAdapter(
                child: Card(
                  child: Basic(
                    title: Text('Reverse Proxy'.tr),
                    subtitle: Text(
                        "Used to retrieve images from pixiv when using the app through the reverse proxy"
                            .tr),
                    trailing: Select<int>(
                      value: controller.hostIndex.value,
                      onChanged: (value) {
                        if (value == null) return;
                        controller.setHostIndex(value);
                      },
                      itemBuilder: (context, index) {
                        switch (index) {
                          case 0:
                            return Text("Default".tr);
                          case 1:
                            return Text(controller.getPixreHost());
                          case _:
                            return Text("Custom".tr);
                        }
                      },
                      children: [
                        SelectGroup(
                          children: [
                            SelectItemButton(
                                value: 0, child: Text("Default".tr)),
                            SelectItemButton(
                                value: 1,
                                child: Text(controller.getPixreHost())),
                            SelectItemButton(
                                value: 2, child: Text("Custom".tr)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (controller.hostIndex.value == 2)
                SliverToBoxAdapter(
                  child: m.InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            input.text = controller.customProxyHost.value;
                            return AlertDialog(
                              title: Text('Custom Proxy'.tr),
                              content: TextField(
                                controller: input,
                                trailing: IconButton.ghost(
                                  icon: Icon(Icons.done),
                                  onPressed: () {
                                    controller.setCustomProxyHost(input.text);
                                    Get.back();
                                  },
                                ),
                              ),
                            );
                          });
                    },
                    child: Card(
                      child: Basic(
                        title: Text('Custom Proxy'.tr),
                        subtitle: Text(controller.customProxyHost.value),
                        trailing: IconButton.ghost(
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.all(16),
              ),
              SliverToBoxAdapter(
                child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [DestructiveButton(child: Text('Reset'.tr),onPressed: () => controller.reset(),)],),
              )
            ],
          ),
        ));
  }
}
