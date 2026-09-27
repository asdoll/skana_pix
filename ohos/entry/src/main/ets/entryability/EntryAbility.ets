
import { FlutterAbility, FlutterEngine } from '@ohos/flutter_ohos';
import { GeneratedPluginRegistrant } from '../plugins/GeneratedPluginRegistrant';
import SafPlugin from '../plugins/SafPlugin';

export default class EntryAbility extends FlutterAbility {
  configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    GeneratedPluginRegistrant.registerWith(flutterEngine)
    // App-local channel (com.skanaone.dev/saf): file import/export on HarmonyOS.
    flutterEngine.getPlugins()?.add(new SafPlugin());
  }
}
