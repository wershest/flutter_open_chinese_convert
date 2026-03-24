import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert_method_channel.dart';
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert_platform_interface.dart';

class MockFlutterOpenChineseConvertPlatform
    with MockPlatformInterfaceMixin
    implements FlutterOpenChineseConvertPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String> convert(
    String text,
    String optionId, {
    bool inBackground = false,
    bool webIgnoreMissingIdioms = false,
  }) async =>
      text;

  @override
  Future<int> initSession(String optionId, {bool inBackground = false}) async => 1;

  @override
  Future<String> convertWithSession(int sessionId, String text) async => text;

  @override
  Future<void> disposeSession(int sessionId) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final FlutterOpenChineseConvertPlatform initialPlatform =
      FlutterOpenChineseConvertPlatform.instance;

  test('$MethodChannelFlutterOpenChineseConvert is the default instance', () {
    expect(
      initialPlatform,
      isInstanceOf<MethodChannelFlutterOpenChineseConvert>(),
    );
  });

  test('getPlatformVersion', () async {
    MockFlutterOpenChineseConvertPlatform fakePlatform =
        MockFlutterOpenChineseConvertPlatform();
    FlutterOpenChineseConvertPlatform.instance = fakePlatform;

    expect(
      await FlutterOpenChineseConvertPlatform.instance.getPlatformVersion(),
      '42',
    );
  });
}
