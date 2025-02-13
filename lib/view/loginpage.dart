import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/account_controller.dart';
import 'package:skana_pix/utils/widgetplugin.dart';
import 'package:skana_pix/view/settings/settingpage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../componentwidgets/webview.dart';
import '../utils/applinks.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int selected = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomAppBar(
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Get.to(() => Scaffold(
                    appBar: appBar(title: "Settings".tr),
                    body: SettingPage())),
              )
            ],
          ),
        ),
        body: Obx(() {
          if (accountController.isLoading.value) {
            return buildLoading(context);
          } else if (!accountController.waitingForAuth.value) {
            return buildLogin(context);
          } else {
            return buildWaiting(context);
          }
        }));
  }

  Widget buildLogin(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            child: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              const SizedBox(
                height: 16,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  ("     ${"SkanaPix".tr}"),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 110,
                        child: TextButton(
                          onPressed: onContinue,
                          child: Text("Login".tr),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                            "You need to complete the login operation in the browser window that will open."
                                .tr),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget buildWaiting(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            child: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Waiting...".tr,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                        "Waiting for authentication. Please finished in the browser."
                            .tr),
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                      child: Text("Back".tr),
                      onPressed: () {
                        accountController.waitingForAuth.value = false;
                      }),
                  const Spacer(),
                ],
              )
            ],
          ),
        )),
      ),
    );
  }

  Widget buildLoading(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            child: SizedBox(
          width: 300,
          height: 300,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Logging in".tr,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  void onContinue() async {
    bool useExternal = true;
    bool exitLogin = false;
    if (GetPlatform.isMobile) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          var alertDialog = AlertDialog(
              content: Text(
                  "I understand this is a free unofficial application.".tr),
              actions: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text("Cancel".tr),
                      onPressed: () {
                        exitLogin = true;
                        Get.back();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      child: Text("Continue with Webview".tr),
                      onPressed: () {
                        exitLogin = false;
                        useExternal = false;
                        Get.back();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      child: Text("Continue with External Browser".tr),
                      onPressed: () {
                        exitLogin = false;
                        useExternal = true;
                        Get.back();
                      },
                    ),
                  ],
                )
              ]);
          return alertDialog;
        },
      );
    }
    if (exitLogin) {
      return;
    }
    var url = await accountController.generateWebviewUrl();
    onLink = (uri) {
      if (uri.scheme == "pixiv") {
        accountController.onFinished(uri.queryParameters["code"]!);
        onLink = null;
        return true;
      }
      return false;
    };
    accountController.waitingForAuth.value = true;
    if (!useExternal && mounted) {
      Get.to(() => WebviewPage(
            url,
            onNavigation: (req) {
              if (req.url.startsWith("pixiv://")) {
                Get.back();
                onLink?.call(Uri.parse(req.url));
                return false;
              }
              return true;
            },
          ));
    } else {
      launchUrlString(url);
    }
  }
}
