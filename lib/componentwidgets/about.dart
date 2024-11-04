import 'package:flutter/material.dart';
import 'package:skana_pix/utils/translate.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AboutPage extends StatefulWidget {
  final bool newVersion;

  const AboutPage({super.key, required this.newVersion});
  @override
  _AboutPageState createState() => _AboutPageState();
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
        title: Text('About'.i18n),
      ),
      body: ListView(children: [
        const ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        const ListTile(
          title: Text('Author'),
          subtitle: Text('asdoll'),
        ),
        ListTile(
          title: const Text('Website'),
          subtitle: const Text('https://github.com/asdoll/skana_pix'),
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
                'Main UI design referenced and models are referenced from Pixez. Really thanks for their team.'),
            SizedBox(height: 10),
            Text(
                'As a Pixiv novel user, I refered Pixiv official app and make novel and manga pages all at main page, and did minor changes of layouts.'),
            SizedBox(height: 10),
            Text(
                'Also novel reading is redesigned to make it more comfortable to read.'),
          ],
        ).paddingHorizontal(10),
      ]),
    );
  }
}
