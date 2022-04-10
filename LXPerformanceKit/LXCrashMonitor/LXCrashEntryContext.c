//
//  LXCrashEntryContext.c
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#include "LXCrashEntryContext.h"
#include "LXMach.h"
#include "LXCrash_NSException.h"
#include "LXCrash_Signal.h"
#include "LXCrash_MachException.h"
#include "LXCrash_DeadLock.h"
#include "LXCrash_CPPException.h"
#include "LXCrash_UserException.h"

typedef struct
{
    LXCrashType crashType;
    bool (*install)(LXCrash_EntryContext* context);
    void (*uninstall)(void);
} LXCrashSentry;

static LXCrashSentry g_sentries[] =
{
    {
        LXCrashTypeMachException,
        lxcrash_installMachHandler,
        lxcrash_uninstallMachHandler,
    },
    {
        LXCrashTypeSignal,
        lxcrash_installSignalHandler,
        lxcrash_uninstallSignalHandler,
    },
    {
        LXCrashTypeCPPException,
        lxcrash_installCPPExceptionHandler,
        lxcrash_uninstallCPPExceptionHandler,
    },
    {
        LXCrashTypeNSException,
        lxcrash_installNSException,
        lxcrash_uninstallNSException,
    },
    {
        LXCrashTypeMainThreadDeadLock,
        lxcrash_installDeadlockHandler,
        lxcrash_uninstallDeadlockHandler,
    },
    {
        LXCrashTypeUserDefined,
        lxcrash_installUserExceptionHandler,
        lxcrash_uninstallUserExceptionHandler,
    },
};
static size_t g_sentriesCount = sizeof(g_sentries) / sizeof(*g_sentries);


/** Context to fill with crash information. */
static LXCrash_EntryContext* g_context = NULL;

/** Keeps track of whether threads have already been suspended or not.
 * This won't handle multiple suspends in a row.
 */
static bool g_threads_are_running = true;

void lxcrash_suspendThreads(void){
    //printf("Suspending threads.");
    if(!g_threads_are_running){
        //printf("Threads already suspended.");
        return;
    }
    
    if(g_context != NULL){
        int numThreads = sizeof(g_context->reservedThreads) / sizeof(g_context->reservedThreads[0]);
        //printf("Suspending all threads except for %d reserved threads.", numThreads);
        if(lxmach_suspendAllThreadsExcept(g_context->reservedThreads, numThreads)){
            //printf("Suspend successful.");
            g_threads_are_running = false;
        }
    }else{
        //printf("Suspending all threads.");
        if(lxmach_suspendAllThreads()){
            //printf("Suspend successful.");
            g_threads_are_running = false;
        }
    }
    //printf("Suspend complete.");
}

void lxcrash_resumeThreads(void){
    //printf("Resuming threads.");
    if(g_threads_are_running){
        //printf("Threads already resumed.");
        return;
    }
    
    if(g_context != NULL)
    {
        int numThreads = sizeof(g_context->reservedThreads) / sizeof(g_context->reservedThreads[0]);
        //printf("Resuming all threads except for %d reserved threads.", numThreads);
        if(lxmach_resumeAllThreadsExcept(g_context->reservedThreads, numThreads))
        {
            //printf("Resume successful.");
            g_threads_are_running = true;
        }
    }
    else
    {
        //printf("Resuming all threads.");
        if(lxmach_resumeAllThreads())
        {
            //printf("Resume successful.");
            g_threads_are_running = true;
        }
    }
    //printf("Resume complete.");
}

void lxcrash_clearContext(LXCrash_EntryContext* context)
{
    void (*onCrash)(void) = context->onCrash;
    memset(context, 0, sizeof(*context));
    context->onCrash = onCrash;
}

void lxcrash_beginHandlingCrash(LXCrash_EntryContext* context)
{
    lxcrash_clearContext(context);
    context->handlingCrash = true;
}

#pragma mark - public methods
LXCrashType lxcrash_installWithContext(LXCrash_EntryContext *context,LXCrashType crashType,void (*onCrash)(void)){
    //printf("Installing handlers with context %p, crash types 0x%x.", context, crashType);
    g_context = context;
    lxcrash_clearContext(g_context);
    g_context->onCrash = onCrash;
    
    LXCrashType installed = 0;
    for(size_t i = 0; i < g_sentriesCount; i++)
    {
        LXCrashSentry* sentry = &g_sentries[i];
        if(sentry->crashType & crashType)
        {
            if(sentry->install == NULL || sentry->install(context))
            {
                installed |= sentry->crashType;
            }
        }
    }
    
    return installed;
}

void lxcrash_uninstall(LXCrashType type){
    for(size_t i = 0; i < g_sentriesCount; i++)
    {
        LXCrashSentry* sentry = &g_sentries[i];
        if(sentry->crashType & type)
        {
            if(sentry->install != NULL)
            {
                sentry->uninstall();
            }
        }
    }
}



