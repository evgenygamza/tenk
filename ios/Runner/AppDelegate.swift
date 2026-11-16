import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let accessibility = FlutterMethodChannel(
      name: "tenk/accessibility",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    accessibility.setMethodCallHandler { call, result in
      guard call.method == "reduceTransparency" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(UIAccessibility.isReduceTransparencyEnabled)
    }
  }
}
