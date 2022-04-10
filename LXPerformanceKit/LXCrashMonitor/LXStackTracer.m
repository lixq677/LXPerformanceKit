//
//  LXStackTracer.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/9.
//

#import "LXStackTracer.h"
#include <execinfo.h>
#include <unistd.h>


/** The maximum number of stack trace lines to use if none is specified. */
#define kDefaultMaxEntries 40

@implementation LXStackTracer


+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LXStackTracer alloc]init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        self.processName = [[NSProcessInfo processInfo] processName];
    }
    return self;
}

- (NSArray *)generateTrace {
    
    return [self generateTraceWithMaxEntries:kDefaultMaxEntries];
}

- (NSArray *)generateTraceWithMaxEntries:(unsigned int)maxEntries {
    //get stack strace from the os
    void* callstack[maxEntries];
    int numFrames = backtrace(callstack, maxEntries);
    char** symbols = backtrace_symbols(callstack, numFrames);
    
    //Create StackTraceEntries.
    NSMutableArray* stackTrace = [NSMutableArray arrayWithCapacity:maxEntries];
    for (int i=0; i<numFrames; i++) {
        [stackTrace addObject:[StackTraceEntry entryWithTraceLine:[NSString stringWithUTF8String:symbols[i]]]];
    }
    
    return stackTrace;
}

- (NSArray*)intelligentTrace:(NSArray *)stackTrace {
    
    int startOffset = 0;
    // Anything with this process name at the start is going to be part of the
    // exception/signal catching.  We skip that.
    for (int i=0; i<[stackTrace count]; i++) {
        StackTraceEntry *entry = [stackTrace objectAtIndex:i];
        if (![self.processName isEqualToString:entry.library]) {
            startOffset = i;
            break;
        }
    }
    
    // Beneath that is a bunch of runtime error handling buff. we skip this as well
    for (int i=startOffset; i<[stackTrace count]; i++) {
        StackTraceEntry* entry = [stackTrace objectAtIndex:i];
        if (0xffffffff == entry.address) {
            //Signal handler stack trace is useless up to "0xffffffff 0x0 + 4294967295"
            startOffset = i+1;
            break;
        }
        if ([@"__objc_personality_v0" isEqualToString:entry.selectorName]) {
            //Exception handler stack trace is useless up to "__objc_personality_v0 + 0"
            startOffset = i+1;
            break;
        }
        
    }
    
    // Look for the last point where it was still in our code.
    // If we don't find anything, we'll just use everything past the exception/signal stuff.
    for(int i = startOffset; i < [stackTrace count]; i++)
    {
        StackTraceEntry* entry = [stackTrace objectAtIndex:i];
        // If we reach the "main" function, we've exhausted the stack trace.
        // Since we couldn't find anything, start from the previously calculated starting point.
        if([@"main" isEqualToString:entry.selectorName])
        {
            break;
        }
        
        // If we find something from our own code, use one level higher as the starting point.
        if([self.processName isEqualToString:entry.library])
        {
            startOffset = i - 1;
            break;
        }
    }
    
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[stackTrace count] - startOffset];
    for(int i = startOffset; i < [stackTrace count]; i++)
    {
        StackTraceEntry* entry = [stackTrace objectAtIndex:i];
        // We don't care about intermediate forwarding functions.
        if(![@"___forwarding___" isEqualToString:entry.selectorName] &&
           ![@"_CF_forwarding_prep_0" isEqualToString:entry.selectorName])
        {
            [result addObject:[stackTrace objectAtIndex:i]];
        }
    }
    
    return result;
}

- (NSString*)printableTrace:(NSArray *)stackTrace {
    
    NSMutableString* string = [NSMutableString stringWithCapacity:[stackTrace count] * 100];
    for(StackTraceEntry* entry in stackTrace)
    {
        [string appendString:[entry description]];
        [string appendString:@"\n"];
    }
    return string;
}


- (NSString *)condensedPrintableTrace:(NSArray *)stackTrace {
    NSMutableString* string = [NSMutableString stringWithCapacity:[stackTrace count] * 50];
    bool firstRound = YES;
    for(StackTraceEntry* entry in stackTrace)
    {
        if(firstRound)
        {
            firstRound = NO;
        }
        else
        {
            // Space separated.
            [string appendString:@" "];
        }
        
        if(nil != entry.objectClass)
        {
            // -[MyClass myMethod:anExtraParameter] or
            // +[MyClass myClassMethod:anExtraParameter]
            NSString* levelPrefix = entry.isClassLevelSelector ? @"+" : @"-";
            [string appendFormat:@"%@[%@ %@]", levelPrefix, entry.objectClass, entry.selectorName];
        }
        else
        {
            // my_c_function
            [string appendFormat:@"%@", entry.selectorName];
        }
    }
    return string;
    
}

+ (NSString *)getMainCallStackSymbolMessageWithCallStackSymbos:(NSArray<NSString *> *)callStackSymbols {
    //MainCallStackSymbolMsg的格式为 +[类名 方法名] 或者 -[类名 方法名]
    __block NSString* mainCallStackSymbolMsg = nil;
    //匹配出来的格式 +[类名 方法名] 或者 -[类名 方法名]
    NSString *regularExpStr = @"[-\\+]\\[.+\\]";
    
    NSRegularExpression *regularExp = [[NSRegularExpression alloc] initWithPattern:regularExpStr options:NSRegularExpressionCaseInsensitive error:nil];
    
    
    for (int index = 2; index < callStackSymbols.count; index++) {
        NSString *callStackSymbol = callStackSymbols[index];
        
        [regularExp enumerateMatchesInString:callStackSymbol options:NSMatchingReportProgress range:NSMakeRange(0, callStackSymbol.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSString* tempCallStackSymbolMsg = [callStackSymbol substringWithRange:result.range];
                
                //get className
                NSString *className = [tempCallStackSymbolMsg componentsSeparatedByString:@" "].firstObject;
                className = [className componentsSeparatedByString:@"["].lastObject;
                
                NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(className)];
                
                //filter category and system class
                if (![className hasSuffix:@")"] && bundle == [NSBundle mainBundle]) {
                    mainCallStackSymbolMsg = tempCallStackSymbolMsg;
                    
                }
                *stop = YES;
            }
        }];
        
        if (mainCallStackSymbolMsg.length) {
            break;
        }
    }
    
    return mainCallStackSymbolMsg;
}

@end

@implementation StackTraceEntry

static NSMutableCharacterSet* objcSymbolSet;

+ (id)entryWithTraceLine:(NSString *)traceLine {
    return [[self alloc]initWithTraceLine:traceLine];
}


- (id)initWithTraceLine:(NSString *)traceLine {
    
    if (objcSymbolSet == nil) {
        objcSymbolSet = [[NSMutableCharacterSet alloc]init];
        [objcSymbolSet formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
        [objcSymbolSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithRange:NSMakeRange('!', '~' - '!')]];
    }
    if (self = [super init]) {
        
        self.rawEntry = traceLine;
        NSScanner *scanner = [NSScanner scannerWithString:self.rawEntry];
        do{
            if (![scanner scanInt:(int*)&_traceEntryNumber]){
                break;
            }
            
            //**参数会自动释放，如果是一个实例变量(instance variable)的话会报错，具体报错信息为：“passing address of non-local object to __autoreleasing parameter for write-back”
            NSString *tempStr = _library;
            if(![scanner scanUpToString:@" 0x" intoString:&tempStr]) {
                _library = tempStr;
                break;
            }
            _library = tempStr;
            
            if(![scanner scanHexInt:&_address]) {
                break;
            }
            
            tempStr = _selectorName;
            if(![scanner scanCharactersFromSet:objcSymbolSet intoString:&tempStr]) {
                _selectorName = tempStr;
                break;
            }
            _selectorName = tempStr;
            
            if([_selectorName length] > 2 && [_selectorName characterAtIndex:1] == '[')
            {
                _isClassLevelSelector = [_selectorName characterAtIndex:0] == '+';
                _objectClass = [_selectorName substringFromIndex:2] ;
                
                tempStr = _selectorName;
                if(![scanner scanUpToString:@"]" intoString:&tempStr]){
                    _selectorName = tempStr;
                    break;
                }
                _selectorName = tempStr;
                
                if(![scanner scanString:@"]" intoString:nil]){
                    break;
                }
            }
            
            if(![scanner scanString:@"+" intoString:nil]){
                break;
            };
            
            if(![scanner scanInt:&_offset]){
                break;
            }
        }while(0);
        
        if(nil == _library)
        {
            _library = @"???";
        }
        if(nil == _selectorName)
        {
            _selectorName = @"???";
        }
    }
    
    return self;
}

- (NSString*) description{
    return _rawEntry;
}

@end
