//
//  LXCrashEntryContext.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#ifndef LXCrashEntryContext_h
#define LXCrashEntryContext_h

#ifdef __cplusplus
extern "C" {
#endif

#include <stdio.h>
#include "LXCrashType.h"
    
#include <mach/mach_types.h>
#include <signal.h>
#include <stdbool.h>

typedef enum{
    LXCrashReservedThreadTypeMachPrimary,
    LXCrashReservedThreadTypeMachSecondary,
    LXCrashReservedThreadTypeCount
} LXCrashReservedTheadType;

    
typedef struct LXCrash_EntryContext {
    
    // Caller defined values. Caller must fill these out prior to installation.
    
    /** Called by the crash handler when a crash is detected. */
    void (*onCrash)(void);
    
    
    // Implementation defined values. Caller does not initialize these.
    
    /** Threads reserved by the crash handlers, which must not be suspended. */
    thread_t reservedThreads[LXCrashReservedThreadTypeCount];
    
    /** If true, the crash handling system is currently handling a crash.
     * When false, all values below this field are considered invalid.
     */
    bool handlingCrash;
    
    /** If true, a second crash occurred while handling a crash. */
    bool crashedDuringCrashHandling;
    
    /** If true, the registers contain valid information about the crash. */
    bool registersAreValid;
    
    /** True if the crash system has detected a stack overflow. */
    bool isStackOverflow;
    
    /** The thread that caused the problem. */
    thread_t offendingThread;
    
    /** Address that caused the fault. */
    uintptr_t faultAddress;
    
    /** The type of crash that occurred.
     * This determines which other fields are valid. */
    LXCrashType crashType;
    
    /** Short description of why the crash occurred. */
    const char* crashReason;
    
    /** The stack trace. */
    uintptr_t* stackTrace;
    
    /** Length of the stack trace. */
    int stackTraceLength;
    
    struct
    {
        /** The mach exception type. */
        int type;
        
        /** The mach exception code. */
        int64_t code;
        
        /** The mach exception subcode. */
        int64_t subcode;
    } mach;
    
    struct
    {
        /** The exception name. */
        const char* name;
        
        const char *callStackSymbols;
        
    } NSException;
    
    struct
    {
        /** The exception name. */
        const char* name;
        
    } CPPException;
    
    struct
    {
        /** User context information. */
        const void* userContext;
        
        /** Signal information. */
        const siginfo_t* signalInfo;
    } signal;
    
    struct
    {
        /** The exception name. */
        const char* name;
        
        /** The line of code where the exception occurred. Can be NULL. */
        const char* lineOfCode;
        
        /** The user-supplied custom format stack trace. */
        const char* customStackTrace;
        
        /** Length of the stack trace. */
        int customStackTraceLength;
    } userException;
    
}LXCrash_EntryContext;
    
    LXCrashType lxcrash_installWithContext(LXCrash_EntryContext *context,LXCrashType crashType,void (*onCrash)(void));
    
    void lxcrash_uninstall(LXCrashType type);
    
    /** Suspend all non-reserved threads.
     *
     * Reserved threads include the current thread and all threads in
     "reservedThreads" in the context.
     */
    void lxcrash_suspendThreads(void);
    
    /** Resume all non-reserved threads.
     *
     * Reserved threads include the current thread and all threads in
     * "reservedThreads" in the context.
     */
    void lxcrash_resumeThreads(void);
    
    /** Prepare the context for handling a new crash.
     */
    void lxcrash_beginHandlingCrash(LXCrash_EntryContext* context);
    
    /** Clear a crash sentry context.
     */
    void lxcrash_clearContext(LXCrash_EntryContext* context);

#ifdef __cplusplus
}
#endif

#endif /* LXCrashEntryContext_h */
