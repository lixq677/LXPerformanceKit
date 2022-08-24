//
//  LXUICPUMonitor.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXUICPUMonitor : NSObject

+ (instancetype)defaultMonitor;

- (void)startMonitor;

- (void)stopMonitor;

@property (nonatomic,assign,getter=isMonitor,readonly)BOOL monitor;

@end

NS_ASSUME_NONNULL_END
