//
//  LXCrashType.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#ifndef LXCrashType_h
#define LXCrashType_h

/** Different ways an application can crash:
 * - Mach kernel exception
 * - Fatal signal
 * - Uncaught C++ exception
 * - Uncaught Objective-C NSException
 * - Deadlock on the main thread
 * - User reported custom exception
 */
typedef enum {
    LXCrashTypeNone                = 0,
    LXCrashTypeNSException         = 1, //NSException OC异常
    LXCrashTypeSignal              = (1<<1),//信号异常，软中断异常
    LXCrashTypeMachException       = (1<<2),//iOS内核报异常
    LXCrashTypeCPPException        = (1<<3),//CPP报异常
    LXCrashTypeMainThreadDeadLock  = (1<<4),//主线程死锁异常
    LXCrashTypeUserDefined         = (1<<5),//用户主动抛异常
    
}LXCrashType;

#define LXCrashTypeAll    \
(\
    LXCrashTypeNSException|\
    LXCrashTypeSignal|\
    LXCrashTypeMachException|\
    LXCrashTypeMainThreadDeadLock|\
    LXCrashTypeCPPException|\
    LXCrashTypeUserDefined\
)\

#define LXCrashTypeAsyncSafe        \
(                                   \
LXCrashTypeMachException      | \
LXCrashTypeNSException        | \
LXCrashTypeCPPException       | \
LXCrashTypeSignal               \
)

#define LXCrashTypeProductionSafe \
(\
LXCrashTypeAll &\
(~LXCrashTypeMainThreadDeadLock)\
)


#endif /* LXCrashType_h */
