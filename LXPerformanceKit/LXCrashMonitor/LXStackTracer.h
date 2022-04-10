//
//  LXStackTracer.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXStackTracer : NSObject

/**
 当前app线程名
 */
@property (nonatomic, strong) NSString *processName;

+ (instancetype)sharedInstance;

/**
 Generate a stack trace with the default maximum entries
 */
- (NSArray*)generateTrace;

/**
 Generate a stack trace with the specified maximum entries.
 */
- (NSArray*)generateTraceWithMaxEntries:(unsigned int)maxEntries;

/**
 * Create an "intelligent" trace from the specified trace.
 * This is designed primarily for stripping out useless trace lines from
 * an exception or signal trace.
 */
- (NSArray*)intelligentTrace:(NSArray*)stackTrace;

/**
 Turn the specified stack trace into a printabe string.
 */
- (NSString*)printableTrace:(NSArray*)stackTrace;

/**
 * Turn the specified stack trace into a condensed printable string.
 * The condensed entries are space separated, and only contain the object class
 * (if any) and the selector call.
 */
- (NSString*)condensedPrintableTrace:(NSArray*)stackTrace;

/**
 获取堆栈主要崩溃精简化得信息<根据正则表达式匹配出来>

 @param callStackSymbols 堆栈的主要崩溃信息
 @return 堆栈主要崩溃精简化信息
 */
+ (NSString*)getMainCallStackSymbolMessageWithCallStackSymbos:(NSArray<NSString*> *)callStackSymbols;

@end

@interface StackTraceEntry : NSObject

/**
 trace entry的位置
 */
@property (nonatomic, readonly) unsigned int traceEntryNumber;

/**
 Which library, framework, or process the entry is from.
 */
@property (nonatomic, readonly) NSString *library;

/**
 The address in momery
 */
@property (nonatomic, readonly) unsigned int address;

/**
 The class of object that made the call
 */
@property (nonatomic, readonly) NSString *objectClass;

/**
 If true, this is a class level selector being called.
 */
@property (nonatomic, readonly) BOOL isClassLevelSelector;

/**
 The selector being called.
 */
@property (nonatomic, readonly) NSString* selectorName;

/**
 The offset within the function or method.
 */
@property (nonatomic, readonly) int offset;


@property (nonatomic, strong) NSString *rawEntry;

/**
 Create a new stack trace entry from the specified trace line.
 */
+ (id) entryWithTraceLine:(NSString*)traceLine;

/**
 Initialize a stack trace entry from the specified trace line.
 */
- (id) initWithTraceLine:(NSString*)traceLine;


@end

NS_ASSUME_NONNULL_END
