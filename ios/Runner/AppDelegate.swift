import Flutter
import UIKit
import UniformTypeIdentifiers
import Foundation // 添加此行

@main
@objc class AppDelegate: FlutterAppDelegate, UIDocumentPickerDelegate {
  var flutterResult: FlutterResult?
  var directoryPath: URL!

  // 定义插件通道名称
  private var directoryPicker: DirectoryPicker?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    guard let controller = window?.rootViewController as? FlutterViewController else {
          fatalError("rootViewController is not of type FlutterViewController")
    }

    let methodChannel = FlutterMethodChannel(name: "com.skanaone.dev/saf", binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler { (call, result) in
      if call.method == "getProxy" {
        if let proxySettings = CFNetworkCopySystemProxySettings()?.takeUnretainedValue() as NSDictionary?,
          let dict = proxySettings.object(forKey: kCFNetworkProxiesHTTPProxy) as? NSDictionary,
          let host = dict.object(forKey: kCFNetworkProxiesHTTPProxy) as? String,
          let port = dict.object(forKey: kCFNetworkProxiesHTTPPort) as? Int {
          let proxyConfig = "\(host):\(port)"
          result(proxyConfig)
        } else {
          result("")
        }
      } else if call.method == "setScreenOn" {
        if let arguments = call.arguments as? Bool {
          let screenOn = arguments
          UIApplication.shared.isIdleTimerDisabled = screenOn
        }
        result(nil)
      } else if call.method == "getDirectoryPath" {
        self.flutterResult = result
        self.getDirectoryPath()
      } else if call.method == "stopAccessingSecurityScopedResource" {
        self.directoryPath?.stopAccessingSecurityScopedResource()
        self.directoryPath = nil
        result(nil)
      } else if call.method == "selectDirectory" {
        self.directoryPicker = DirectoryPicker()
        self.directoryPicker?.selectDirectory(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func getDirectoryPath() {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder], asCopy: false)
    documentPicker.delegate = self
    documentPicker.allowsMultipleSelection = false
    documentPicker.directoryURL = nil
    documentPicker.modalPresentationStyle = .formSheet

    if let rootViewController = window?.rootViewController {
      rootViewController.present(documentPicker, animated: true, completion: nil)
    }
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    self.directoryPath = urls.first
    if self.directoryPath == nil {
      flutterResult?(nil)
      return
    }

    let success = self.directoryPath.startAccessingSecurityScopedResource()

    if success {
      flutterResult?(self.directoryPath.path)
    } else {
      flutterResult?(nil)
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    flutterResult?(nil)
  }
}

class DirectoryPicker: NSObject, UIDocumentPickerDelegate {
    private var result: FlutterResult?

    // 初始化选择目录方法
    func selectDirectory(result: @escaping FlutterResult) {
        self.result = result

        // 配置 UIDocumentPicker 为目录选择模式
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

        // 获取根视图控制器并显示选择器
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    // 处理选择完成后的结果
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // 获取选中的路径
        if let url = urls.first {
            result?(url.path)
        } else {
            result?(nil)
        }
    }

    // 处理取消选择情况
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        result?(nil)
    }
}
