import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_open_chinese_convert_method_channel.dart';

/// The interface that platform-specific implementations of this plugin must
/// implement.
///
/// Platform implementations should extend this class rather than implement it,
/// to avoid breaking changes when new methods are added.
abstract class FlutterOpenChineseConvertPlatform extends PlatformInterface {
  /// Constructs a FlutterOpenChineseConvertPlatform.
  FlutterOpenChineseConvertPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOpenChineseConvertPlatform _instance =
      MethodChannelFlutterOpenChineseConvert();

  /// The default instance of [FlutterOpenChineseConvertPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOpenChineseConvert].
  static FlutterOpenChineseConvertPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOpenChineseConvertPlatform] when
  /// they register themselves.
  static set instance(FlutterOpenChineseConvertPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the current platform version string, or `null` if unavailable.
  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Converts [text] using conversion [optionId].
  Future<String> convert(
    String text,
    String optionId, {
    bool inBackground = false,
    bool webIgnoreMissingIdioms = false,
  }) {
    throw UnimplementedError('convert() has not been implemented.');
  }

  /// Initializes a reusable converter session and returns its session id.
  Future<int> initSession(
    String optionId, {
    bool inBackground = false,
  }) {
    throw UnimplementedError('initSession() has not been implemented.');
  }

  /// Converts [text] using an existing converter [sessionId].
  Future<String> convertWithSession(
    int sessionId,
    String text,
  ) {
    throw UnimplementedError('convertWithSession() has not been implemented.');
  }

  /// Disposes an existing converter [sessionId].
  Future<void> disposeSession(int sessionId) {
    throw UnimplementedError('disposeSession() has not been implemented.');
  }
}
