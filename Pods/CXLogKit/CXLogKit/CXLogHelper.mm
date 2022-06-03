//
//  CXLogHelper.m
//  CXLog
//
//  Created by 李笑清 on 2020/7/10.
//  Copyright © 2020 李笑清. All rights reserved.
//

#import "CXLogHelper.h"
#import <mars/xlog/xlogger.h>
#import <mars/xlog/appender.h>
#import <mars/xlog/xloggerbase.h>

FOUNDATION_EXPORT  CXLogLevel cx_logger_Level(){
    return (CXLogLevel)xlogger_Level();
}

FOUNDATION_EXPORT void cx_logger_SetLevel(CXLogLevel level){
    xlogger_SetLevel((TLogLevel)level);
}

FOUNDATION_EXPORT int  cx_logger_IsEnabledFor(CXLogLevel level){
    return xlogger_IsEnabledFor((TLogLevel)level);
}

FOUNDATION_EXPORT void cx_logger_appender_open(CXAppenderMode mode, const char* dir, const char* nameprefix,const char* pub_key){
    appender_open((TAppenderMode)mode,dir,nameprefix,pub_key);
}

FOUNDATION_EXPORT void cx_logger_appender_flush(){
    appender_flush();
}

FOUNDATION_EXPORT void cx_logger_appender_flush_sync(){
    appender_flush_sync();
}

FOUNDATION_EXPORT void cx_logger_appender_close(){
    appender_close();
}

FOUNDATION_EXPORT void cx_logger_appender_setmode(CXAppenderMode mode){
    appender_setmode((TAppenderMode)mode);
}

FOUNDATION_EXPORT bool cx_logger_appender_get_current_log_path(char* log_path, unsigned int len){
    return appender_get_current_log_path(log_path, len);
}

FOUNDATION_EXPORT bool cx_logger_appender_get_current_log_cache_path(char* logPath, unsigned int len){
    return appender_get_current_log_cache_path(logPath,len);
}

FOUNDATION_EXPORT void cx_logger_appender_set_console_log(bool is_open){
    appender_set_console_log(is_open);
}

FOUNDATION_EXPORT void cx_logger_appender_set_max_alive_duration(long max_time){
     appender_set_max_alive_duration(max_time);
}

FOUNDATION_EXPORT void cx_logger_appender_set_max_file_size(uint64_t max_byte_size){
    appender_set_max_file_size(max_byte_size);
}

FOUNDATION_EXPORT NSArray<NSString*> *cx_logger_appender_getfilepath_from_timespan(int timespan, const char* prefix){
    std::vector<std::string> strVec(2);
    bool success = appender_getfilepath_from_timespan(timespan, prefix, strVec);
    if (!success) {
        return nil;
    }
    NSMutableArray<NSString *> *strArr = [NSMutableArray array];
    for (auto it = strVec.begin(); it != strVec.end(); it ++) {
        NSString *toAppend = [NSString stringWithUTF8String:(*it).c_str()];
        if(toAppend.length > 0){
            [strArr addObject:toAppend];
        }
    }
    return strArr;
}




@implementation CXLogHelper

+ (void)logWithLevel:(CXLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char *)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName message:(NSString *)message {
    if (message == nil || ![message isKindOfClass:NSString.class]) {
        return;
    }
    NSString *module = [NSString stringWithFormat:@"模块名：%@",moduleName];
    NSString *file = [NSString stringWithFormat:@"文件名：%s",fileName];
    NSString *func = [NSString stringWithFormat:@"函数名：%s",funcName];
    
    XLoggerInfo info;
    info.level = (TLogLevel)logLevel;
    info.tag = [module UTF8String];
    info.filename = [file UTF8String];
    info.func_name = [func UTF8String];
    info.line = lineNumber;
    gettimeofday(&info.timeval, NULL);
    info.tid = (uintptr_t)[NSThread currentThread];
    info.maintid = (uintptr_t)[NSThread mainThread];
    info.pid = 0;
    NSString *configString = [NSString stringWithFormat:@"log:%@\n",message];
    
    xlogger_Write(&info, configString.UTF8String);
}

+ (void)logWithLevel:(CXLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName format:(NSString *)format, ... {
    if ([self shouldLog:logLevel]) {
        va_list argList;
        va_start(argList, format);
        NSString* message = [[NSString alloc] initWithFormat:format arguments:argList];
        [self logWithLevel:logLevel moduleName:moduleName fileName:fileName lineNumber:lineNumber funcName:funcName message:message];
        va_end(argList);
    }
}

+ (BOOL)shouldLog:(CXLogLevel)level {
    if (level >= (CXLogLevel)xlogger_Level()) {
        return YES;
    }
    return NO;
}

@end

