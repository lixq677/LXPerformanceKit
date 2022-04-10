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
 @param handler 回调CPU使用percent
 */
- (void)startMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(float cpuUsage))handler;

- (void)stopMonitor;


@end

NS_ASSUME_NONNULL_END
