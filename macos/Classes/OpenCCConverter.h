#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCCConverter : NSObject
+ (nullable NSString *)convertText:(NSString *)text
                            option:(NSString *)option
                          dataPath:(NSString *)dataPath
                             error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
