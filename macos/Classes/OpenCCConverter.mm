#import "OpenCCConverter.h"

#include "Config.hpp"
#include "Converter.hpp"

namespace {
std::string BuildConfigJson(NSString* option) {
  if ([option isEqualToString:@"s2t"]) {
    return R"({"name":"s2t","segmentation":{"type":"mmseg","dict":{"type":"text","file":"STPhrases.txt"}},"conversion_chain":[{"dict":{"type":"group","dicts":[{"type":"text","file":"STPhrases.txt"},{"type":"text","file":"STCharacters.txt"}]}}]})";
  }
  if ([option isEqualToString:@"t2s"]) {
    return R"({"name":"t2s","segmentation":{"type":"mmseg","dict":{"type":"text","file":"TSPhrases.txt"}},"conversion_chain":[{"dict":{"type":"group","dicts":[{"type":"text","file":"TSPhrases.txt"},{"type":"text","file":"TSCharacters.txt"}]}}]})";
  }
  if ([option isEqualToString:@"s2hk"]) {
    return R"({"name":"s2hk","segmentation":{"type":"mmseg","dict":{"type":"text","file":"STPhrases.txt"}},"conversion_chain":[{"dict":{"type":"group","dicts":[{"type":"text","file":"STPhrases.txt"},{"type":"text","file":"STCharacters.txt"}]}},{"dict":{"type":"text","file":"HKVariants.txt"}}]})";
  }
  if ([option isEqualToString:@"hk2s"]) {
    return R"({"name":"hk2s","segmentation":{"type":"mmseg","dict":{"type":"text","file":"TSPhrases.txt"}},"conversion_chain":[{"dict":{"type":"text","file":"HKVariantsRevPhrases.txt"}},{"dict":{"type":"group","dicts":[{"type":"text","file":"TSPhrases.txt"},{"type":"text","file":"TSCharacters.txt"}]}}]})";
  }
  if ([option isEqualToString:@"s2tw"]) {
    return R"({"name":"s2tw","segmentation":{"type":"mmseg","dict":{"type":"text","file":"STPhrases.txt"}},"conversion_chain":[{"dict":{"type":"group","dicts":[{"type":"text","file":"STPhrases.txt"},{"type":"text","file":"STCharacters.txt"}]}},{"dict":{"type":"text","file":"TWVariants.txt"}}]})";
  }
  if ([option isEqualToString:@"tw2s"]) {
    return R"({"name":"tw2s","segmentation":{"type":"mmseg","dict":{"type":"text","file":"TSPhrases.txt"}},"conversion_chain":[{"dict":{"type":"text","file":"TWVariantsRevPhrases.txt"}},{"dict":{"type":"group","dicts":[{"type":"text","file":"TSPhrases.txt"},{"type":"text","file":"TSCharacters.txt"}]}}]})";
  }
  if ([option isEqualToString:@"s2twp"]) {
    return R"({"name":"s2twp","segmentation":{"type":"mmseg","dict":{"type":"text","file":"STPhrases.txt"}},"conversion_chain":[{"dict":{"type":"group","dicts":[{"type":"text","file":"STPhrases.txt"},{"type":"text","file":"STCharacters.txt"}]}},{"dict":{"type":"group","dicts":[{"type":"text","file":"TWPhrasesIT.txt"},{"type":"text","file":"TWPhrasesName.txt"},{"type":"text","file":"TWPhrasesOther.txt"}]}},{"dict":{"type":"text","file":"TWVariants.txt"}}]})";
  }
  if ([option isEqualToString:@"tw2sp"]) {
    return R"({"name":"tw2sp","segmentation":{"type":"mmseg","dict":{"type":"text","file":"TSPhrases.txt"}},"conversion_chain":[{"dict":{"type":"text","file":"TWVariantsRevPhrases.txt"}},{"dict":{"type":"group","dicts":[{"type":"text","file":"TSPhrases.txt"},{"type":"text","file":"TSCharacters.txt"}]}}]})";
  }
  return "";
}
}  // namespace

@implementation OpenCCConverter

+ (nullable NSString *)convertText:(NSString *)text
                            option:(NSString *)option
                          dataPath:(NSString *)dataPath
                             error:(NSError * _Nullable __autoreleasing *)error {
  const std::string configJson = BuildConfigJson(option);
  if (configJson.empty()) {
    if (error) {
      *error = [NSError errorWithDomain:@"flutter_open_chinese_convert"
                                   code:1001
                               userInfo:@{NSLocalizedDescriptionKey : @"Unsupported conversion option."}];
    }
    return nil;
  }

  try {
    std::string dictionaryPath = std::string([dataPath UTF8String]);
    if (!dictionaryPath.empty() && dictionaryPath.back() != '/') {
      dictionaryPath += "/";
    }

    opencc::Config config;
    opencc::ConverterPtr converter = config.NewFromString(configJson, dictionaryPath);
    std::string converted = converter->Convert(std::string([text UTF8String]));
    return [NSString stringWithUTF8String:converted.c_str()];
  } catch (const std::exception& ex) {
    if (error) {
      *error = [NSError errorWithDomain:@"flutter_open_chinese_convert"
                                   code:1002
                               userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithUTF8String:ex.what()]}];
    }
    return nil;
  }
}

@end
