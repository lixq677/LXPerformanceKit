//
//  LXMEMMonitor.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import <Foundation/Foundation.h>
#import <LXPerformanceKit/LXMemoryInfo.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXMEMMonitor : NSObject

+ (instancetype)defaultMonitor;

//监听内存使用情况
@property (nonatomic,assign,getter=isMemorySizeMonitor,readonly)BOOL memorySizeMonitor;

//单次分配监听内存
@property (nonatomic,assign,getter=isSingleMallocMonitor,readonly)BOOL singleMallocMonitor;


- (void)startMemorySizeMonitorWithTimeInterval:(NSTimeInterval)timeInterval handler:(void(^)(LXMemoryInfo *memory))handler;

- (void)stopMemorySizeMonitor;

//监听单次内存分配,threshholdInBytes单位B，阀值，超过阀值回调block
//阀值不能设置太小，或设置小于10K 就直接10K,设置太小，分配的内存不够输出日志大小就会造成死循环
-(void)startMallocStackMonitorWithThreshholdInBytes:(size_t)threshholdInBytes block:(void(^)(NSString *stackLog,NSString *stack, size_t bytes))block;


//停止监听单次内存分配
-(void)stopMallocStackMonitor;

@end

NS_ASSUME_NONNULL_END
