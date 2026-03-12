# GitHub Copilot Instructions for flutter_open_chinese_convert

## Project Overview

`flutter_open_chinese_convert` is a Flutter plugin that bridges
[OpenCC](https://github.com/BYVoid/OpenCC) (開放中文轉換 / Open Chinese Convert) to Flutter
projects. It enables conversion between Traditional and Simplified Chinese across multiple regional
standards.

Supported conversion options:

| ID      | Description                                                                          |
|---------|--------------------------------------------------------------------------------------|
| `s2t`   | Simplified Chinese → Traditional Chinese                                             |
| `t2s`   | Traditional Chinese → Simplified Chinese                                             |
| `s2hk`  | Simplified Chinese → Traditional Chinese (Hong Kong Standard)                        |
| `hk2s`  | Traditional Chinese (Hong Kong Standard) → Simplified Chinese                        |
| `s2tw`  | Simplified Chinese → Traditional Chinese (Taiwan Standard)                           |
| `tw2s`  | Traditional Chinese (Taiwan Standard) → Simplified Chinese                           |
| `s2twp` | Simplified Chinese → Traditional Chinese (Taiwan Standard) with Taiwanese idiom      |
| `tw2sp` | Traditional Chinese (Taiwan Standard) → Simplified Chinese with Mainland Chinese idiom |

The plugin supports **Android**, **iOS**, and **Web**.

---

## Repository Structure

```
flutter_open_chinese_convert/
├── android/                        # Android platform implementation
│   ├── build.gradle                # Android build config (Kotlin, CMake, min SDK 24)
│   ├── settings.gradle
│   └── src/main/
│       ├── cpp/
│       │   ├── CMakeLists.txt      # CMake build for the native OpenCC library
│       │   ├── chineseconverter.cpp
│       │   └── OpenCC/             # Full copy of OpenCC source (see note below)
│       └── kotlin/.../
│           └── FlutterOpenccPlugin.kt  # Kotlin plugin entry point
├── ios/
│   ├── flutter_open_chinese_convert/
│   │   ├── Package.swift           # Swift Package Manager manifest
│   │   └── Sources/.../
│   │       └── FlutterOpenChineseConvertPlugin.swift  # Swift plugin entry point
│   ├── flutter_open_chinese_convert.podspec  # CocoaPods spec (legacy)
│   └── legacy/                     # Legacy CocoaPods Swift source
├── lib/
│   ├── flutter_open_chinese_convert.dart          # Public API entry point
│   ├── flutter_open_chinese_convert_method_channel.dart
│   ├── flutter_open_chinese_convert_platform_interface.dart
│   └── src/
│       ├── chinese_converter.dart  # ChineseConverter class
│       ├── options.dart            # ConverterOption classes
│       └── web/                    # Web implementation (Dart/JS)
├── test/                           # Unit tests
├── example/                        # Example Flutter app
├── analysis_options.yaml           # Dart linting rules (flutter_lints)
├── .swift-format                   # Swift formatting rules
├── .fvmrc                          # Flutter Version Manager config (Flutter 3.38.0)
└── pubspec.yaml
```

### Important Note: Bundled OpenCC for Android

The plugin includes a **full copy of OpenCC** in `android/src/main/cpp/OpenCC/`. This is
intentional. The upstream
[android-opencc](https://github.com/qichuan/android-opencc) library was not updated to fix the
Android 16KB memory page size requirement (needed for Android 15+). Because that maintainer has not
published an update, we vendor the OpenCC C++ source directly and build it via CMake. The 16KB
linker flag is set in `CMakeLists.txt`:

```cmake
target_link_options(ChineseConverter PRIVATE "-Wl,-z,max-page-size=16384")
```

Do **not** replace the bundled OpenCC with a dependency on `android-opencc` unless it has been
verified to support the 16KB page size alignment.

---

## Prerequisites

| Tool          | Version / Notes                                    |
|---------------|----------------------------------------------------|
| Flutter       | 3.38.0 (pinned via FVM — see `.fvmrc`)             |
| Dart          | Ships with Flutter (SDK `>=3.3.0 <4.0.0`)          |
| Java          | 17 (required for Android Gradle builds)            |
| Android SDK   | `compileSdk 36`, `minSdk 24`                       |
| CMake         | 3.22.1 (used for Android native build)             |
| Xcode         | Latest stable (for iOS builds)                     |
| CocoaPods     | Required for legacy iOS CocoaPods builds           |

Install dependencies after cloning:

```bash
flutter pub get
```

---

## Building the Project

### Android

```bash
cd example
flutter build apk --debug
```

The Android build uses CMake to compile the bundled OpenCC C++ sources into a static library
(`libOpenCC.a`), which is then linked into the `ChineseConverter` shared library (`libChineseConverter.so`).

### iOS

```bash
# CocoaPods (legacy / default without SPM enabled)
pod repo update
cd example
flutter build ios --debug --no-codesign

# Swift Package Manager
flutter config --enable-swift-package-manager
cd example
flutter build ios --debug --no-codesign --simulator
```

### Web

The web implementation is pure Dart and does not require a separate build step.

### Running the Example App

```bash
cd example
flutter run
```

---

## Running Tests

### Dart / Flutter unit tests

```bash
flutter test
```

Tests live in the `test/` directory. They use mock `MethodChannel` handlers and do not require a
device or emulator.

### Android unit tests

```bash
cd android
./gradlew test
```

---

## Linting and Formatting

### Dart

```bash
flutter analyze          # Static analysis using flutter_lints
dart format .            # Auto-format all Dart files
dart run import_sorter:main  # Sort imports (configured in pubspec.yaml)
```

Linting rules are defined in `analysis_options.yaml` and extend `package:flutter_lints/flutter.yaml`.

### Swift

Swift source files use `swift-format` with the configuration in `.swift-format`:

- **Indentation**: 4 spaces
- **Line length**: 100 characters

```bash
swift-format format --recursive --in-place ios/
swift-format lint --recursive ios/
```

### Kotlin

Follow standard [Kotlin coding conventions](https://kotlinlint.io). No additional linter is
configured beyond Android Studio's built-in inspections.

---

## Code Conventions

### Dart

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style.
- Use `flutter_lints` rules (enforced by `analysis_options.yaml`).
- Sort imports with `import_sorter` (`dart run import_sorter:main`).
- Avoid `print()`; use logging or error handling instead.
- All public APIs must have dartdoc comments.

### Swift

- Indentation: 4 spaces (configured in `.swift-format`).
- Maximum line length: 100 characters.
- Use `swift-format` for formatting.
- The plugin entry point extends `NSObject` and conforms to `FlutterPlugin`.

### Kotlin

- Indentation: 4 spaces.
- Follow [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html).
- Use coroutines (`kotlinx.coroutines`) for background operations.
- The plugin entry point implements `FlutterPlugin` and `MethodCallHandler`.

### C++ (Android Native)

- The C++ code in `android/src/main/cpp/` is a thin JNI bridge wrapping OpenCC.
- Follow the existing code style in `chineseconverter.cpp`.
- Do not modify files inside `android/src/main/cpp/OpenCC/` unless updating the vendored OpenCC
  version intentionally.

---

## Committing Conventions

Use clear and descriptive commit messages. Follow this style:

- **feat**: A new feature (e.g., `feat: add T2TW conversion option`)
- **fix**: A bug fix (e.g., `fix: resolve Android 16KB page size issue`)
- **build**: Build system changes, dependency updates (e.g., `build: update Kotlin to 2.1.0`)
- **ci**: CI/CD changes (e.g., `ci: add Flutter 3.38.x to build matrix`)
- **docs**: Documentation changes (e.g., `docs: update README usage example`)
- **refactor**: Code refactoring without behavior change
- **test**: Adding or updating tests
- **chore**: Other maintenance tasks

Keep each commit focused on a single concern. Reference issues or PRs where relevant.

---

## Plugin Architecture

The plugin uses the standard Flutter platform channel pattern:

1. **Dart API** (`lib/src/chinese_converter.dart`): calls `MethodChannel('flutter_open_chinese_convert')` with method name `convert` and arguments `[text, optionId, inBackground, webIgnoreMissingIdioms]`.
2. **Android** (`FlutterOpenccPlugin.kt`): receives the method call, maps the option ID to a `ConversionType`, and calls the native `ChineseConverter.convert()` (either on the main thread or a coroutine).
3. **iOS** (`FlutterOpenChineseConvertPlugin.swift`): receives the method call, maps the option ID to `ChineseConverter.Options`, and calls `ChineseConverter.convert()` (either on the calling thread or a background `DispatchQueue`).
4. **Web** (`lib/src/web/`): pure Dart/JS implementation using `opencc-js`.

The `inBackground` parameter controls whether conversion is performed on a background thread
(Android: coroutine on `IO` dispatcher; iOS: `DispatchQueue.global()`).

---

## Adding a New Conversion Option

1. Add a new `ConverterOption` subclass in `lib/src/options.dart`.
2. Add it to `_options` in `lib/src/chinese_converter.dart`.
3. Map the new option's `id` in:
   - `FlutterOpenccPlugin.kt` (`typeOf()` function)
   - `FlutterOpenChineseConvertPlugin.swift` (`convertOptions(from:)` function)
   - Web implementation
4. Update `README.md` and `CHANGELOG.md`.

---

## Updating the Vendored OpenCC (Android)

The OpenCC source lives in `android/src/main/cpp/OpenCC/`. To update it:

1. Copy the new OpenCC release source into that directory.
2. Update `CMakeLists.txt` if the set of source files changes.
3. Verify the 16KB page size linker flag (`-Wl,-z,max-page-size=16384`) is still present.
4. Build and test on a physical Android 15+ device (or an emulator with 16KB page size enabled).
