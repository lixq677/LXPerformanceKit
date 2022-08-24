//
//  LXMEMMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import "LXMEMMonitor.h"
#import <malloc/malloc.h>
#import <dlfcn.h>
#import <execinfo.h>
#import <LXPerformanceKit/LXBacktrace.h>

typedef NS_OPTIONS(int, LXMallocLogType) {
    LXMallocLogTypeFree             =    0,
    LXMallocLogTypeAllocate         =   1 << 1,
    LXMallocLogTypeDeallocte        =   1 << 2,
    LXMallocLogTypeHasZone          =   1 << 3,
    LXMallocLogTypeCleared          =   1 << 6
};

typedef NS_ENUM(int,LXMallocType) {
    LXMallocTypeMalloc  =  LXMallocLogTypeAllocate | LXMallocLogTypeHasZone,
    LXMallocTypeCalloc  =  LXMallocLogTypeAllocate | LXMallocLogTypeCleared | LXMallocLogTypeHasZone,
    LXMallocTypeRealloc =   LXMallocLogTypeAllocate | LXMallocLogTypeDeallocte | LXMallocLogTypeHasZone,
    LXMallocTypeFree    =   LXMallocLogTypeDeallocte | LXMallocLogTypeHasZone,
};

/**
 * params:参数解释：
 * type : LXMallocType
 * arg1:default_zone 结构体指针，我们不关心,详情看源码苹果源码：libmalloc
 * arg2:
 *  LXMallocTypeMalloc和LXMallocTypeCalloc类型是下新分配内存空间的大小，
 *  LXMallocTypeFree下是释放内存空间的首地址
 *  LXMallocTypeRealloc 旧空间要释放内存空间的首地址
 * arg3:
 *  LXMallocTypeMalloc和LXMallocTypeCalloc和LXMallocTypeFree下为0，无需关心
 *  LXMallocTypeRealloc 新空间重新分配内存空间的大小
 * result；
 *  分配内存或重新分配内存空间的首地址
 * num_hot_frames_to_skip:0
 *
 */
typedef void (malloc_logger_t)(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t num_hot_frames_to_skip);

extern malloc_logger_t* malloc_logger;

static const size_t kThreshholdInBytes = 10 * 1024;

static  size_t gThreshholdInBytes_ = 0;

static void lx_dev_stack_logger(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t backtrace_to_skip);

@interface LXMEMMonitor ()

@property (nonatomic,copy)void(^singleMallocBlock)(NSString * _Nullable stackLog,NSString * _Nonnull stack, size_t bytes);

@end

@implementation LXMEMMonitor{
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

- (void)startMemorySizeMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(LXMemoryInfo *GPUUtilization))handler{
    if (self.isMemorySizeMonitor) {
        return;
    }
    _memorySizeMonitor = YES;
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(self->_monitorTimer);
        self->_monitorTimer = NULL;
    }
    
    if(!handler) {
        return;
    }
    dispatch_queue_t queue = dispatch_queue_create("lx_monitor_queue", NULL);
    dispatch_async(queue, ^{
        self->_monitorTimer = CFRunLoopTimerCreateWithHandler(CFAllocatorGetDefault(), CFAbsoluteTimeGetCurrent(),timeInterval, 0, 0,^(CFRunLoopTimerRef timer) {
            handler([LXMemoryInfo new]);
        });
        CFRunLoopTimerSetTolerance(self->_monitorTimer, 0.1); //设置容忍时间
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), self->_monitorTimer, kCFRunLoopCommonModes);
        CFRunLoopRun();
    });
}

- (void)stopMemorySizeMonitor{
    if (NO == self.isMemorySizeMonitor) {
        return;
    }
    _memorySizeMonitor = NO;
    if(_monitorTimer) {
        CFRunLoopTimerInvalidate(_monitorTimer);
        _monitorTimer = NULL;
    }
}

- (void)startMallocStackMonitorWithThreshholdInBytes:(size_t)threshholdInBytes block:(void (^)(NSString * _Nonnull,NSString *_Nonnull, size_t))block{
    if (YES == self.isSingleMallocMonitor) {
        return;
    }
    gThreshholdInBytes_ = threshholdInBytes;
    self.singleMallocBlock = block;
    malloc_logger = (malloc_logger_t *)lx_dev_stack_logger;
}

- (void)stopMallocStackMonitor{
    malloc_logger = NULL;
}

@end


static void lx_dev_stack_logger(uint32_t type, uintptr_t arg1, uintptr_t arg2, uintptr_t arg3, uintptr_t result, uint32_t backtrace_to_skip){
    size_t size = 0;
    if(type == LXMallocTypeMalloc|| type == LXMallocTypeCalloc){//malloc或calloc 分配内存
        size = arg2;
    }else if (type == LXMallocTypeRealloc){//重新分配
        size = arg3;
    }else{//释放
        
    }
    if (size > MAX(kThreshholdInBytes, gThreshholdInBytes_)) {//打印堆栈
        @autoreleasepool {
            NSString *log = [LXBacktrace backtraceStacksAndSymbol];
            NSString *stack = [LXBacktrace backtraceStacksNoSymbol];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                NSMutableString *stackInfo = [[NSMutableString alloc] initWithFormat:@"chunk_malloc:%.2f KB stack:\n",(double)size/(1024)];
                [stackInfo appendString:log];
                void(^singleMallocBlock)(NSString * _Nullable stackLog,NSString * _Nonnull stack, size_t bytes) = [[LXMEMMonitor defaultMonitor] singleMallocBlock];
                if (singleMallocBlock) {
                    singleMallocBlock(log,stack,size);
                }
            });
        }
    }
}
