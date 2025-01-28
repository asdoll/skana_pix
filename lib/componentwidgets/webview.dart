import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:get/get.dart';
import 'package:skana_pix/controller/theme_controller.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage(this.url, {this.onNavigation, super.key});

  final String url;

  final bool Function(NavigationRequest req)? onNavigation;

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  WebViewController? controller;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
  }

  NavigationDecision handleNavigation(NavigationRequest req) {
    if (widget.onNavigation != null) {
      return widget.onNavigation!(req)
          ? NavigationDecision.navigate
          : NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  @override
  Widget build(BuildContext context) {
    controller ??= WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(
          ThemeManager.instance.isDarkMode ? Colors.white : Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => loadingPercentage = 0),
          onProgress: (int progress) =>
              setState(() => loadingPercentage = progress),
          onPageFinished: (String url) =>
              setState(() => loadingPercentage = 100),
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: handleNavigation,
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top, left: 16, right: 16),
            child: Row(
              children: [
                //const Text("Webview"),
                const Spacer(),
                IconButton.ghost(
                  icon: const Icon(
                    Icons.open_in_new,
                    size: 20,
                  ),
                  onPressed: () {
                    launchUrlString(widget.url);
                    Get.back();
                  },
                ),
              ],
            )),
        LinearProgressIndicator(value: loadingPercentage / 100),
        Expanded(
          child: WebViewWidget(
            controller: controller!,
          ),
        ),
      ],
    );
  }
}
