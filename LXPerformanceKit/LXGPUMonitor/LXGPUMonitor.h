//
//  LXGPUMonitor.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import <Foundation/Foundation.h>
#import "LXGPUUtilization.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXGPUMonitor : NSObject

+ (instancetype)defaultMonitor;

- (void)startMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(LXGPUUtilization *GPUUtilization))handler;

- (void)stopMonitor;

@property (nonatomic,assign,getter=isMonitor,readonly)BOOL monitor;

@end

NS_ASSUME_NONNULL_END
