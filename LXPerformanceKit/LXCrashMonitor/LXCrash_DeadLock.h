//
//  LXCrash_DeadLock.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#ifndef LXCrash_DeadLock_h
#define LXCrash_DeadLock_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include "LXCrashEntryContext.h"
    
    
    /** Install the deadlock handler.
     *
     * @param context The crash context to fill out when a crash occurs.
     *
     * @return true if installation was succesful.
     */
    bool lxcrash_installDeadlockHandler(LXCrash_EntryContext* context);
    
    /** Uninstall our custome NSException handler.
     */
    void lxcrash_uninstallDeadlockHandler(void);
    
    /** Set the interval between watchdog checks on the main thread.
     * Default is 5 seconds.
     *
     * @param value The number of seconds between checks (0 = disabled).
     */
    void lxcrash_setDeadlockHandlerWatchdogInterval(double value);
    
    
#ifdef __cplusplus
}
#endif

#endif /* LXCrash_DeadLock_h */
