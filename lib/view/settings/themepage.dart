import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:get/get.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  @override
  void dispose() {
    super.dispose();
    Get.delete<ThemeController>();
  }

  @override
  Widget build(BuildContext context) {
    ThemeController controller = Get.put(ThemeController());

    return Obx(() => Scaffold(
            headers: [
              AppBar(
                title: Text("Skin".tr),
                padding: EdgeInsets.all(10),
                leading: [
                  const NormalBackButton(),
                ],
              ),
              const Divider()
            ],
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Card(
                      child: Basic(
                    title: Text("Dark Mode".tr),
                    trailing: Select<String>(
                      value: controller.darkMode.value,
                      itemBuilder: (context, item) => item == "0"
                          ? Text("System".tr)
                          : item == "1"
                              ? Text("Light".tr)
                              : Text("Dark".tr),
                      children: [
                        SelectItemButton(value: '0', child: Text("System".tr)),
                        SelectItemButton(value: '1', child: Text("Light".tr)),
                        SelectItemButton(value: '2', child: Text("Dark".tr))
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        controller.changeDarkMode(value);
                      },
                    ),
                  )),
                ),
                SliverToBoxAdapter(
                  child: Card(
                    child: Basic(
                        title: Text("Color Theme".tr),
                        trailing: OutlineButton(
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryForeground,
                                width: 2,
                                strokeAlign: BorderSide.strokeAlignOutside,
                              ),
                            ),
                          ),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                title: Text("Pick A Color".tr),
                                content: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (int i = 0;
                                        i < controller.themeNames.length;
                                        i++)
                                      Button(
                                        onPressed: () {
                                          controller.changeTheme(
                                              controller.themeNames[i]);
                                          Get.back();
                                        },
                                        style: controller.themeName.value ==
                                                controller.themeNames[i]
                                            ? ButtonStyle.primary()
                                            : ButtonStyle.outline(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: controller
                                                    .themeColors[i].primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: controller
                                                      .themeColors[i]
                                                      .primaryForeground,
                                                  width: 2,
                                                  strokeAlign: BorderSide
                                                      .strokeAlignOutside,
                                                ),
                                              ),
                                            ),
                                            const Gap(8),
                                            Text(controller.themeNames[i].tr),
                                          ],
                                        ),
                                      )
                                  ],
                                )),
                          ),
                        )),
                  ),
                ),
              ],
            )));
  }
}
