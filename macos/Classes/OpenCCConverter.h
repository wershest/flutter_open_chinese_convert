#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCCConverter : NSObject
+ (nullable NSString *)convertText:(NSString *)text
                            option:(NSString *)option
                          dataPath:(NSString *)dataPath
                             error:(NSError * _Nullable * _Nullable)error;
+ (nullable NSNumber *)initSessionWithOption:(NSString *)option
                                     dataPath:(NSString *)dataPath
                                        error:(NSError * _Nullable * _Nullable)error;
+ (nullable NSString *)convertWithSessionId:(NSNumber *)sessionId
                                       text:(NSString *)text
                                      error:(NSError * _Nullable * _Nullable)error;
+ (void)disposeSessionId:(NSNumber *)sessionId;
@end

NS_ASSUME_NONNULL_END
