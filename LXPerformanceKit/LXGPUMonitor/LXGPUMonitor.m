//
//  LXGPUMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import "LXGPUMonitor.h"

@implementation LXGPUMonitor{
    CFRunLoopTimerRef _monitorTimer;
}

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)startMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(LXGPUUtilization *GPUUtilization))handler{
    if (_monitor) {
        return;
    }
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(self->_monitorTimer);
        self->_monitorTimer = NULL;
    }
    
    if(!handler) {
        return;
    }
    _monitor = YES;
    dispatch_queue_t queue = dispatch_queue_create("lx_monitor_queue", NULL);
    dispatch_async(queue, ^{
        self->_monitorTimer = CFRunLoopTimerCreateWithHandler(CFAllocatorGetDefault(), CFAbsoluteTimeGetCurrent(),timeInterval, 0, 0,^(CFRunLoopTimerRef timer) {
            handler([LXGPUUtilization current]);
        });
        CFRunLoopTimerSetTolerance(self->_monitorTimer, 0.1); //设置容忍时间
        CFRunLoopAddTimer(CFRunLoopGetMain(), self->_monitorTimer, kCFRunLoopCommonModes);
    });
   
}

- (void)stopMonitor{
    _monitor = NO;
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(_monitorTimer);
        _monitorTimer = NULL;
    }
}



@end
