//
//  LXCrash_Signal.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#ifndef LXCrash_Signal_h
#define LXCrash_Signal_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include "LXCrashEntryContext.h"
    
    bool lxcrash_installSignalHandler(LXCrash_EntryContext *context);
    void lxcrash_uninstallSignalHandler(void);
    
#ifdef __cplusplus
}
#endif

#endif /* LXCrash_Signal_h */

