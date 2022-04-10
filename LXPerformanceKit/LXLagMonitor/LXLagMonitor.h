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


@property (nonatomic, readonly) NSArray<LXLag *> *lagReports;

+ (instancetype)defaultMonitor;

//开始监控
- (void)startMonitorWithReportBlock:(void(^)(LXLag *lagInfo))block;

//停止监控
- (void)stopMonitor;

- (void)deleteReports;


@end

NS_ASSUME_NONNULL_END
