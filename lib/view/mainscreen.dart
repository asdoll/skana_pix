import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:skana_pix/view/defaults.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<String> titles = <String>[
    'Cloud',
    'Beach',
    'Sunny',
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = DynamicData.themeData.colorScheme;
    final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
    final Color evenItemColor = colorScheme.primary.withOpacity(0.15);
    List<Widget> tabs = [
      ListView.builder(
        itemCount: 25,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: index.isOdd ? oddItemColor : evenItemColor,
            title: Text(ConnectManager().apiClient.account.user.name),
          );
        },
      ),
      ListView.builder(
        itemCount: 25,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            tileColor: index.isOdd ? oddItemColor : evenItemColor,
            title: Text('${titles[1]} $index'),
          );
        },
      ),
      Center(
        child: ElevatedButton(
          onPressed: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const MainScreen2(),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: const Text("Go to Screen 2"),
        ),
      ),
    ];
    return MaterialApp(
      theme: DynamicData.themeData,
      darkTheme: DynamicData.darkTheme,
      themeMode: ThemeMode.system,
      home:
      DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          bottom: TabBar(
            tabs: [
              new Container(
                  height: 30.0,
                  width: 80,
                  child: new Tab(text: 'Illust'),
                ),
              new Container(
                  height: 30.0,
                  width: 80,
                  // color: Colors.red,
                  child: new Tab(text: 'Manga'),
                ),
              new Container(
                  height: 30.0,
                  width: 80,
                  // color: Colors.red,
                  child: new Tab(text: 'Novel'),
                ),
            ],
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
          ),
        body: TabBarView(
          children: tabs,
        ),
      ),
    ),
    );
  }
}

class MainScreen2 extends StatefulWidget {
  const MainScreen2({super.key});

  @override
  _MainScreen2State createState() => _MainScreen2State();
}

class _MainScreen2State extends State<MainScreen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const MainScreen3(),
              withNavBar: true, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: const Text("Go to Screen 3"),
        ),
      ),
    );
  }
}

class MainScreen3 extends StatefulWidget {
  const MainScreen3({super.key});

  @override
  _MainScreen3State createState() => _MainScreen3State();
}

class _MainScreen3State extends State<MainScreen3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            PersistentNavBarNavigator.popUntilFirstScreenOnSelectedTabScreen(
              context,
              routeName:
                  "/", //If you haven't defined a routeName for the first screen of the selected tab then don't use the optional property `routeName`. Otherwise it may not work as intended
            );
          },
          child: const Text("Go to Screen 1"),
        ),
      ),
    );
  }
}