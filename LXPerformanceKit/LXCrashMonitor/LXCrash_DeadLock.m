//
//  LXCrash_DeadLock.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/8.
//

#import "LXCrash_DeadLock.h"
#import "LXMach.h"
//#import <CXLogKit/CXLogKit.h>

@import Foundation;

#define kIdleInterval 5.0f


@class LXCrashDeadlockMonitor;

// ============================================================================
#pragma mark - Globals -
// ============================================================================

/** Flag noting if we've installed our custom handlers or not.
 * It's not fully thread safe, but it's safer than locking and slightly better
 * than nothing.
 */
static volatile sig_atomic_t g_installed = 0;

/** Thread which monitors other threads. */
static LXCrashDeadlockMonitor* g_monitor;

/** Context to fill with crash information. */
static LXCrash_EntryContext* g_context;

/** Interval between watchdog pulses. */
static double g_watchdogInterval = 0;


// ============================================================================
#pragma mark - X -
// ============================================================================


@interface LXCrashDeadlockMonitor: NSObject

@property(nonatomic, readwrite, retain) NSThread* monitorThread;
@property(nonatomic, readwrite, assign) thread_t mainThread;
@property(atomic, readwrite, assign) BOOL awaitingResponse;

@end

@implementation LXCrashDeadlockMonitor

@synthesize monitorThread = _monitorThread;
@synthesize mainThread = _mainThread;
@synthesize awaitingResponse = _awaitingResponse;

- (id) init{
    if((self = [super init])){
        // target (self) is retained until selector (runMonitor) exits.
        self.monitorThread = [[NSThread alloc] initWithTarget:self selector:@selector(runMonitor) object:nil];
        self.monitorThread.name = @"LXCrash Deadlock Detection Thread";
        [self.monitorThread start];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainThread = lxmach_thread_self();
        });
    }
    return self;
}

- (void)cancel{
    [self.monitorThread cancel];
}

- (void)watchdogPulse{
    __block id blockSelf = self;
    self.awaitingResponse = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [blockSelf watchdogAnswer];
    });
}

- (void) watchdogAnswer{
    self.awaitingResponse = NO;
}

- (void)handleDeadlock{
    lxcrash_beginHandlingCrash(g_context);
    
    //CXLogDebug(@"Filling out context.");
    g_context->crashType = LXCrashTypeMainThreadDeadLock;
    g_context->offendingThread = self.mainThread;
    g_context->registersAreValid = false;
    
    //CXLogDebug(@"Calling main crash handler.");
    g_context->onCrash();
    
    
    //CXLogDebug(@"Crash handling complete. Restoring original handlers.");
    lxcrash_uninstall(LXCrashTypeAll);
    
    //CXLogDebug(@"Calling abort()");
    abort();
}

- (void) runMonitor{
    BOOL cancelled = NO;
    do{
        // Only do a watchdog check if the watchdog interval is > 0.
        // If the interval is <= 0, just idle until the user changes it.
        @autoreleasepool {
            NSTimeInterval sleepInterval = g_watchdogInterval;
            BOOL runWatchdogCheck = sleepInterval > 0;
            if(!runWatchdogCheck){
                sleepInterval = kIdleInterval;
            }
            [NSThread sleepForTimeInterval:sleepInterval];
            cancelled = self.monitorThread.isCancelled;
            if(!cancelled && runWatchdogCheck){
                if(self.awaitingResponse){
                    [self handleDeadlock];
                }else{
                    [self watchdogPulse];
                }
            }
        }
    } while (!cancelled);
}

@end


bool lxcrash_installDeadlockHandler(LXCrash_EntryContext* context){
    //CXLogDebug(@"Installing deadlock handler.");
    if(g_installed){
        //CXLogDebug(@"Deadlock handler already installed.");
        return true;
    }
    g_installed = 1;
    
    g_context = context;
    
    //CXLogDebug(@"Creating new deadlock monitor.");
    g_monitor = [[LXCrashDeadlockMonitor alloc] init];
    return true;
}

void lxcrash_uninstallDeadlockHandler(void){
    //CXLogDebug(@"Uninstalling deadlock handler.");
    if(!g_installed)
    {
        //CXLogDebug(@"Deadlock handler was already uninstalled.");
        return;
    }
    [g_monitor cancel];
    g_monitor = nil;
    
    g_installed = 0;
}

void lxcrash_setDeadlockHandlerWatchdogInterval(double value)
{
    g_watchdogInterval = value;
}
