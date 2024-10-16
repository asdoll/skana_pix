import 'package:flutter/material.dart';
import 'package:skana_pix/pixiv_dart_api.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../componentwidgets/webview.dart';
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Login".i18n,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 96,
                            child: TextButton(
                              onPressed: onContinue,
                              child: Text("Continue".i18n),
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
    bool? useExternal;
    bool exitLogin = false;
    await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          var alertDialog = AlertDialog(
              content: Text("I understand this is a free unofficial application.".i18n),
              actions: [
                TextButton(
                  child: Text("Cancel".i18n),
                  onPressed: () {
                    exitLogin = true;
                    DynamicData.rootNavigatorKey.currentState!.pop();
                  },
                ),
                TextButton(
                  child: Text("Continue".i18n),
                  onPressed: () {
                    exitLogin = false;
                    DynamicData.rootNavigatorKey.currentState!.pop();
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    putBackUserData();
                    exitLogin = true;
                    DynamicData.rootNavigatorKey.currentState!.pop();
                  },
                  child: const Text("put back login data"),
                ),
              ]);
          return alertDialog;
        },
      );
    if (exitLogin) {
      return;
    }
    useExternal = DynamicData.isMobile;
    var url = await ConnectManager().apiClient.generateWebviewUrl();
    bool Function(dynamic uri)? onLink;
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
    var res = await ConnectManager().apiClient.loginWithCode(code);
    if (res.error) {
      if (mounted) {
        context.showToast(message: res.errorMessage!);
      }
      setState(() {
        isLogging = false;
      });
    } else {
      widget.callback();
    }
  }
}
