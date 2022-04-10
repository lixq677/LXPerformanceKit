//
//  LXCrash_UserException.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#ifndef LXCrash_UserException_h
#define LXCrash_UserException_h

#ifdef __cplusplus
extern "C" {
#endif
    
    #include "LXCrashEntryContext.h"
    
#include <signal.h>
#include <stdbool.h>
    
    
    /** Install the user exception handler.
     *
     * @param context Contextual information for the crash handler.
     *
     * @return true if installation was succesful.
     */
    bool lxcrash_installUserExceptionHandler(LXCrash_EntryContext* context);
    
    /** Uninstall the user exception handler.
     */
    void lxcrash_uninstallUserExceptionHandler(void);
    
    
    /** Report a custom, user defined exception.
     * If terminateProgram is true, all sentries will be uninstalled and the application will
     * terminate with an abort().
     *
     * @param name The exception name (for namespacing exception types).
     *
     * @param reason A description of why the exception occurred.
     *
     * @param lineOfCode A copy of the offending line of code (NULL = ignore).
     *
     * @param stackTrace An array of strings representing the call stack leading to the exception.
     *
     * @param stackTraceCount The length of the stack trace array (0 = ignore).
     *
     * @param terminateProgram If true, do not return from this function call. Terminate the program instead.
     */
    void lxcrash_reportUserException(const char* name,
                                           const char* reason,
                                           const char* lineOfCode,
                                           const char* stackTrace,
                                           size_t stackTraceCount,
                                           bool terminateProgram);
    
    
#ifdef __cplusplus
}
#endif

#endif /* LXCrash_UserException_h */
