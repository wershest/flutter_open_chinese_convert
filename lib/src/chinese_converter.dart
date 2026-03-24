import 'dart:async';

import '../flutter_open_chinese_convert_platform_interface.dart';
import 'options.dart';

/// The Chinese converter.
class ChineseConverter {
  static final List<ConverterOption> _options = [
    S2T(),
    T2S(),
    S2HK(),
    HK2S(),
    S2TW(),
    TW2S(),
    S2TWp(),
    TW2Sp(),
  ];

  /// All available options.
  static List<ConverterOption> get allOptions => _options;

  /// Converter input [text] with a given [option].
  ///
  /// For example:
  ///
  /// ``` dart
  /// var text = '鼠标里面的硅二极管坏了，导致光标分辨率降低。';
  /// var result = await ChineseConverter.convert(text, S2TWp());
  /// ```
  ///
  /// You can pass the [inBackground] parameter if you want to create native
  /// threads while doing text conversion.
  ///
  /// OpenCC-JS does not support simplified idioms and will throw
  /// UnimplementedError if using the sp option.
  /// You can pass the [webIgnoreMissingIdioms] parameter to ignore the missing
  /// idioms and run the conversion using the standard simplified dictionary.
  static Future<String> convert(String text, ConverterOption option,
      {bool inBackground = false, bool webIgnoreMissingIdioms = false}) async {
    return FlutterOpenChineseConvertPlatform.instance.convert(
      text,
      option.id,
      inBackground: inBackground,
      webIgnoreMissingIdioms: webIgnoreMissingIdioms,
    );
  }
}

/// A reusable converter session that avoids reinitializing native converters.
class ChineseConverterSession {
  ChineseConverterSession._(this._sessionId, this._option);

  final int _sessionId;
  final ConverterOption _option;
  bool _disposed = false;

  /// Creates a reusable converter session for [option].
  static Future<ChineseConverterSession> create(
    ConverterOption option, {
    bool inBackground = false,
  }) async {
    final sessionId = await FlutterOpenChineseConvertPlatform.instance
        .initSession(option.id, inBackground: inBackground);
    return ChineseConverterSession._(sessionId, option);
  }

  /// Converts [text] using the initialized session.
  Future<String> convert(String text) async {
    if (_disposed) {
      throw StateError('ChineseConverterSession has been disposed.');
    }
    return FlutterOpenChineseConvertPlatform.instance
        .convertWithSession(_sessionId, text);
  }

  /// The option associated with this session.
  ConverterOption get option => _option;

  /// Disposes the session and releases associated native resources.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await FlutterOpenChineseConvertPlatform.instance.disposeSession(_sessionId);
  }
}
