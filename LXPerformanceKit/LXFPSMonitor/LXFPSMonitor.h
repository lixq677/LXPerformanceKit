//
//  LXFPSMonitor.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXFPSMonitor : NSObject

+ (instancetype)defaultMonitor;

//开始监控
- (void)startMonitorWithBlock:(void(^)(int fps))block;

//停止监控
- (void)stopMonitor;

@property (nonatomic,assign,getter=isMonitor,readonly)BOOL monitor;

@end

NS_ASSUME_NONNULL_END
