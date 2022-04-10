//
//  LXCPUMonitor.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import "LXCPUMonitor.h"
#import "LXCPUInfo.h"

@interface LXCPUMonitor (){
    CFRunLoopTimerRef _monitorTimer;
}

@property (nonatomic, strong) LXCPUInfo *cpuInfo;

@end

@implementation LXCPUMonitor

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

#pragma mark - public methods
- (void)startMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void (^)(float))handler{
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(self->_monitorTimer);
        self->_monitorTimer = NULL;
    }
    
    if(!handler) {
        return;
    }
    //开启新的计时器
    timeInterval = timeInterval > 0.2?timeInterval:1.0f;
    
    _monitorTimer = CFRunLoopTimerCreateWithHandler(CFAllocatorGetDefault(), CFAbsoluteTimeGetCurrent(),
                                                    timeInterval, 0, 0,
                                                    ^(CFRunLoopTimerRef timer) {
                                                        if(handler)
                                                            handler([self.cpuInfo usage]);
                                                    });
    CFRunLoopTimerSetTolerance(_monitorTimer, 0.1); //设置容忍时间
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), _monitorTimer, kCFRunLoopDefaultMode);
}

- (void)stopMonitor{
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(_monitorTimer);
        _monitorTimer = NULL;
    }
}

#pragma mark - getters and setters
- (LXCPUInfo *)cpuInfo{
    if (!_cpuInfo) {
        _cpuInfo = [[LXCPUInfo alloc] init];
    }
    return _cpuInfo;
}


@end
