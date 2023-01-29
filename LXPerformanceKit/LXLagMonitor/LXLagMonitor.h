//
//  LXLagMonitor.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import <Foundation/Foundation.h>
#import "LXLag.h"

NS_ASSUME_NONNULL_BEGIN

@interface LXLagMonitor : NSObject

+ (instancetype)defaultMonitor;

//开始监控
- (void)startMonitorWithReportBlock:(void(^)(LXLag *lagInfo))block;

//停止监控
- (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
