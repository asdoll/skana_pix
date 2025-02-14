import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moon_design/moon_design.dart';
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
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.settings,color: context.moonTheme?.tokens.colors.bulma,),
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
                  "     ${"SkanaPix".tr}",
                  style: const TextStyle(fontSize: 20),
                ).header(),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 110,
                        child: filledButton(
                          onPressed: onContinue,
                          label: "Login".tr,
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
                                .tr).small(),
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
                ).subHeader(),
              ).paddingAll(20),
              Expanded(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                        "Waiting for authentication. Please finished in the browser."
                            .tr).small(),
                  ),
                ),
              ),
              Row(
                children: [
                  outlinedButton(
                      label: "Back".tr,
                      onPressed: () {
                        accountController.waitingForAuth.value = false;
                      }),
                  const Spacer(),
                ],
              ).paddingAll(20)
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
                ).subHeader(),
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
      await showMoonModal(
      context: context,
      builder: (context) {
        return Dialog(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoonAlert(
                borderColor: Get
                    .context?.moonTheme?.buttonTheme.colors.borderColor
                    .withValues(alpha: 0.5),
                showBorder: true,
                label: Text("I understand this is a free unofficial application.".tr).header(),
                verticalGap: 16,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    outlinedButton(
                      label: "Cancel".tr,
                      onPressed: () {
                        exitLogin = true;
                        Get.back();
                      },
                    ).paddingBottom(16),
                    filledButton(
                      label: "Continue with Webview".tr,
                      onPressed: () {
                        exitLogin = false;
                        useExternal = false;
                        Get.back();
                      },
                    ).paddingBottom(16),
                    filledButton(
                      label: "Continue with External Browser".tr,
                      onPressed: () {
                        exitLogin = false;
                        useExternal = true;
                        Get.back();
                      },
                    ),
                  ],
                )),
          ],
        ));
      });
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
