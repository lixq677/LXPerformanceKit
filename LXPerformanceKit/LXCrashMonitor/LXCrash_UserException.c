//
//  LXCrash_UserException.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#import "LXCrash_UserException.h"
#include "LXMach.h"

#include <execinfo.h>
#include <stdlib.h>


/** Context to fill with crash information. */
static LXCrash_EntryContext* g_context;


bool lxcrash_installUserExceptionHandler(LXCrash_EntryContext* const context)
{
    //printf("Installing user exception handler.");
    g_context = context;
    return true;
}

void lxcrash_uninstallUserExceptionHandler(void)
{
    //printf("Uninstalling user exception handler.");
    g_context = NULL;
}

void lxcrash_reportUserException(const char* name,
                                       const char* reason,
                                       const char* lineOfCode,
                                       const char* stackTrace,
                                       size_t stackTraceCount,
                                       bool terminateProgram){
    if(g_context != NULL){
        lxcrash_beginHandlingCrash(g_context);
        
        //printf("Suspending all threads");
        //lxcrash_suspendThreads();
        
        //printf("Fetching call stack.");
        int callstackCount = 100;
        uintptr_t callstack[callstackCount];
        callstackCount = backtrace((void**)callstack, callstackCount);
        if(callstackCount <= 0){
            //printf("backtrace() returned call stack length of %d", callstackCount);
            callstackCount = 0;
        }
        
        //printf("Filling out context.");
        g_context->crashType = LXCrashTypeUserDefined;
        g_context->offendingThread = lxmach_thread_self();
        g_context->registersAreValid = false;
        g_context->crashReason = reason;
        g_context->stackTrace = callstack;
        g_context->stackTraceLength = callstackCount;
        g_context->userException.name = name;
        g_context->userException.lineOfCode = lineOfCode;
        g_context->userException.customStackTrace = stackTrace;
        g_context->userException.customStackTraceLength = (int)stackTraceCount;
        
        //printf("Calling main crash handler.");
        g_context->onCrash();
        
        if(terminateProgram){
            lxcrash_uninstall(LXCrashTypeAll);
            lxcrash_resumeThreads();
            abort();
        }else{
            lxcrash_clearContext(g_context);
            lxcrash_resumeThreads();
        }
    }
}
