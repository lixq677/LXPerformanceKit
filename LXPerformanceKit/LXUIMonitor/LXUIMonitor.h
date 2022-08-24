//
//  LXUIMonitor.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (int,LXUIMonitorType){
    LXUIMonitorTypeCPU,
    LXUIMonitorTypeGPU,
    LXUIMonitorTypeFPS,
    LXUIMonitorTypeMEM
};


@interface LXUIMonitor : NSObject

+ (void)startMonitor:(LXUIMonitorType)monitorType;

+ (void)stopMonitor:(LXUIMonitorType)monitorType;

+ (BOOL)isMonitor:(LXUIMonitorType)monitorType;

@end

NS_ASSUME_NONNULL_END
