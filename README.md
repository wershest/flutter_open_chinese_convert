# flutter_open_chinese_convert

[![pub package](https://img.shields.io/pub/v/flutter_open_chinese_convert.svg)](https://pub.dev/packages/flutter_open_chinese_convert)
[![Build](https://github.com/zonble/flutter_open_chinese_convert/actions/workflows/ci.yml/badge.svg)](https://github.com/zonble/flutter_open_chinese_convert/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/zonble/flutter_open_chinese_convert/blob/main/LICENSE)

flutter_open_chinese_convert bridges [OpenCC](https://github.com/BYVoid/OpenCC)
(開放中文轉換 / Open Chinese Convert) to your Flutter projects. You can use the
package to convert between Traditional and Simplified Chinese across multiple
regional standards.

## Supported Platforms

| Platform | Support |
|----------|---------|
| Android  | ✅ (min SDK 24 / Android 7.0) |
| iOS      | ✅ |
| Web      | ✅ |

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_open_chinese_convert: ^0.9.0
```

Then run:

```bash
flutter pub get
```

## Conversion Options

The package supports the following conversion options:

| Class     | ID      | Description                                                                          |
|-----------|---------|--------------------------------------------------------------------------------------|
| `S2T`     | `s2t`   | Simplified Chinese → Traditional Chinese                                             |
| `T2S`     | `t2s`   | Traditional Chinese → Simplified Chinese                                             |
| `S2HK`    | `s2hk`  | Simplified Chinese → Traditional Chinese (Hong Kong Standard)                        |
| `HK2S`    | `hk2s`  | Traditional Chinese (Hong Kong Standard) → Simplified Chinese                        |
| `S2TW`    | `s2tw`  | Simplified Chinese → Traditional Chinese (Taiwan Standard)                           |
| `TW2S`    | `tw2s`  | Traditional Chinese (Taiwan Standard) → Simplified Chinese                           |
| `S2TWp`   | `s2twp` | Simplified Chinese → Traditional Chinese (Taiwan Standard) with Taiwanese idiom      |
| `TW2Sp`   | `tw2sp` | Traditional Chinese (Taiwan Standard) → Simplified Chinese with Mainland Chinese idiom |

You can also retrieve the list of all available options at runtime:

```dart
List<ConverterOption> options = ChineseConverter.allOptions;
```

## Usage

Call `ChineseConverter.convert` with the text to convert and a conversion
option:

```dart
import 'package:flutter_open_chinese_convert/flutter_open_chinese_convert.dart';

var text = '鼠标里面的硅二极管坏了，导致光标分辨率降低。';
var result = await ChineseConverter.convert(text, S2TWp());
// 滑鼠裡面的矽二極體壞了，導致游標解析度降低。
```

### Running conversion in the background

Pass `inBackground: true` to perform the conversion on a native background
thread (Android: Kotlin coroutine on the `IO` dispatcher; iOS:
`DispatchQueue.global()`). This is recommended for large text inputs to avoid
blocking the UI thread:

```dart
var result = await ChineseConverter.convert(
  text,
  S2TWp(),
  inBackground: true,
);
```

### Web: handling unsupported idiom conversion

The web implementation uses [opencc-js](https://github.com/nk2028/opencc-js) loaded from a CDN. OpenCC-JS does not support the `TW2Sp` (Traditional Chinese with Mainland Chinese idiom) option. Calling `convert` with `TW2Sp()` on the web will throw an `UnimplementedError` by default.

To fall back to standard Traditional → Simplified conversion without idiom
substitution instead of throwing an error, pass `webIgnoreMissingIdioms: true`:

```dart
var result = await ChineseConverter.convert(
  text,
  TW2Sp(),
  webIgnoreMissingIdioms: true, // falls back to TW2S on web
);
```

### Web: loading the OpenCC-JS library

On the web platform, the library dynamically loads
`opencc-js` from the [jsDelivr CDN](https://www.jsdelivr.com/) the first time
`convert` is called. No additional setup is required, but the user's device must
have internet access to reach the CDN on the first conversion call.

To use the package on the web, add the following to your `web/index.html` — or
let the plugin load it automatically via script injection:

```html
<!-- Optional: pre-load to avoid delay on first conversion -->
<script src="https://cdn.jsdelivr.net/npm/opencc-js@1.0.5/dist/umd/full.js"></script>
```

## Android: 16KB page size alignment

Starting with Android 15, devices may use a 16KB memory page size. This package
builds its native library (`libChineseConverter.so`) with the
`-Wl,-z,max-page-size=16384` linker flag, ensuring compatibility with Android
15+ devices without any additional configuration needed on your part.

## References

- [OpenCC Project](https://github.com/BYVoid/OpenCC)
- [opencc-js](https://github.com/nk2028/opencc-js)
- [SwiftyOpenCC](https://github.com/ddddxxx/SwiftyOpenCC)
