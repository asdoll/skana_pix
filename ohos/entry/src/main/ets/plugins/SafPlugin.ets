/*
 * HarmonyOS implementation of the `com.skanaone.dev/saf` channel used by
 * lib/utils/safplugin.dart (history / settings import and export).
 *
 * Methods:
 *   createFile(name, mimeType) -> uri ('' / null when the user cancels)
 *   writeUri(uri, data)        -> writes the bytes to a previously created uri
 *   openFile(type)             -> bytes of a picked file (null when cancelled)
 *
 * Android uses ACTION_CREATE_DOCUMENT / ACTION_OPEN_DOCUMENT; the equivalent on
 * HarmonyOS is DocumentViewPicker (save / select), which hands back a uri that
 * can be read and written through fileIo.
 */

import {
  AbilityAware,
  AbilityPluginBinding,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';

import { common } from '@kit.AbilityKit';
import { picker, fileIo as fs } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SafPlugin';
const CHANNEL_NAME = 'com.skanaone.dev/saf';

export default class SafPlugin implements FlutterPlugin, MethodCallHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private context: common.UIAbilityContext | null = null;

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    this.channel = new MethodChannel(binding.getBinaryMessenger(), CHANNEL_NAME);
    this.channel.setMethodCallHandler(this);
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    if (this.channel !== null) {
      this.channel.setMethodCallHandler(null);
      this.channel = null;
    }
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    this.context = binding.getAbility().context;
  }

  onDetachedFromAbility(): void {
    this.context = null;
  }

  getUniqueClassName(): string {
    return TAG;
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    switch (call.method) {
      case 'createFile':
        this.createFile(call.argument('name') as string, call.argument('mimeType') as string)
          .then((uri: string | null) => {
            result.success(uri);
          })
          .catch((error: BusinessError) => {
            hilog.error(0, TAG, `createFile failed: ${JSON.stringify(error)}`);
            result.error('CreateFileFailed', error.message, null);
          });
        break;
      case 'writeUri':
        this.writeUri(call.argument('uri') as string, call.argument('data') as Uint8Array)
          .then(() => {
            result.success(null);
          })
          .catch((error: BusinessError) => {
            hilog.error(0, TAG, `writeUri failed: ${JSON.stringify(error)}`);
            result.error('WriteUriFailed', error.message, null);
          });
        break;
      case 'openFile':
        this.openFile(call.argument('type') as string)
          .then((bytes: Uint8Array | null) => {
            result.success(bytes);
          })
          .catch((error: BusinessError) => {
            hilog.error(0, TAG, `openFile failed: ${JSON.stringify(error)}`);
            result.error('OpenFileFailed', error.message, null);
          });
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  /** Shows the system "save as" dialog and returns the uri to write into. */
  private async createFile(name: string, mimeType: string): Promise<string | null> {
    const context = this.requireContext();
    const options = new picker.DocumentSaveOptions();
    if (name !== null && name !== undefined && name.length > 0) {
      options.newFileNames = [name];
    }
    const suffix = SafPlugin.suffixOfName(name);
    if (suffix.length > 0) {
      options.fileSuffixChoices = [suffix];
    }
    const documentPicker = new picker.DocumentViewPicker(context);
    const uris: Array<string> = await documentPicker.save(options);
    if (uris === null || uris === undefined || uris.length === 0) {
      // The user dismissed the dialog.
      return null;
    }
    return uris[0];
  }

  /** Writes [data] to the uri returned by [createFile]. */
  private async writeUri(uri: string, data: Uint8Array): Promise<void> {
    if (uri === null || uri === undefined || uri.length === 0) {
      throw new Error('uri is empty');
    }
    if (data === null || data === undefined) {
      throw new Error('data is empty');
    }
    const file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    try {
      fs.writeSync(file.fd, data);
    } finally {
      fs.closeSync(file);
    }
  }

  /** Shows the system file picker and returns the picked file's bytes. */
  private async openFile(type: string): Promise<Uint8Array | null> {
    const context = this.requireContext();
    const options = new picker.DocumentSelectOptions();
    options.maxSelectNumber = 1;
    const filters = SafPlugin.suffixFiltersOfMimeType(type);
    if (filters.length > 0) {
      options.fileSuffixFilters = filters;
    }
    const documentPicker = new picker.DocumentViewPicker(context);
    const uris: Array<string> = await documentPicker.select(options);
    if (uris === null || uris === undefined || uris.length === 0) {
      // The user dismissed the dialog.
      return null;
    }
    const file = fs.openSync(uris[0], fs.OpenMode.READ_ONLY);
    try {
      const stat = fs.statSync(file.fd);
      if (stat.size <= 0) {
        return new Uint8Array(0);
      }
      const buffer = new ArrayBuffer(stat.size);
      const readLength = fs.readSync(file.fd, buffer);
      return new Uint8Array(buffer.slice(0, readLength));
    } finally {
      fs.closeSync(file);
    }
  }

  private requireContext(): common.UIAbilityContext {
    if (this.context === null || this.context === undefined) {
      throw new Error('SafPlugin is not attached to a UIAbility yet');
    }
    return this.context;
  }

  /** '.json' for 'illusthis.json', empty when the name has no suffix. */
  private static suffixOfName(name: string): string {
    if (name === null || name === undefined) {
      return '';
    }
    const dot = name.lastIndexOf('.');
    if (dot <= 0 || dot === name.length - 1) {
      return '';
    }
    return name.substring(dot).toLowerCase();
  }

  /**
   * The Dart side only ever asks for JSON, but keep this tolerant so a future
   * call with another mime type still gets a sensible picker filter.
   */
  private static suffixFiltersOfMimeType(mimeType: string): Array<string> {
    if (mimeType === null || mimeType === undefined) {
      return [];
    }
    const type = mimeType.toLowerCase();
    if (type.includes('json')) {
      return ['.json'];
    }
    if (type.includes('text')) {
      return ['.txt'];
    }
    if (type.includes('image')) {
      return ['.png', '.jpg', '.jpeg', '.gif', '.webp'];
    }
    return [];
  }
}
