import 'package:flutter/material.dart' show InkWell;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/componentwidgets/backarea.dart';
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
      headers: [
        AppBar(
          title: Text('About'.tr),
          padding: EdgeInsets.all(10),
          leading: [
            const NormalBackButton(),
          ],
        ),
        const Divider()
      ],
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
        Card(
          child: Basic(
            title: Text('Version'.tr),
            subtitle: Text('1.0.0'),
          ),
        ),
        Card(
          child: Basic(
            title: Text('Author'.tr),
            subtitle: Text('asdoll'),
          ),
        ),
        Card(
          child: InkWell(
            child: Basic(
              title: Text('Website'.tr),
              subtitle: Text('https://github.com/asdoll/skana_pix'),
            ),
            onTap: () => launchUrlString("https://github.com/asdoll/skana_pix"),
          ),
        ),
        Card(
          child: const Column(
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
          ),
        ),
      ]),
    );
  }
}
