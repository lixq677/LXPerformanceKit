//
//  CXLogger.m
//  CXLog
//
//  Created by 李笑清 on 2020/7/10.
//  Copyright © 2020 李笑清. All rights reserved.
//

#import "CXLogger.h"
#import "CXLogHelper.h"
#import <sys/xattr.h>
@implementation CXLogger

+ (void)initSettingLogPath:(NSString *)logPath attrName:(NSString *)attrName{
    if ([attrName length] == 0) {
        NSAssert(NO, @"attrName不能为空");
    }
    u_int8_t attrValue = 1;
    setxattr([logPath UTF8String], [attrName UTF8String], &attrValue, sizeof(attrValue), 0, 0);
    
}

+ (CXLogLevel)level{
    return cx_logger_Level();
}

+ (void)setLevel:(CXLogLevel)level{
    cx_logger_SetLevel(level);
}

+ (void)setCacheDuration:(long)duration{
    cx_logger_appender_set_max_alive_duration(duration);
}

+ (void)setFileMaxSize:(uint64_t)maxByteSize{
    cx_logger_appender_set_max_file_size(maxByteSize);
}

+ (int)isEnabledForLevel:(CXLogLevel)level{
    return cx_logger_IsEnabledFor(level);
}

+ (void)open:(CXAppenderMode)mode dir:(NSString *)dir nameprefix:(NSString *)nameprefix pubKey:(NSString *)pubKey{
    return cx_logger_appender_open(mode, [dir UTF8String], [nameprefix UTF8String], [pubKey UTF8String]);
}

+ (NSString*)getCurrentLogDirectory{
    char log_path[2048] = {0};
    bool havePath = cx_logger_appender_get_current_log_path(log_path,sizeof(log_path));
    if (havePath) {
        return [NSString stringWithUTF8String:log_path];
    }
    return nil;
}

+ (NSArray<NSString*> *)getAllFilePath{
    NSString *logDir = [CXLogger getCurrentLogDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [manager enumeratorAtPath:logDir];
    NSMutableArray<NSString*> *files = [NSMutableArray arrayWithCapacity:42];
    NSString *filename = nil;
    while (filename = [dirEnum nextObject]) {
        if ([[filename pathExtension] isEqualToString:@"xlog"]) {
            [files addObject: filename];
        }
    }
    return files;
}

+ (NSArray<NSString*> *)getFilePathFromDaysAgo:(uint32_t)fromDaysAgo toDaysAgo:(uint32_t)toDaysAgo namePrefix:(NSString*)namePrefix{
    if (fromDaysAgo < toDaysAgo) {
        return nil;
    }
    NSMutableArray<NSString*> *files = [NSMutableArray array];
    for (uint32_t daysAgo = fromDaysAgo; daysAgo >= toDaysAgo; --daysAgo) {
        NSArray<NSString*> *array = cx_logger_appender_getfilepath_from_timespan(daysAgo, [namePrefix UTF8String]);
        [files addObjectsFromArray:array];
    }
    return [NSArray arrayWithArray:files];
}

+ (NSArray<NSString*>*)getFilePathDaysAgo:(uint32_t)daysAgo namePrefix:(NSString*)namePrefix{
    return cx_logger_appender_getfilepath_from_timespan(daysAgo, [namePrefix UTF8String]);
}

+ (void)setConsole:(BOOL)open;{
    cx_logger_appender_set_console_log(open);
}



+ (void)flush{
    cx_logger_appender_flush();
}
+ (void)syncFlush{
    cx_logger_appender_flush_sync();
}
+ (void)close{
    cx_logger_appender_close();
}

+ (void)setMode:(CXAppenderMode)mode{
    cx_logger_appender_setmode(mode);
}


@end


FOUNDATION_EXPORT void CXLogInternal(CXLogLevel level,NSString *module, const char *file, int line,const char *func, NSString *prefix, NSString *format,...){
    do {
        if ([CXLogHelper shouldLog:level]) {
            va_list argList;
            va_start(argList, format);
            NSString *msg = [[NSString alloc] initWithFormat:format arguments:argList];
            va_end(argList);
            NSString *aMessage = [NSString stringWithFormat:@"%@%@", prefix, msg, nil];
            NSString *m = module ?:@"";
            if (![m isKindOfClass:NSString.class])return;
            [CXLogHelper logWithLevel:level moduleName:m fileName:file lineNumber:line funcName:func message:aMessage];
        }
    } while(0);
}


