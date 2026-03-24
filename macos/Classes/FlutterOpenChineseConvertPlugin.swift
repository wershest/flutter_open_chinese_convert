import Cocoa
import FlutterMacOS

public class FlutterOpenChineseConvertPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_open_chinese_convert", binaryMessenger: registrar.messenger)
        let instance = FlutterOpenChineseConvertPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "convert":
            guard
                let list = call.arguments as? [Any],
                list.count >= 3,
                let text = list[0] as? String,
                let option = list[1] as? String,
                let inBackground = list[2] as? Bool
            else {
                result(
                    FlutterError(
                        code: "MISSING_PARAMETER", message: "Required parameters are missing",
                        details: nil))
                return
            }
            guard let dataPath = resourceBundle()?.resourcePath else {
                result(
                    FlutterError(
                        code: "NO_BUNDLE",
                        message: "OpenCC resource bundle was not found.",
                        details: nil))
                return
            }
            if inBackground {
                DispatchQueue.global().async {
                    self.convert(text: text, option: option, dataPath: dataPath, result: result)
                }
            } else {
                convert(text: text, option: option, dataPath: dataPath, result: result)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func resourceBundle() -> Bundle? {
        let podBundle = Bundle(for: Self.self)
        guard
            let bundleURL = podBundle.url(
                forResource: "flutter_open_chinese_convert_resources", withExtension: "bundle")
        else {
            return nil
        }
        return Bundle(url: bundleURL)
    }

    private func convert(text: String, option: String, dataPath: String, result: @escaping FlutterResult) {
        do {
            let converted = try OpenCCConverter.convertText(
                text, option: option, dataPath: dataPath)
            DispatchQueue.main.async {
                result(converted)
            }
        } catch {
            DispatchQueue.main.async {
                result(
                    FlutterError(
                        code: "CONVERT_FAILED",
                        message: error.localizedDescription,
                        details: nil))
            }
        }
    }
}
