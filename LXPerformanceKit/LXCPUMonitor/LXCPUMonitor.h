//
//  LXCPUMonitor.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXCPUMonitor : NSObject

+ (instancetype)defaultMonitor;

/**
 监听CPU使用状况

 @param timeInterval 间隔监听时间
 @param handler 回调CPU使用percent,以及每个线程占用CPU使用率
 */
- (void)startMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(float cpuUsage,NSDictionary<NSNumber *,NSNumber *> *threadUsageDictionary))handler;

- (void)stopMonitor;

@property (nonatomic,assign,getter=isMonitor,readonly)BOOL monitor;

/*监听线程号*/
@property (nonatomic,assign,readonly)thread_t thread;

- (void)addWhiteList:(NSThread *)thread;

@end

NS_ASSUME_NONNULL_END
