Pod::Spec.new do |s|
  s.name             = 'flutter_open_chinese_convert'
  s.version          = '0.0.1'
  s.summary          = 'OpenCC bridge for Flutter.'
  s.description      = <<-DESC
flutter_open_chinese_convert bridges OpenCC (Open Chinese Convert) to your
Flutter projects.
                       DESC
  s.homepage         = 'https://github.com/zonble/flutter_open_chinese_convert'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Weizhong Yang a.k.a zonble' => 'zonble@gmail.com' }
  s.source           = { :path => '.' }
  s.prepare_command  = <<-CMD
    rm -rf Classes/OpenCCVendor
    mkdir -p Classes/OpenCCVendor
    cp -R ../android/src/main/cpp/OpenCC/src Classes/OpenCCVendor/src
    cp -R ../android/src/main/cpp/OpenCC/deps/marisa-0.2.6 Classes/OpenCCVendor/marisa-0.2.6
    cp -R ../android/src/main/cpp/OpenCC/deps/rapidjson-1.1.0 Classes/OpenCCVendor/rapidjson-1.1.0
    cp -R ../android/src/main/cpp/OpenCC/data/dictionary Classes/OpenCCVendor/dictionary
  CMD
  s.source_files     = [
    'Classes/FlutterOpenChineseConvertPlugin.swift',
    'Classes/OpenCCConverter.h',
    'Classes/OpenCCConverter.mm',
    'Classes/OpenCCVendor/src/BinaryDict.cpp',
    'Classes/OpenCCVendor/src/Config.cpp',
    'Classes/OpenCCVendor/src/Conversion.cpp',
    'Classes/OpenCCVendor/src/ConversionChain.cpp',
    'Classes/OpenCCVendor/src/Converter.cpp',
    'Classes/OpenCCVendor/src/Dict.cpp',
    'Classes/OpenCCVendor/src/DictEntry.cpp',
    'Classes/OpenCCVendor/src/DictGroup.cpp',
    'Classes/OpenCCVendor/src/Lexicon.cpp',
    'Classes/OpenCCVendor/src/MarisaDict.cpp',
    'Classes/OpenCCVendor/src/MaxMatchSegmentation.cpp',
    'Classes/OpenCCVendor/src/PhraseExtract.cpp',
    'Classes/OpenCCVendor/src/SerializedValues.cpp',
    'Classes/OpenCCVendor/src/Segmentation.cpp',
    'Classes/OpenCCVendor/src/TextDict.cpp',
    'Classes/OpenCCVendor/src/UTF8StringSlice.cpp',
    'Classes/OpenCCVendor/src/UTF8Util.cpp',
    'Classes/OpenCCVendor/marisa-0.2.6/lib/marisa/*.cc',
    'Classes/OpenCCVendor/marisa-0.2.6/lib/marisa/grimoire/io/*.cc',
    'Classes/OpenCCVendor/marisa-0.2.6/lib/marisa/grimoire/trie/*.cc',
    'Classes/OpenCCVendor/marisa-0.2.6/lib/marisa/grimoire/vector/*.cc',
  ]
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '10.14'
  s.swift_version = '5.0'
  s.resource_bundles = {
    'flutter_open_chinese_convert_resources' => [
      'Classes/OpenCCVendor/dictionary/*.txt',
    ]
  }
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) OPENCC_ENABLE_DARTS=1',
    'HEADER_SEARCH_PATHS' => [
      '"${PODS_TARGET_SRCROOT}/Classes/OpenCCVendor/src"',
      '"${PODS_TARGET_SRCROOT}/Classes/OpenCCVendor/marisa-0.2.6/include"',
      '"${PODS_TARGET_SRCROOT}/Classes/OpenCCVendor/marisa-0.2.6/lib"',
      '"${PODS_TARGET_SRCROOT}/Classes/OpenCCVendor/rapidjson-1.1.0"',
    ].join(' ')
  }
end
