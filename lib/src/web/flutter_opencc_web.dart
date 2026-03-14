import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/services.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart';

import '../../flutter_open_chinese_convert_platform_interface.dart';
import 'option_pair.dart';

/// Creates an OpenCC converter instance from the given [options] object.
///
/// This calls the `OpenCC.Converter` JavaScript constructor, which returns a
/// function that accepts a string and produces the converted output.
@JS('OpenCC.Converter')
external JSFunction Converter(JSAny options);

/// The web implementation of [FlutterOpenChineseConvertPlatform].
///
/// Uses the [opencc-js](https://github.com/nk2028/opencc-js) library loaded
/// from a CDN to perform Chinese text conversion in the browser.
class FlutterOpenccWeb extends FlutterOpenChineseConvertPlatform {
  /// Creates a new instance of [FlutterOpenccWeb].
  FlutterOpenccWeb();

  /// Registers this class as the platform implementation for the web.
  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
        "flutter_open_chinese_convert", const StandardMethodCodec(), registrar);
    final FlutterOpenccWeb instance = FlutterOpenccWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);
  }

  /// Handles incoming method calls from the Flutter framework.
  ///
  /// Supports the `convert` method with arguments `[text, option,
  /// inBackground, webIgnoreMissingIdioms]`.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'convert':
        return _convert(
            call.arguments[0], //text
            call.arguments[1], //option
            call.arguments[3] //ignore unimplemented simplified idioms
            );
    }
  }

  Future<String> _convert(String text, String option, bool ignoreSp) async {
    OptionPair options;
    await loadLibrary();

    if (option == 'tw2sp') {
      ignoreSp
          ? options = OptionPair.tw2s
          : throw UnimplementedError(
              "Simplified idioms are not supported by OpenCC-JS. Set webIgnoreMissingIdioms when calling convert() to suppress this error.");
    } else {
      options = OptionPair.optionMap[option]!;
    }

    JSFunction converterInstance =
        Converter({"to": options.to, "from": options.from}.jsify()!);
    JSAny? result = converterInstance.callAsFunction(null, text.toJS);
    return (result as JSString).toDart;
  }

  /// Dynamically loads the opencc-js library from a CDN into the page if it
  /// has not already been loaded.
  ///
  /// Appends a `<script>` element to `document.head` and waits for it to
  /// finish loading before resolving.  Subsequent calls are no-ops when the
  /// script element is already present.
  Future<void> loadLibrary() async {
    final String scriptId = 'flutter-open-chinese-convert';
    if (document.querySelector('script#$scriptId') != null) {
      return;
    }

    final scriptUrl =
        "https://cdn.jsdelivr.net/npm/opencc-js@1.0.5/dist/umd/full.js";
    final completer = Completer<void>();

    final script = HTMLScriptElement()
      ..id = scriptId
      ..async = true
      ..defer = false
      ..type = 'application/javascript'
      ..crossOrigin = 'anonymous'
      ..src = scriptUrl
      ..onload = (JSAny _) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      }.toJS
      ..onerror = (JSAny error) {
        if (!completer.isCompleted) {
          completer.completeError(
              Exception('Failed to load OpenCC-JS library from CDN: $error'));
        }
      }.toJS;

    document.head!.appendChild(script);
    await completer.future;
  }
}
