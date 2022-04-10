//
//  LXCrash_Signal.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#import "LXCrash_Signal.h"
#include "LXMach.h"
#include "LXSignalInfo.h"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

/** Flag noting if we've installed our custom handlers or not.
 * It's not fully thread safe, but it's safer than locking and slightly better
 * than nothing.
 */
static volatile sig_atomic_t g_installed = 0;

/** Our custom signal stack. The signal handler will use this as its stack. */
static stack_t g_signalStack = {0};

/** Signal handlers that were installed before we installed ours. */
static struct sigaction* g_previousSignalHandlers = NULL;

/** Context to fill with crash information. */
static LXCrash_EntryContext* g_context;

void lxsignal_handle(int sigNum,
                              siginfo_t* signalInfo,
                              void* userContext)
{
    //printf("Trapped signal %d", sigNum);
    if(g_installed)
    {
        bool wasHandlingCrash = g_context->handlingCrash;
        lxcrash_beginHandlingCrash(g_context);
        
        //printf("Signal handler is installed. Continuing signal handling.");
        
        //printf("Suspending all threads.");
        //lxcrash_suspendThreads();
        
        if(wasHandlingCrash)
        {
            //printf("Detected crash in the crash reporter. Restoring original handlers.");
            g_context->crashedDuringCrashHandling = true;
            lxcrash_uninstall(LXCrashTypeAsyncSafe);
        }
        
        
        //printf("Filling out context.");
        g_context->crashType = LXCrashTypeSignal;
        g_context->offendingThread = lxmach_thread_self();
        g_context->registersAreValid = true;
        g_context->faultAddress = (uintptr_t)signalInfo->si_addr;
        g_context->signal.userContext = userContext;
        g_context->signal.signalInfo = signalInfo;
        
        
        //printf("Calling main crash handler.");
        g_context->onCrash();
        
        //printf("Crash handling complete. Restoring original handlers.");
        lxcrash_uninstall(LXCrashTypeAsyncSafe);
        lxcrash_resumeThreads();
    }
    
    //printf("Re-raising signal for regular handlers to catch.");
    // This is technically not allowed, but it works in OSX and iOS.
    raise(sigNum);
}

bool lxcrash_installSignalHandler(LXCrash_EntryContext *context){
    //printf("Installing signal handler.");
    
    if(g_installed)
    {
        //printf("Signal handler already installed.");
        return true;
    }
    g_installed = 1;
    
    g_context = context;
    
    if(g_signalStack.ss_size == 0)
    {
        //printf("Allocating signal stack area.");
        g_signalStack.ss_size = SIGSTKSZ;
        g_signalStack.ss_sp = malloc(g_signalStack.ss_size);
    }
    
    //printf("Setting signal stack area.");
    if(sigaltstack(&g_signalStack, NULL) != 0)
    {
        //printf("signalstack: %s", strerror(errno));
        goto failed;
    }
    
    const int* fatalSignals = lxsignal_fatalSignals();
    int fatalSignalsCount = lxsignal_numFatalSignals();
    
    if(g_previousSignalHandlers == NULL)
    {
        //printf("Allocating memory to store previous signal handlers.");
        g_previousSignalHandlers = malloc(sizeof(*g_previousSignalHandlers)
                                          * (unsigned)fatalSignalsCount);
    }
    
    struct sigaction action = {{0}};
    action.sa_flags = SA_SIGINFO | SA_ONSTACK;
#ifdef __LP64__
    action.sa_flags |= SA_64REGSET;
#endif
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = &lxsignal_handle;
    
    for(int i = 0; i < fatalSignalsCount; i++)
    {
        //printf("Assigning handler for signal %d", fatalSignals[i]);
        if(sigaction(fatalSignals[i], &action, &g_previousSignalHandlers[i]) != 0)
        {
            char sigNameBuff[30];
            const char* sigName = lxsignal_signalName(fatalSignals[i]);
            if(sigName == NULL)
            {
                snprintf(sigNameBuff, sizeof(sigNameBuff), "%d", fatalSignals[i]);
                sigName = sigNameBuff;
            }
            //printf("sigaction (%s): %s", sigName, strerror(errno));
            // Try to reverse the damage
            for(i--;i >= 0; i--)
            {
                sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
            }
            goto failed;
        }
    }
    //printf("Signal handlers installed.");
    return true;
    
failed:
    //printf("Failed to install signal handlers.");
    g_installed = 0;
    return false;
}

void lxcrash_uninstallSignalHandler(void){
    //printf("Uninstalling signal handlers.");
    if(!g_installed)
    {
        //printf("Signal handlers were already uninstalled.");
        return;
    }
    
    const int* fatalSignals = lxsignal_fatalSignals();
    int fatalSignalsCount = lxsignal_numFatalSignals();
    
    for(int i = 0; i < fatalSignalsCount; i++)
    {
        //printf("Restoring original handler for signal %d", fatalSignals[i]);
        sigaction(fatalSignals[i], &g_previousSignalHandlers[i], NULL);
    }
    
    //printf("Signal handlers uninstalled.");
    g_installed = 0;
}
