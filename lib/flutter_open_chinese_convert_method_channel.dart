import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_open_chinese_convert_platform_interface.dart';

/// An implementation of [FlutterOpenChineseConvertPlatform] that uses method channels.
class MethodChannelFlutterOpenChineseConvert
    extends FlutterOpenChineseConvertPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_open_chinese_convert');
  int _nextSessionId = 1;
  final Map<int, String> _localSessionOptions = <int, String>{};
  final Set<int> _nativeSessionIds = <int>{};
  final Map<int, bool> _sessionInBackground = <int, bool>{};

  /// Returns the current platform version string, or `null` if unavailable.
  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<String> convert(
    String text,
    String optionId, {
    bool inBackground = false,
    bool webIgnoreMissingIdioms = false,
  }) async {
    final String result = await methodChannel.invokeMethod(
      'convert',
      [text, optionId, inBackground, webIgnoreMissingIdioms],
    );
    return result;
  }

  @override
  Future<int> initSession(
    String optionId, {
    bool inBackground = false,
  }) async {
    try {
      final int? nativeId = await methodChannel.invokeMethod<int>(
        'initConverter',
        [optionId, inBackground],
      );
      if (nativeId != null) {
        _nativeSessionIds.add(nativeId);
        _sessionInBackground[nativeId] = inBackground;
        return nativeId;
      }
    } on PlatformException {
      // Fallback to local session emulation when native session is unavailable.
    } on MissingPluginException {
      // Fallback to local session emulation when native session is unavailable.
    }

    final int sessionId = _nextSessionId++;
    _localSessionOptions[sessionId] = optionId;
    _sessionInBackground[sessionId] = inBackground;
    return sessionId;
  }

  @override
  Future<String> convertWithSession(int sessionId, String text) async {
    if (_nativeSessionIds.contains(sessionId)) {
      final bool inBackground = _sessionInBackground[sessionId] ?? false;
      final String? result = await methodChannel.invokeMethod<String>(
        'convertWithSession',
        [sessionId, text, inBackground],
      );
      if (result == null) {
        throw PlatformException(
          code: 'NULL_RESULT',
          message: 'Native converter returned null.',
        );
      }
      return result;
    }

    final optionId = _localSessionOptions[sessionId];
    if (optionId == null) {
      throw PlatformException(
        code: 'INVALID_SESSION',
        message: 'Session does not exist or has been disposed.',
      );
    }
    return convert(
      text,
      optionId,
      inBackground: _sessionInBackground[sessionId] ?? false,
    );
  }

  @override
  Future<void> disposeSession(int sessionId) async {
    if (_nativeSessionIds.remove(sessionId)) {
      _sessionInBackground.remove(sessionId);
      try {
        await methodChannel.invokeMethod<void>('disposeConverter', [sessionId]);
      } on PlatformException {
        // Best effort cleanup.
      } on MissingPluginException {
        // Best effort cleanup.
      }
      return;
    }
    _localSessionOptions.remove(sessionId);
    _sessionInBackground.remove(sessionId);
  }
}
