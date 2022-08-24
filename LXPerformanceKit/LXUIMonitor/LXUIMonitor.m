//
//  LXUIMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import "LXUIMonitor.h"
#import "LXUICPUMonitor.h"
#import "LXUIGPUMonitor.h"
#import "LXUIMEMMonitor.h"
#import "LXUIFPSMonitor.h"

@implementation LXUIMonitor

+ (void)startMonitor:(LXUIMonitorType)monitorType{
    switch (monitorType) {
        case LXUIMonitorTypeCPU:
            [[LXUICPUMonitor defaultMonitor] startMonitor];
            break;
        case LXUIMonitorTypeGPU:
            [[LXUIGPUMonitor defaultMonitor] startMonitor];
            break;
        case LXUIMonitorTypeMEM:
            [[LXUIMEMMonitor defaultMonitor] startMonitor];
            break;
        case LXUIMonitorTypeFPS:
            [[LXUIFPSMonitor defaultMonitor] startMonitor];
            break;
        default:
            break;
    }
}

+ (void)stopMonitor:(LXUIMonitorType)monitorType{
    switch (monitorType) {
        case LXUIMonitorTypeCPU:
            [[LXUICPUMonitor defaultMonitor] stopMonitor];
            break;
        case LXUIMonitorTypeGPU:
            [[LXUIGPUMonitor defaultMonitor] stopMonitor];
            break;
        case LXUIMonitorTypeMEM:
            [[LXUIMEMMonitor defaultMonitor] stopMonitor];
            break;
        case LXUIMonitorTypeFPS:
            [[LXUIFPSMonitor defaultMonitor] stopMonitor];
            break;
        default:
            break;
    }
}

+ (BOOL)isMonitor:(LXUIMonitorType)monitorType{
    BOOL monitor = NO;
    switch (monitorType) {
        case LXUIMonitorTypeCPU:
            monitor = [[LXUICPUMonitor defaultMonitor] isMonitor];
            break;
        case LXUIMonitorTypeGPU:
            monitor = [[LXUIGPUMonitor defaultMonitor] isMonitor];
            break;
        case LXUIMonitorTypeMEM:
            monitor = [[LXUIMEMMonitor defaultMonitor] isMonitor];
            break;
        case LXUIMonitorTypeFPS:
            monitor = [[LXUIFPSMonitor defaultMonitor] isMonitor];
            break;
        default:
            break;
    }
    return monitor;
}


@end
