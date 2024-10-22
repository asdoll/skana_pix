import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../componentwidgets/webview.dart';
import '../utils/applinks.dart';
import '../utils/navigation.dart';
import '../utils/translate.dart';
import 'defaults.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(this.callback, {super.key});

  final void Function() callback;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool checked = false;

  bool waitingForAuth = false;

  bool isLogging = false;

  @override
  Widget build(BuildContext context) {
    if (isLogging) {
      return buildLoading(context);
    } else if (!waitingForAuth) {
      return buildLogin(context);
    } else {
      return buildWaiting(context);
    }
  }

  Widget buildLogin(BuildContext context) {
    return SizedBox(
      child: Center(
        child: Card(
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
                      ("     ${"SkanaPix".i18n}"),
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
                            child: FilledButton(
                              onPressed: onContinue,
                              child: Text("Login".i18n),
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
                                    .i18n),
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
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Waiting...".i18n,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Text(
                            "Waiting for authentication. Please finished in the browser."
                                .i18n),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                          child: Text("Back".i18n),
                          onPressed: () {
                            setState(() {
                              waitingForAuth = false;
                            });
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
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: SizedBox(
              width: 300,
              height: 300,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Logging in".i18n,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator.adaptive(),
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
    if (DynamicData.isMobile) {
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          var alertDialog = AlertDialog(
              content: Text(
                  "I understand this is a free unofficial application.".i18n),
              actions: [
                TextButton(
                  child: Text("Cancel".i18n),
                  onPressed: () {
                    exitLogin = true;
                    DynamicData.rootNavigatorKey.currentState!.pop();
                  },
                ),
                TextButton(
                  child: Text("Continue with Webview".i18n),
                  onPressed: () {
                    exitLogin = false;
                    useExternal = false;
                    DynamicData.rootNavigatorKey.currentState!.pop();
                  },
                ),
                TextButton(
                  child: Text("Continue with External Browser".i18n),
                  onPressed: () {
                    exitLogin = false;
                    useExternal = true;
                    DynamicData.rootNavigatorKey.currentState!.pop();
                  },
                ),
              ]);
          return alertDialog;
        },
      );
    }
    if (exitLogin) {
      return;
    }
    var url = await generateWebviewUrl();
    onLink = (uri) {
      if (uri.scheme == "pixiv") {
        onFinished(uri.queryParameters["code"]!);
        onLink = null;
        return true;
      }
      return false;
    };
    setState(() {
      waitingForAuth = true;
    });
    if (!useExternal && mounted) {
      context.to(() => WebviewPage(
            url,
            onNavigation: (req) {
              if (req.url.startsWith("pixiv://")) {
                DynamicData.rootNavigatorKey.currentState!.pop();
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

  void onFinished(String code) async {
    setState(() {
      isLogging = true;
      waitingForAuth = false;
    });
    var res = await loginWithCode(code);
    if (res.error) {
      if (mounted) {
        BotToast.showText(text: res.errorMessage!);
      }
      setState(() {
        isLogging = false;
      });
    } else {
      widget.callback();
    }
  }
}
