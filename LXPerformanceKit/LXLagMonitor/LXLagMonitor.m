//
//  LXLagMonitor.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import "LXLagMonitor.h"
#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>
#import <execinfo.h>
#import "LXBacktraceLogger.h"
#import <YYCache/YYCache.h>
#import <libextobjc/extobjc.h>

@interface LXLagMonitor (){
    int _timeoutCount;
    CFRunLoopObserverRef _runLoopObserver;
    
    @public
    dispatch_semaphore_t _dispatchSemaphore;
    CFRunLoopActivity _runLoopActivity;
}

@property (nonatomic, copy)YYDiskCache *diskCache;

@property (nonatomic, strong)NSMutableSet<NSString *> *allKeys;

@property (nonatomic,copy)void(^reportBlock)(LXLag *lagInfo);

@end

@implementation LXLagMonitor

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}


#pragma mark - public methods

- (void)startMonitorWithReportBlock:(void(^)(LXLag *lagInfo))block {
    if (_runLoopObserver) {
        return;
    }
    self.reportBlock = block;
    _dispatchSemaphore = dispatch_semaphore_create(0);//Dispatch Semaphore 保证同步
    //创建一个观察者
    CFRunLoopObserverContext context = {
        0,
        (__bridge void*)self,
        NULL,
        NULL
    };
    _runLoopObserver = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &_runLoopObserverCallBack, &context);
    //将观察这添加到主线的runLoop的common模式下
    CFRunLoopAddObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopCommonModes);
    
    //创建子线程监控
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       //子线程中开启一个持续的RunLoop来进行监控
        LXLag *lagInfo = nil;
        while (YES) {
            long semaphoreWait = dispatch_semaphore_wait(self->_dispatchSemaphore, dispatch_time(DISPATCH_TIME_NOW, 60*NSEC_PER_MSEC));
            if (semaphoreWait != 0) {
                if (!self->_runLoopObserver) {
                    self->_timeoutCount = 0;
                    self->_dispatchSemaphore = 0;
                    self->_runLoopActivity = 0;
                    return ;
                }
                //两个RunLoop状态，BeforeSources和AfterWaiting这两个状态区间时间检查是否卡顿
                if (self->_runLoopActivity == kCFRunLoopBeforeSources || self->_runLoopActivity == kCFRunLoopAfterWaiting) {
                    //出现五次结果
                    if (++self->_timeoutCount >= 5) {//超过5*60=300毫秒就认为是卡顿
                        if (lagInfo == nil) {
                            lagInfo = [[LXLag alloc] init];
                            NSMutableArray *stacks = [NSMutableArray arrayWithArray:lx_baseAddressInfo()];
                            NSString *mainThreadStack = [LXBacktraceLogger backtraceOfMainThread];
                            if (mainThreadStack) {
                                [stacks addObject:mainThreadStack];
                            }
                            NSString *currentThreadStack = [LXBacktraceLogger backtraceOfCurrentThread];
                            if (currentThreadStack) {
                                [stacks addObject:currentThreadStack];
                            }
                            
                            if ([stacks count]>0) {
                                lagInfo.stack = [stacks componentsJoinedByString:@"\n"];
                            }
                        }
                        NSLog(@"something lag");
                    }
                    continue;
                }//end activity
            }// end semaphore wait
            
               
            if(lagInfo){
                [self generateLagReportWithLag:lagInfo];
            }
            lagInfo = nil;
            self->_timeoutCount = 0;
        }// end while
    });
}

- (void)stopMonitor{
    if (!_runLoopObserver) {
        return;
    }
    CFRunLoopRemoveObserver(CFRunLoopGetMain(), _runLoopObserver, kCFRunLoopCommonModes);
    CFRelease(_runLoopObserver);
    _runLoopObserver = NULL;
}

static void _runLoopObserverCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    LXLagMonitor *lagMonitor = (__bridge LXLagMonitor *)info;
    lagMonitor->_runLoopActivity = activity;
    
    dispatch_semaphore_t semaphore = lagMonitor->_dispatchSemaphore;
    dispatch_semaphore_signal(semaphore);
}

- (void)deleteReports{
    [self.diskCache removeAllObjects];
}

- (NSArray<LXLag *> *)lagReports{
    NSMutableArray *reports = [NSMutableArray array];
    [self.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        id item = [self.diskCache objectForKey:obj];
        if ([item isKindOfClass:[LXLag class]]) {
            [reports addObject:item];
        }
    }];
    return reports;
}

#pragma mark - private methods

- (void)generateLagReportWithLag:(LXLag *)lagInfo{
    LXLagDegree lagDegree = LXLagDegreeSlight;
    if (self->_timeoutCount >= 30) {
        lagDegree = LXLagDegreeSerious;
    }else if (self->_timeoutCount >= 15){
        lagDegree = LXLagDegreeMedium;
    }else{
        lagDegree = LXLagDegreeSlight;
    }
    lagInfo.lagDegree = lagDegree;
    @weakify(self);
    [self.diskCache setObject:lagInfo forKey:lagInfo.uuid withBlock:^(){
        @strongify(self);
        if (self.reportBlock) {
            if ([NSThread isMainThread]) {
                self.reportBlock(lagInfo);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.reportBlock(lagInfo);
                });
            }
        }
    }];

}


- (YYDiskCache *)diskCache{
    if (!_diskCache) {
        NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [cacheFolder stringByAppendingPathComponent:@"lx.cache.performance.lag"];
        _diskCache = [[YYDiskCache alloc] initWithPath:path];
    }
    return _diskCache;
}

- (NSMutableSet<NSString *> *)allKeys{
    if (!_allKeys) {
        _allKeys = [NSMutableSet set];
    }
    return _allKeys;
}


@end
