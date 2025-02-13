import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
import 'package:skana_pix/controller/update_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'.tr),
        leading: const NormalBackButton(),
        shape: Border(
            bottom: BorderSide(
          color: Get.theme.colorScheme.onSurface.withValues(alpha: 0.5),
          width: 0.2,
        )),
      ),
      body: ListView(padding: EdgeInsets.zero, children: [
        moonListTile(
          title: 'Version'.tr,
          subtitle: updateController.getVersion(),
        ),
        moonListTile(
          title: 'Author'.tr,
          subtitle: 'asdoll',
        ),
        moonListTile(
          title: 'Website'.tr,
          subtitle: 'https://github.com/asdoll/skana_pix',
          onTap: () => launchUrlString("https://github.com/asdoll/skana_pix"),
        ),
        moonListTileWidgets(
          label: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'This is a Flutter project for Pixiv. The project is open source and free to use.',
              ).subHeader(),
              SizedBox(height: 10),
              Text('Main UI design referenced and models are referenced from Pixez. Some are referenced from Pixes. Really thanks for their teams.')
                  .subHeader(),
              SizedBox(height: 10),
              Text("Also thanks for mabDc's project eso, provides a display of novel pages.")
                  .subHeader(),
              SizedBox(height: 10),
              Text('As a Pixiv novel user, I refered Pixiv official app and make novel and manga pages all at main page, and did minor changes of layouts.')
                  .subHeader(),
              SizedBox(height: 10),
            ],
          ),
        ),
      ]),
    );
  }
}
