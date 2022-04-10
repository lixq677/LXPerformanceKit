//
//  LXCrash_CPPException.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/7.
//

#import "LXCrash_CPPException.h"

#include "LXMach.h"

#include <cxxabi.h>
#include <dlfcn.h>
#include <exception>
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
#include <typeinfo>
#import <Foundation/Foundation.h>
//#import <CXLogKit/CXLogKit.h>


#define STACKTRACE_BUFFER_LENGTH 30
#define DESCRIPTION_BUFFER_LENGTH 1000


// Compiler hints for "if" statements
#define likely_if(x) if(__builtin_expect(x,1))
#define unlikely_if(x) if(__builtin_expect(x,0))


// ============================================================================
#pragma mark - Globals -
// ============================================================================

/** True if this handler has been installed. */
static volatile sig_atomic_t g_installed = 0;

/** True if the handler should capture the next stack trace. */
static bool g_captureNextStackTrace = false;

static std::terminate_handler g_originalTerminateHandler;

/** Buffer for the backtrace of the most recent exception. */
static uintptr_t g_stackTrace[STACKTRACE_BUFFER_LENGTH];

/** Number of backtrace entries in the most recent exception. */
static int g_stackTraceCount = 0;

/** Context to fill with crash information. */
static LXCrash_EntryContext* g_context;


// ============================================================================
#pragma mark - Callbacks -
// ============================================================================

typedef void (*cxa_throw_type)(void*, std::type_info*, void (*)(void*));

extern "C" void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*))
{
    if(g_captureNextStackTrace)
    {
        g_stackTraceCount = backtrace((void**)g_stackTrace, sizeof(g_stackTrace) / sizeof(*g_stackTrace));
    }
    
    static cxa_throw_type orig_cxa_throw = NULL;
    unlikely_if(orig_cxa_throw == NULL)
    {
        orig_cxa_throw = (cxa_throw_type) dlsym(RTLD_NEXT, "__cxa_throw");
    }
    orig_cxa_throw(thrown_exception, tinfo, dest);
    __builtin_unreachable();
}


static void CPPExceptionTerminate(void){
   
    
    //CXLogDebug(@"Trapped c++ exception");
    bool isNSException = false;
    char descriptionBuff[DESCRIPTION_BUFFER_LENGTH];
    const char* name = NULL;
    const char* description = NULL;
    
    //CXLogDebug(@"Get exception type name.");
    std::type_info* tinfo = __cxxabiv1::__cxa_current_exception_type();
    if(tinfo != NULL)
    {
        name = tinfo->name();
    }
    
    description = descriptionBuff;
    descriptionBuff[0] = 0;
    
    //CXLogDebug(@"Discovering what kind of exception was thrown.");
    g_captureNextStackTrace = false;
    try
    {
        throw;
    }
    catch(NSException* exception)
    {
        //CXLogDebug(@"Detected NSException. Letting the current NSException handler deal with it.");
        isNSException = true;
    }
    catch(std::exception& exc)
    {
        strncpy(descriptionBuff, exc.what(), sizeof(descriptionBuff));
    }
#define CATCH_VALUE(TYPE, PRINTFTYPE) \
catch(TYPE value)\
{ \
snprintf(descriptionBuff, sizeof(descriptionBuff), "%" #PRINTFTYPE, value); \
}
    CATCH_VALUE(char,                 d)
    CATCH_VALUE(short,                d)
    CATCH_VALUE(int,                  d)
    CATCH_VALUE(long,                ld)
    CATCH_VALUE(long long,          lld)
    CATCH_VALUE(unsigned char,        u)
    CATCH_VALUE(unsigned short,       u)
    CATCH_VALUE(unsigned int,         u)
    CATCH_VALUE(unsigned long,       lu)
    CATCH_VALUE(unsigned long long, llu)
    CATCH_VALUE(float,                f)
    CATCH_VALUE(double,               f)
    CATCH_VALUE(long double,         Lf)
    CATCH_VALUE(char*,                s)
   // CATCH_VALUE(const char*,          s)
    catch(...)
    {
        description = NULL;
    }
    g_captureNextStackTrace = (g_installed != 0);
    
    if(!isNSException)
    {
        bool wasHandlingCrash = g_context->handlingCrash;
        lxcrash_beginHandlingCrash(g_context);
        
        if(wasHandlingCrash)
        {
            //CXLogDebug(@"Detected crash in the crash reporter. Restoring original handlers.");
            g_context->crashedDuringCrashHandling = true;
            lxcrash_uninstall((LXCrashType)LXCrashTypeAll);
        }
        
        //CXLogDebug(@"Suspending all threads.");
        //lxcrash_suspendThreads();
        
        g_context->crashType = LXCrashTypeCPPException;
        g_context->offendingThread = lxmach_thread_self();
        g_context->registersAreValid = false;
        g_context->stackTrace = g_stackTrace + 1; // Don't record __cxa_throw stack entry
        g_context->stackTraceLength = g_stackTraceCount - 1;
        g_context->CPPException.name = name;
        g_context->crashReason = description;
        
        //CXLogDebug(@"Calling main crash handler.");
        g_context->onCrash();
        
        //CXLogDebug(@"Crash handling complete. Restoring original handlers.");
        lxcrash_uninstall((LXCrashType)LXCrashTypeAll);
        lxcrash_resumeThreads();
    }
    
    g_originalTerminateHandler();
}


// ============================================================================
#pragma mark - Public API -
// ============================================================================

extern "C" bool lxcrash_installCPPExceptionHandler(LXCrash_EntryContext* context){
    //CXLogDebug(@"Installing C++ exception handler.");
    
    if(g_installed)
    {
        //CXLogDebug(@"C++ exception handler already installed.");
        return true;
    }
    g_installed = 1;
    
    g_context = context;
    
    g_originalTerminateHandler = std::set_terminate(CPPExceptionTerminate);
    g_captureNextStackTrace = true;
    return true;
}

extern "C" void lxcrash_uninstallCPPExceptionHandler(void){
    //CXLogDebug(@"Uninstalling C++ exception handler.");
    if(!g_installed)
    {
        //CXLogDebug(@"C++ exception handler already uninstalled.");
        return;
    }
    
    g_captureNextStackTrace = false;
    std::set_terminate(g_originalTerminateHandler);
    g_installed = 0;
}
