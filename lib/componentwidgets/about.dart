import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  final bool newVersion;

  const AboutPage({super.key, required this.newVersion});
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: ScrollableState());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: ListView(children: [
        ListTile(
          title: Text('Version'),
          subtitle: Text('1.0.0'),
        ),
        ListTile(
          title: Text('Author'),
          subtitle: Text('John Doe'),
        ),
        ListTile(
          title: Text('Email'),
          subtitle: Text('[email protected]'),
        ),
        ListTile(
          title: Text('Website'),
          subtitle: Text('https://example.com'),
        ),
      ]),
    );
  }
}
