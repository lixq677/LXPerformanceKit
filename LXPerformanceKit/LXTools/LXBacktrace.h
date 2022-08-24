//
//  LXBacktraceLogger.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LXLOG NSLog(@"%@",[LXBacktraceLogger backtraceOfCurrentThread]);
#define LXLOG_MAIN NSLog(@"%@",[LXBacktraceLogger backtraceOfMainThread]);
#define LXLOG_ALL NSLog(@"%@",[LXBacktraceLogger backtraceOfAllThread]);

@interface LXBacktrace : NSObject

+ (NSString *)backtraceAllThread;
+ (NSString *)backtraceCurrentThread;
+ (NSString *)backtraceMainThread;
+ (NSString *)backtraceNSThread:(NSThread *)thread;
///转换oc线程为linux 线程
+ (thread_t)machThreadFromNSThread:(NSThread *)nsthread;

/// 回溯linux 线程
+ (NSString *)backtraceThread:(thread_t)thread;

///回溯堆栈信息，只有image 的名字以及相关地址信息
+ (NSString *)backtraceStacksNoSymbol;

/*堆栈信息，已符号化*/
+ (NSString *)backtraceStacksAndSymbol;

+ (NSArray *)baseAddressInfo;


@end

NS_ASSUME_NONNULL_END
