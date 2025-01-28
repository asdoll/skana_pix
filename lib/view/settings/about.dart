import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {

  const AboutPage({super.key});
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'.tr),
      ),
      body: ListView(children: [
        ListTile(
          title: Text('Version'.tr),
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          title: Text('Author'.tr),
          subtitle: Text('asdoll'),
        ),
        ListTile(
          title: Text('Website'.tr),
          subtitle: Text('https://github.com/asdoll/skana_pix'),
          onTap: () => launchUrlString("https://github.com/asdoll/skana_pix"),
        ),
        const Divider(),
        const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is a Flutter project for Pixiv. The project is open source and free to use.',
            ),
            SizedBox(height: 10),
            Text(
                'Main UI design referenced and models are referenced from Pixez. Some are referenced from Pixes. Really thanks for their teams.'),
            SizedBox(height: 10),
            Text(
                "Also thanks for mabDc's project eso, provides a display of novel pages."),
            SizedBox(height: 10),
            Text(
                'As a Pixiv novel user, I refered Pixiv official app and make novel and manga pages all at main page, and did minor changes of layouts.'),
            SizedBox(height: 10),
          ],
        ).paddingHorizontal(10),
      ]),
    );
  }
}
