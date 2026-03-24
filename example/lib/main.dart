// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _index = 0;
  final _original = '鼠标里面的硅二极管坏了，导致光标分辨率降低。\n滑鼠裡面的矽二極體壞了，導致游標解析度降低。';
  var _converted = '';

  @override
  void initState() {
    super.initState();
    _convert();
  }

  Future<void> _convert() async {
    var text = _original;
    var option = ChineseConverter.allOptions[_index];
    try {
      var result = await ChineseConverter.convert(
        text,
        option,
        inBackground: true,
      );
      setState(() => _converted = result);
    } on PlatformException catch (e) {
      setState(() => _converted = 'Convert failed: ${e.message ?? e.code}');
    }
  }

  Future<void> _batchConvert() async {
    final option = ChineseConverter.allOptions[_index];
    final texts = List<String>.generate(10, (i) => '[$i] $_original');
    final results = <String>[];
    ChineseConverterSession? session;
    try {
      session = await ChineseConverterSession.create(option, inBackground: true);
      for (final text in texts) {
        final converted = await session.convert(text);
        results.add(converted);
      }
      setState(() => _converted = results.join('\n\n'));
    } on PlatformException catch (e) {
      setState(() => _converted = 'Batch convert failed: ${e.message ?? e.code}');
    } finally {
      await session?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Row(children: <Widget>[Text('Open Chinese Convert')]),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildMenu(context),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Original:',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0), child: Text(_original)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Conveted:',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_converted),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: _batchConvert,
                      child: const Text('批量转换'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget buildMenu(BuildContext context) => PopupMenuButton<int>(
        elevation: 2,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              ChineseConverter.allOptions[_index].chineseDescription,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
        onSelected: (i) {
          _index = i;
          _convert();
        },
        itemBuilder: (context) => List.of(
          ChineseConverter.allOptions
              .asMap()
              .map(
                (i, x) => MapEntry(
                  i,
                  PopupMenuItem(
                    value: i,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 40,
                          child: i == _index
                              ? const Icon(Icons.check)
                              : Container(),
                        ),
                        Expanded(
                          child: Text(
                            x.chineseDescription,
                            style: const TextStyle(fontSize: 12.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .values,
        ),
      );
}
