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
        case "initConverter":
            guard
                let list = call.arguments as? [Any],
                list.count >= 2,
                let option = list[0] as? String,
                let _ = list[1] as? Bool
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
            do {
                let sessionIdNumber = try OpenCCConverter.initSession(withOption: option, dataPath: dataPath)
                if let sessionId = Int(exactly: sessionIdNumber) {
                    result(sessionId)
                } else {
                    result(
                        FlutterError(
                            code: "INIT_FAILED",
                            message: "Failed to initialize converter session.",
                            details: nil))
                }
            } catch {
                result(
                    FlutterError(
                        code: "INIT_FAILED",
                        message: error.localizedDescription,
                        details: nil))
            }
        case "convertWithSession":
            guard
                let list = call.arguments as? [Any],
                list.count >= 3,
                let sessionId = list[0] as? Int,
                let text = list[1] as? String,
                let inBackground = list[2] as? Bool
            else {
                result(
                    FlutterError(
                        code: "MISSING_PARAMETER", message: "Required parameters are missing",
                        details: nil))
                return
            }
            let task = {
                do {
                    let converted = try OpenCCConverter.convert(
                        withSessionId: NSNumber(value: sessionId), text: text)
                    DispatchQueue.main.async { result(converted) }
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
            if inBackground {
                DispatchQueue.global().async(execute: task)
            } else {
                task()
            }
        case "disposeConverter":
            guard
                let list = call.arguments as? [Any],
                list.count >= 1,
                let sessionId = list[0] as? Int
            else {
                result(
                    FlutterError(
                        code: "MISSING_PARAMETER", message: "Required parameters are missing",
                        details: nil))
                return
            }
            OpenCCConverter.disposeSessionId(NSNumber(value: sessionId))
            result(nil)
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
            // Keep one-shot convert backward compatible.
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
