//
//  LXCrash.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/17.
//

#import <Foundation/Foundation.h>
#import "LXCrash.h"
#import "LXCrashType.h"

NS_ASSUME_NONNULL_BEGIN


@interface LXCrashMonitor : NSObject

@property (nonatomic, assign) LXCrashType handlingCrashTypes;

+ (LXCrashMonitor *)defaultMonitor;


- (void)startMonitorWithTypes:(LXCrashType)types reportBlock:(nullable void(^)(LXCrash *crashInfo))block;

- (void)stopMonitor;

- (void)deleteReport;

- (NSArray<LXCrash *> *)crashReports;

/**
 主动写入崩溃日志

 @param name 错误名称
 @param reason 错误原因
 @param details 其他详细内容
 @param terminateProgram 是否结束APP
 */
- (void)reportUserException:(NSString *)name
                     reason:(NSString *)reason
                    details:(NSString *)details
           terminateProgram:(BOOL)terminateProgram;


@end



NS_ASSUME_NONNULL_END
