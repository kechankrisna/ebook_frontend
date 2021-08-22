import UIKit
import Flutter
import flutter_downloader


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
//    let eub_kitty = FlutterMethodChannel(name: "epub_kitty", binaryMessenger: controller.binaryMessenger)
//    eub_kitty.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//        print(call.method)
//        if(!controller.hasPlugin("EpubKittyPlugin")) {
//            let dic: NSDictionary = call.arguments as! NSDictionary
//            let strPath: String = dic.value(forKey: "bookPath") as! String
//            print(strPath)
//            openEPub(strPath: dic.value(forKey: "bookPath") as! String, conteroller: controller)
//        }
//    })
//    let granth_payment_paypal = FlutterMethodChannel(name: "granth_payment_paypal", binaryMessenger: controller.binaryMessenger)
//    granth_payment_paypal.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//        print(call.method)
//        if ("startPaytmPayment" == call.method) {
//            PaytmPlugin.init()
//        } else {
//            result(FlutterMethodNotImplemented)
//        }
//    })
    
    let granth_payment = FlutterMethodChannel(name: "granth_payment", binaryMessenger: controller.binaryMessenger)
    granth_payment.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        print(call.method)
        if(!controller.hasPlugin("PaytmPlugin")) {
            PaytmPlugin.register(with: controller.registrar(forPlugin: "PaytmPlugin")!)
        }
    })

    //GeneratedPluginRegistrant.register(with: self)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private func registerPlugins(registry: FlutterPluginRegistry) {
    if (!registry.hasPlugin("FlutterDownloaderPlugin")) {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
}

//private func openEPub(strPath: String, conteroller: UIViewController) {
//    let config = FolioReaderConfig()
//    //        let bookPath = Bundle.main.path(forResource: "For the Love of Rescue Dogs - Tom Colvin", ofType: "epub")
//    let folioReader = FolioReader()
//    folioReader.presentReader(parentViewController: conteroller, withEpubPath: strPath, andConfig: config)
//}
