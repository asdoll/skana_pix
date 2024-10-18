import 'package:flutter/services.dart';
import 'package:skana_pix/pixiv_dart_api.dart';

import 'defaults.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import 'package:flutter/material.dart';

import 'loginpage.dart';
import 'mainscreen.dart';
import 'settingscreen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);
  final NavBarStyle _navBarStyle = NavBarStyle.style6;

  List<Widget> _buildScreens() {
    return [MainScreen(), SettingScreen(), SettingScreen()];
  }

  void jumpTab() {
    _controller.jumpToTab(0);
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.auto_awesome),
        inactiveIcon: Icon(Icons.auto_awesome_outlined),
        //title: ("Trending"),
        activeColorPrimary: DynamicData.themeData.primaryColor,
        inactiveColorPrimary: DynamicData.inActiveNavColor,
        scrollController: DynamicData.recommendScrollController,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: "/",
        ),
        iconSize: 26.0,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.motion_photos_on),
        inactiveIcon: Icon(Icons.motion_photos_on_outlined),
        //title: ("Feed"),
        activeColorPrimary: DynamicData.themeData.primaryColor,
        inactiveColorPrimary: DynamicData.inActiveNavColor,
        //scrollController: DynamicData.recommendMangaScrollController,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: "/",
          routes: {
            "/first": (final context) => const MainScreen2(),
            "/second": (final context) => const MainScreen3(),
          },
        ),
        iconSize: 26.0,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.pest_control_rodent),
        inactiveIcon: Icon(Icons.pest_control_rodent_outlined),
        //title: ("Users"),
        activeColorPrimary: DynamicData.themeData.primaryColor,
        inactiveColorPrimary: DynamicData.inActiveNavColor,
        //scrollController: DynamicData.recommendMangaScrollController,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: "/",
          routes: {
            "/first": (final context) => const MainScreen2(),
            "/second": (final context) => const MainScreen3(),
          },
        ),
        iconSize: 26.0,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (ConnectManager().notLoggedIn) {
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 0.0,
          systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
              systemNavigationBarColor:
                  Theme.of(context).scaffoldBackgroundColor),
        ),
        body: Material(
          child: LoginPage(() => setState(() {})),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0.0,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
            systemNavigationBarColor:
                Theme.of(context).scaffoldBackgroundColor),
      ),
      body: Material(
        color: getTheme(context).primaryColor,
        child: PersistentTabView(
          context,
          controller: _controller,
          screens: _buildScreens(),
          items: _navBarsItems(),
          handleAndroidBackButtonPress: true, // Default is true.
          resizeToAvoidBottomInset:
              true, // This needs to be true if you want to move up the screen on a non-scrollable screen when keyboard appears. Default is true.
          stateManagement: true, // Default is true.
          hideNavigationBarWhenKeyboardAppears: true,
          popBehaviorOnSelectedNavBarItemPress: PopBehavior.all,
          padding: const EdgeInsets.only(top: 4),
          backgroundColor: getTheme(context).scaffoldBackgroundColor,
          isVisible: true,
          animationSettings: const NavBarAnimationSettings(
            navBarItemAnimation: ItemAnimationSettings(
              // Navigation Bar's items animation properties.
              duration: Duration(milliseconds: 400),
              curve: Curves.ease,
            ),
            screenTransitionAnimation: ScreenTransitionAnimationSettings(
              // Screen transition animation on change of selected tab.
              animateTabTransition: true,
              duration: Duration(milliseconds: 200),
              screenTransitionAnimationType:
                  ScreenTransitionAnimationType.fadeIn,
            ),
          ),
          confineToSafeArea: true,
          navBarHeight: 42,
          navBarStyle:
              _navBarStyle, // Choose the nav bar style with this property
        ),
      ),
    );
  }
}
