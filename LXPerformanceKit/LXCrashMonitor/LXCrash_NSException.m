//
//  LXCrash_NSException.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#import "LXCrash_NSException.h"
#include "LXMach.h"
#import "LXStackTracer.h"
//#import <CXLogKit/CXLogKit.h>

static volatile sig_atomic_t g_NSException_installed = 0;

static NSUncaughtExceptionHandler* g_previousUncaughtExceptionHandler;

/** Context to fill with crash information. */
static LXCrash_EntryContext* g_context;

static void lxcrash_handleNSException(NSException *exception){
    if (g_NSException_installed) {
        //
        bool wasHandlingCrash = g_context->handlingCrash;
        lxcrash_beginHandlingCrash(g_context);
        
        //CXLogDebug(@"Exception handler is installed. Continuing exception handling.");
        
        if(wasHandlingCrash){
            //CXLogDebug(@"Detected crash in the crash reporter. Restoring original handlers.");
            g_context->crashedDuringCrashHandling = true;
            lxcrash_uninstall(LXCrashTypeAll);
        }
        
        //CXLogDebug(@"Suspending all threads.");
        //lxcrash_suspendThreads();
        
        //CXLogDebug(@"Filling out context.");
        NSArray* addresses = [exception callStackReturnAddresses];
        NSUInteger numFrames = [addresses count];
        uintptr_t* callstack = malloc(numFrames * sizeof(*callstack));
        for(NSUInteger i = 0; i < numFrames; i++)
        {
            callstack[i] = [[addresses objectAtIndex:i] unsignedLongValue];
        }
        
        g_context->crashType = LXCrashTypeNSException;
        g_context->offendingThread = lxmach_thread_self();
        g_context->registersAreValid = false;
        g_context->NSException.name = strdup([[exception name] UTF8String]);
        g_context->crashReason = strdup([[exception reason] UTF8String]);
        g_context->stackTrace = callstack;
        g_context->stackTraceLength = (int)numFrames;
        
        NSArray *symbols = [exception callStackSymbols];
        if ([symbols count]>0) {
            NSString *callStackSymbol = [LXStackTracer getMainCallStackSymbolMessageWithCallStackSymbos:symbols];
            if (callStackSymbol.length) {
                g_context->NSException.callStackSymbols = strdup([callStackSymbol UTF8String]);
            } else {
                //CXLogDebug(@"callStackSymbol was nil!");
            }
        }
        
        //CXLogDebug(@"Calling main crash handler.");
        g_context->onCrash();
        
        //CXLogDebug(@"Crash handling complete. Restoring original handlers.");
        lxcrash_uninstall(LXCrashTypeAll);
        
        if (g_previousUncaughtExceptionHandler != NULL)
        {
            //CXLogDebug(@"Calling original exception handler.");
            g_previousUncaughtExceptionHandler(exception);
        }
    }
}

bool lxcrash_installNSException(LXCrash_EntryContext *context){
    do{
        if (g_NSException_installed) {
            break;
        }
        
        g_NSException_installed = 1;
        g_context = context;
        
        g_previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
        
        //CXLogDebug(@"install nsexception");
        NSSetUncaughtExceptionHandler(&lxcrash_handleNSException);
    }while(0);
    
    return true;
}

void lxcrash_uninstallNSException(void){
    if (g_NSException_installed) {
        //CXLogDebug(@"uninstall NSException");
        NSSetUncaughtExceptionHandler(g_previousUncaughtExceptionHandler);
        
        g_NSException_installed = 0;
    }
}
