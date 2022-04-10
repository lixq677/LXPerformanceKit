//
//  LXCrash_CPPException.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#ifndef LXCrash_CPPException_h
#define LXCrash_CPPException_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include "LXCrashEntryContext.h"
    
    
    /** Install the C++ exception handler.
     *
     * @param context Contextual information for the crash handler.
     *
     * @return true if installation was succesful.
     */
    bool lxcrash_installCPPExceptionHandler(LXCrash_EntryContext* context);
    
    /** Uninstall the C++ exception handler.
     */
    void lxcrash_uninstallCPPExceptionHandler(void);
    
    
#ifdef __cplusplus
}
#endif

#endif /* LXCrash_CPPException_h */
