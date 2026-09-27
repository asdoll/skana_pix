/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import {
  AbilityAware,
  AbilityPluginBinding,
  Any,
  FlutterPlugin,
  FlutterPluginBinding,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
  NewWantListener,
} from '@ohos/flutter_ohos';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import EventChannel, { EventSink, StreamHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/EventChannel';

const TAG: string = 'AppLinksPlugin';

/** AppLinksPlugin **/
export default class AppLinksPlugin implements FlutterPlugin, MethodCallHandler, NewWantListener, StreamHandler, AbilityAware {
  private channel: MethodChannel | null = null;
  private eventChannel: EventChannel | null = null;
  private initialLink: string | null = null;
  private latestLink: string | null = null;
  private eventSink: EventSink | null = null;
  private abilityBinding: AbilityPluginBinding | null = null;
  // Align with Android: deliver initial link via EventChannel only once.
  private initialLinkSent: boolean = false;

  constructor() {
  }

  onAttachedToAbility(binding: AbilityPluginBinding): void {
    // 幂等防护：若已绑定同一 binding 则跳过，避免重复注册 NewWantListener
    if (this.abilityBinding === binding) {
      return;
    }
    // 若绑定到新的 Ability，先释放旧的监听器
    if (this.abilityBinding) {
      this.onDetachedFromAbility();
    }
    try {
      const ability = binding.getAbility();
      const launchWant: Want | undefined = ability.launchWant;
      if (launchWant) {
        // Explicit empty-string handling: treat '' the same as missing uri.
        const uri: string | undefined = launchWant.uri;
        if (uri !== undefined && uri !== null && uri.length > 0) {
          this.initialLink = uri;
          this.latestLink = uri;
        } else {
          this.initialLink = null;
          this.latestLink = null;
        }
      }
      binding.addOnNewWantListener(this);
      // 仅在成功注册监听器后设置 binding，避免异常后状态不一致
      this.abilityBinding = binding;
    } catch (e) {
      let err = e as Error;
      console.error(`${TAG} onAttachedToAbility error: ${err.message}`);
    }
  }

  onDetachedFromAbility(): void {
    try {
      if (this.abilityBinding) {
        this.abilityBinding.removeOnNewWantListener(this);
        this.abilityBinding = null;
      }
      this.initialLink = null;
      this.latestLink = null;
      this.initialLinkSent = false;
    } catch (e) {
      let err = e as Error;
      console.error(`${TAG} onDetachedFromAbility error: ${err.message}`);
    }
  }

  onListen(args: Any, events: EventSink): void {
    try {
      if (!events) {
        console.error(`${TAG} onListen: events is null`);
        return;
      }
      this.eventSink = events;
      if (!this.initialLinkSent && this.initialLink) {
        this.initialLinkSent = true;
        events.success(this.initialLink);
      }
    } catch (e) {
      let err = e as Error;
      console.error(`${TAG} onListen error: ${err.message}`);
    }
  }

  onCancel(args: Any): void {
    this.eventSink = null;
  }

  onNewWant(want: Want, launchParams: AbilityConstant.LaunchParam): void {
    try {
      if (want.uri) {
        // Design: only update latestLink for warm/new intents (align Android handleIntent).
        // initialLink stays as the cold-start launch uri and is never overwritten here.
        this.latestLink = want.uri;
        this.eventSink?.success(want.uri);
      }
      // Align with Android: do not emit when uri is empty/null.
    } catch (e) {
      // Avoid double callback if success() already threw; only log here.
      let err = e as Error;
      console.error(`${TAG} onNewWant error: ${err.message}`);
    }
  }

  getUniqueClassName(): string {
    return "AppLinksPlugin"
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    try {
      this.channel = new MethodChannel(binding.getBinaryMessenger(), "com.llfbandit.app_links/messages");
      this.channel.setMethodCallHandler(this);
      this.eventChannel = new EventChannel(binding.getBinaryMessenger(), "com.llfbandit.app_links/events");
      this.eventChannel.setStreamHandler(this);
    } catch (e) {
      let err = e as Error;
      console.error(`${TAG} onAttachedToEngine error: ${err.message}`);
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding): void {
    try {
      // Ordering: detach Ability first so NewWantListener / abilityBinding are cleared
      // before MethodChannel/EventChannel handlers are nulled, avoiding listener leaks
      // when Engine is destroyed while Ability binding is still active.
      this.onDetachedFromAbility();
      if (this.channel != null) {
        this.channel.setMethodCallHandler(null);
      }
      if (this.eventChannel != null) {
        this.eventChannel.setStreamHandler(null);
      }
      this.channel = null;
      this.eventChannel = null;
      this.eventSink = null;
      this.initialLink = null;
      this.latestLink = null;
      this.initialLinkSent = false;
    } catch (e) {
      let err = e as Error;
      console.error(`${TAG} onDetachedFromEngine error: ${err.message}`);
    }
  }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    if (!call || !call.method) {
      result.error("INVALID_ARGUMENT", "Method call or method name is null", null);
      return;
    }
    let replied: boolean = false;
    try {
      if (call.method == "getLatestLink") {
        result.success(this.latestLink);
        replied = true;
        return;
      } else if (call.method == "getInitialLink") {
        result.success(this.initialLink);
        replied = true;
        return;
      } else {
        result.notImplemented();
        replied = true;
        return;
      }
    } catch (e) {
      let err = e as Error;
      console.error(`${TAG} onMethodCall error: ${err.message}`);
      // Ensure Dart Future always completes if failure happened before reply.
      if (!replied) {
        try {
          result.error("APPLINKS_ERROR", `Method call failed: ${err.message}`, null);
        } catch (replyErr) {
          let replyError = replyErr as Error;
          console.error(`${TAG} onMethodCall result.error failed: ${replyError.message}`);
        }
      }
    }
  }
}
