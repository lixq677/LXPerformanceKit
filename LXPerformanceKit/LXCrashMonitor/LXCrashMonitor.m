//
//  LXCrash.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/17.
//

#import "LXCrashMonitor.h"
#import "LXStackTracer.h"
#import <YYCache/YYCache.h>
#include "LXCrashEntryContext.h"
#include "LXSignalInfo.h"
#include "LXMach.h"
#include <mach-o/dyld.h>
#import <execinfo.h>
#import "LXBacktraceLogger.h"
#import "LXCrash_UserException.h"

@interface LXCrashMonitor ()

@property (nonatomic, copy) YYDiskCache *diskCache;

@property (nonatomic, strong)NSMutableSet<NSString *> *allKeys;

@property (nonatomic,copy)void(^reportBlock)(LXCrash *crashInfo);

- (void)writeCrashReport:(LXCrash *)crash;

@end

LXCrash_EntryContext g_crashContext;

static volatile sig_atomic_t g_installed = 0;

NSArray *genCrashStack(){
    if (g_crashContext.stackTraceLength>0) {
        
        char **strings = backtrace_symbols((void *)g_crashContext.stackTrace, (int)g_crashContext.stackTraceLength);
        NSMutableArray *ret = [NSMutableArray arrayWithCapacity:g_crashContext.stackTraceLength];
        
        [ret addObjectsFromArray:lx_baseAddressInfo()];
        
        for (int i = 0; i < g_crashContext.stackTraceLength; ++i)
            [ret addObject:@(strings[i])];
        
        if (strings) {
            free(strings);
        }
        
        return ret;
    }
    return nil;
}

#pragma mark - static methods
void lxcrash_onCrash(void){
    //处理当前的异常信息
    LXCrash *crashInfo = nil;
    switch (g_crashContext.crashType) {
        case LXCrashTypeNSException:
            crashInfo = [[LXCrash alloc] initWithName:g_crashContext.NSException.name reason:g_crashContext.crashReason stack:genCrashStack() symbol:g_crashContext.NSException.callStackSymbols];
            crashInfo.crashType = @"NSException";
            break;
        case LXCrashTypeSignal:{
            int sigNum = g_crashContext.signal.signalInfo->si_signo;
            int sigCode = g_crashContext.signal.signalInfo->si_code;
            const char* sigName = lxsignal_signalName(sigNum);
            const char* sigCodeName = lxsignal_signalCodeName(sigNum, sigCode);
            
            char symbol[256] = {0};
            sprintf(symbol,"App crashed due to signal: [%s, %s] at %0lx",
                            sigName, sigCodeName, g_crashContext.faultAddress);
            
            NSMutableArray *stacks = [NSMutableArray arrayWithArray:lx_baseAddressInfo()];
            NSString *mainThreadStack = [LXBacktraceLogger backtraceOfMainThread];
            if (mainThreadStack) {
                [stacks addObject:mainThreadStack];
            }
            NSString *currentThreadStack = [LXBacktraceLogger backtraceOfCurrentThread];
            if (currentThreadStack) {
                [stacks addObject:currentThreadStack];
            }

            crashInfo = [[LXCrash alloc] initWithName:sigCodeName reason:g_crashContext.crashReason stack:stacks symbol:symbol];
            crashInfo.crashType = @"SignalException";
        }
            break;
        case LXCrashTypeMachException:{
            int machExceptionType = g_crashContext.mach.type;
            kern_return_t machCode = (kern_return_t)g_crashContext.mach.code;
            const char* machExceptionName = lxmach_exceptionName(machExceptionType);
            const char* machCodeName = machCode == 0 ? NULL : lxmach_kernelReturnCodeName(machCode);
            
            char symbol[256] = {0};
            sprintf(symbol,"App crashed due to mach exception: [%s: %s] at %0lx",
                            machExceptionName, machCodeName, g_crashContext.faultAddress);
            
            NSMutableArray *stacks = [NSMutableArray arrayWithArray:lx_baseAddressInfo()];
            NSString *mainThreadStack = [LXBacktraceLogger backtraceOfMainThread];
            if (mainThreadStack) {
                [stacks addObject:mainThreadStack];
            }
            NSString *currentThreadStack = [LXBacktraceLogger backtraceOfCurrentThread];
            if (currentThreadStack) {
                [stacks addObject:currentThreadStack];
            }
            
            crashInfo = [[LXCrash alloc] initWithName:machExceptionName reason:g_crashContext.crashReason stack:stacks symbol:symbol];
            
            crashInfo.crashType = @"MachException";
        }
            break;
        case LXCrashTypeCPPException:{
            crashInfo = [[LXCrash alloc] initWithName:g_crashContext.CPPException.name reason:g_crashContext.crashReason stack:genCrashStack() symbol:NULL];
            
            crashInfo.crashType = @"CPPException";
        }
            break;
        case LXCrashTypeMainThreadDeadLock:{
            crashInfo = [[LXCrash alloc] initWithName:@"MainThreadDeadLock" reason:@"Main thread deadlocked"];
            
            crashInfo.stack = [LXBacktraceLogger backtraceOfMainThread];
            
            crashInfo.crashType = @"DeadLockException";
        }
            break;
        case LXCrashTypeUserDefined:{
            crashInfo = [[LXCrash alloc] initWithName:g_crashContext.userException.name reason:g_crashContext.crashReason stack:genCrashStack() symbol:g_crashContext.userException.customStackTrace];
            
            crashInfo.crashType = @"UserDefinedException";
        }
            break;
            
        default:
            break;
    }
    
    [[LXCrashMonitor defaultMonitor] writeCrashReport:crashInfo];
}


@implementation LXCrashMonitor

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}


#pragma mark - public methods
- (void)startMonitorWithTypes:(LXCrashType)types reportBlock:(void(^)(LXCrash *crashInfo))block{
    self.reportBlock = block;
    LXCrashType type = LXCrashTypeNone;
    if (!g_installed) {
        g_installed = 1;
        type = lxcrash_installWithContext(&g_crashContext, types, lxcrash_onCrash);
    }
    
//    if (type == LXCrashTypeNone) {
//        return NO;
//    }
//    return YES;
}

- (void)stopMonitor{
    if (g_installed) {
        lxcrash_uninstall(LXCrashTypeAll);
        g_installed = 0;
    }
}

- (void)deleteReport{
    [self.diskCache removeAllObjects];
}

- (NSArray<LXCrash *> *)crashReports{
    NSMutableArray *reports = [NSMutableArray array];
    [self.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        id item = [self.diskCache objectForKey:obj];
        if ([item isKindOfClass:[LXCrash class]]) {
            [reports addObject:item];
        }
    }];
    return reports;
}

- (void)writeCrashReport:(LXCrash *)crash{
    if (crash.uuid) {
        [self.allKeys addObject:crash.uuid];
        [self.diskCache setObject:crash forKey:crash.uuid];
        if (self.reportBlock) {
            if ([NSThread isMainThread]) {
                self.reportBlock(crash);
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.reportBlock(crash);
                });
            }
        }
    }
}


- (void)reportUserException:(NSString *)name
                     reason:(NSString *)reason
                    details:(NSString *)details
           terminateProgram:(BOOL)terminateProgram{
    lxcrash_reportUserException([name UTF8String], [reason UTF8String], NULL, [details UTF8String], [details length], [@(terminateProgram) boolValue]);
}


#pragma mark getters and setters

- (YYDiskCache *)diskCache{
    if (!_diskCache) {
        NSString *cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = [cacheFolder stringByAppendingPathComponent:@"lx.cache.performance.crash"];
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
