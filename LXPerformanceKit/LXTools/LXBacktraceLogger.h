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

uintptr_t lx_get_load_address(void);

uintptr_t lx_get_slide_address(void);

NSString *lx_get_dSYM_UUID(void);

NSArray *lx_baseAddressInfo(void);

@interface LXBacktraceLogger : NSObject

+ (NSString *)backtraceOfAllThread;
+ (NSString *)backtraceOfCurrentThread;
+ (NSString *)backtraceOfMainThread;
+ (NSString *)backtraceOfNSThread:(NSThread *)thread;


@end

NS_ASSUME_NONNULL_END
