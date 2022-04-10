//
//  LXCrash_NSException.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#ifndef LXCrash_NSException_h
#define LXCrash_NSException_h


#ifdef __cplusplus
extern "C" {
#endif
    
#include "LXCrashEntryContext.h"
    
bool lxcrash_installNSException(LXCrash_EntryContext *context);
    
void lxcrash_uninstallNSException(void);
    
#ifdef __cplusplus
}
#endif
    
#endif
