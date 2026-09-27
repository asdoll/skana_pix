import 'package:skana_pix/controller/logging.dart';
import 'package:skana_pix/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

export 'package:skana_pix/utils/platform_utils.dart' show isOhos;

/// Launch mode to use for a plain web link.
///
/// `url_launcher_ohos` routes [LaunchMode.platformDefault] for http(s) links to
/// an in-app browser page, which has to be added to the HarmonyOS project by
/// hand (`harmony_browser_page` header plus a registered ArkTS route). Without
/// that page the call fails with `ACTIVITY_NOT_FOUND`, so on HarmonyOS the
/// external browser is requested explicitly instead.
LaunchMode get browserLaunchMode =>
    isOhos ? LaunchMode.externalApplication : LaunchMode.platformDefault;

/// Opens [url] in an external browser, never throwing.
///
/// Returns false when the link could not be handed to another app, so callers
/// can fall back to their own webview.
Future<bool> openInBrowser(String url, {LaunchMode? mode}) async {
  final Uri? uri = Uri.tryParse(url);
  if (uri == null) return false;
  try {
    return await launchUrl(uri, mode: mode ?? browserLaunchMode);
  } catch (e, s) {
    log.e("failed to open $url: $e", error: "$s");
    return false;
  }
}
