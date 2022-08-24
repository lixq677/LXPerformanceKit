//
//  LXCPUMonitor.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import "LXCPUMonitor.h"
#import "LXCPUInfo.h"
#import <LXPerformanceKit/LXBacktrace.h>

@interface LXCPUMonitor (){
    CFRunLoopTimerRef _monitorTimer;
}

@property (nonatomic, strong) LXCPUInfo *cpuInfo;

@property (nonatomic,strong)NSMutableArray<NSNumber *> *whiteList;

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
- (void)startMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(float cpuUsage,NSDictionary<NSNumber *,NSNumber *> *threadUsage))handler{
    if(!handler || _monitor) {
        return;
    }
    _monitor = YES;
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(self->_monitorTimer);
        self->_monitorTimer = NULL;
    }
    //开启新的计时器
    timeInterval = MIN(timeInterval, 0.2);
    dispatch_queue_t queue = dispatch_queue_create("lx_monitor_queue", NULL);
    dispatch_async(queue, ^{
        self->_thread = [LXBacktrace machThreadFromNSThread:[NSThread currentThread]];
        self->_monitorTimer = CFRunLoopTimerCreateWithHandler(CFAllocatorGetDefault(), CFAbsoluteTimeGetCurrent(),timeInterval, 0, 0,^(CFRunLoopTimerRef timer) {
            if(handler){
                __block float usage = 0;
                NSDictionary<NSNumber *,NSNumber *> *cpuUsagesDictionary = [LXCPUInfo cpuThreadUsage];
                NSMutableDictionary<NSNumber *,NSNumber *> *cpuUsages = [NSMutableDictionary dictionary];
                [cpuUsagesDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([self.whiteList containsObject:key]) return;
                    if ([key intValue] == self->_thread) return;
                    usage += obj.floatValue;
                    cpuUsages[key] = obj;
                }];
                handler(usage,cpuUsages);
            }
        });
        CFRunLoopTimerSetTolerance(self->_monitorTimer, 0.1); //设置容忍时间
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), self->_monitorTimer, kCFRunLoopCommonModes);
        CFRunLoopRun();
    });
}

- (void)stopMonitor{
    _monitor = NO;
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(_monitorTimer);
        _monitorTimer = NULL;
    }
}

- (void)addWhiteList:(NSThread *)thread{
    thread_t thr = [LXBacktrace machThreadFromNSThread:thread];
    [self.whiteList addObject:@(thr)];
}


- (NSMutableArray<NSNumber *> *)whiteList{
    if(!_whiteList){
        _whiteList = [NSMutableArray array];
    }
    return _whiteList;
}

#pragma mark - getters and setters
- (LXCPUInfo *)cpuInfo{
    if (!_cpuInfo) {
        _cpuInfo = [[LXCPUInfo alloc] init];
    }
    return _cpuInfo;
}


@end
