#import "OpenCCConverter.h"

#include "Config.hpp"
#include "Converter.hpp"
#include <atomic>
#include <mutex>
#include <unordered_map>

namespace {
std::mutex gSessionMutex;
std::unordered_map<int64_t, opencc::ConverterPtr> gSessions;
std::atomic<int64_t> gNextSessionId{1};

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

opencc::ConverterPtr BuildConverter(NSString* option, NSString* dataPath) {
  const std::string configJson = BuildConfigJson(option);
  if (configJson.empty()) {
    throw std::runtime_error("Unsupported conversion option.");
  }

  std::string dictionaryPath = std::string([dataPath UTF8String]);
  if (!dictionaryPath.empty() && dictionaryPath.back() != '/') {
    dictionaryPath += "/";
  }

  opencc::Config config;
  return config.NewFromString(configJson, dictionaryPath);
}
}  // namespace

@implementation OpenCCConverter

+ (nullable NSString *)convertText:(NSString *)text
                            option:(NSString *)option
                          dataPath:(NSString *)dataPath
                             error:(NSError * _Nullable __autoreleasing *)error {
  try {
    opencc::ConverterPtr converter = BuildConverter(option, dataPath);
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

+ (nullable NSNumber *)initSessionWithOption:(NSString *)option
                                     dataPath:(NSString *)dataPath
                                        error:(NSError * _Nullable __autoreleasing *)error {
  try {
    opencc::ConverterPtr converter = BuildConverter(option, dataPath);
    const int64_t sessionId = gNextSessionId.fetch_add(1);
    {
      std::lock_guard<std::mutex> lock(gSessionMutex);
      gSessions[sessionId] = std::move(converter);
    }
    return [NSNumber numberWithLongLong:sessionId];
  } catch (const std::exception& ex) {
    if (error) {
      *error = [NSError errorWithDomain:@"flutter_open_chinese_convert"
                                   code:1003
                               userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithUTF8String:ex.what()]}];
    }
    return nil;
  }
}

+ (nullable NSString *)convertWithSessionId:(NSNumber *)sessionId
                                       text:(NSString *)text
                                      error:(NSError * _Nullable __autoreleasing *)error {
  opencc::ConverterPtr converter;
  {
    std::lock_guard<std::mutex> lock(gSessionMutex);
    const auto it = gSessions.find([sessionId longLongValue]);
    if (it == gSessions.end()) {
      if (error) {
        *error = [NSError errorWithDomain:@"flutter_open_chinese_convert"
                                     code:1004
                                 userInfo:@{NSLocalizedDescriptionKey : @"Converter session not found."}];
      }
      return nil;
    }
    converter = it->second;
  }

  try {
    std::string converted = converter->Convert(std::string([text UTF8String]));
    return [NSString stringWithUTF8String:converted.c_str()];
  } catch (const std::exception& ex) {
    if (error) {
      *error = [NSError errorWithDomain:@"flutter_open_chinese_convert"
                                   code:1005
                               userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithUTF8String:ex.what()]}];
    }
    return nil;
  }
}

+ (void)disposeSessionId:(NSNumber *)sessionId {
  std::lock_guard<std::mutex> lock(gSessionMutex);
  gSessions.erase([sessionId longLongValue]);
}

@end
