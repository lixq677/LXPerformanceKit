//
//  LXCrash_MachException.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#ifndef LXCrash_MachException_h
#define LXCrash_MachException_h

#ifdef __cplusplus
extern "C" {
#endif
    
    
#include "LXCrashEntryContext.h"
    
    
    /** Install our custom mach exception handler.
     *
     * @param context Contextual information for the crash handler.
     *
     * @return true if installation was succesful.
     */
    bool lxcrash_installMachHandler(LXCrash_EntryContext *context);
    
    /** Uninstall our custom mach exception handler.
     */
    void lxcrash_uninstallMachHandler(void);
    
    
#ifdef __cplusplus
}
#endif

#endif /* LXCrash_MachException_h */
