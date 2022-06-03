//
//  CXLogger.h
//  CXLog
//
//  Created by 李笑清 on 2020/7/10.
//  Copyright © 2020 李笑清. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CXLogDeclare.h"

#define __FILENAME__ (strrchr(__FILE__,'/')+1)

NS_ASSUME_NONNULL_BEGIN

@interface CXLogger : NSObject


/// 初始化日志路径和名字
/// @param logPath <#logPath description#>
/// @param attrName <#attrName description#>
+ (void)initSettingLogPath:(NSString *)logPath attrName:(NSString *)attrName;

/// 获取日志级别
+ (CXLogLevel)level;


/// 设置日志级别
/// @param level <#level description#>
+ (void)setLevel:(CXLogLevel)level;


/// 设置单个文件缓存时间,默认10天，最小1天
/// @param duration 时间，单位 秒
+ (void)setCacheDuration:(long)duration;


/// 设置单个文件最大是多小
/// @param maxByteSize <#maxByteSize description#>
+ (void)setFileMaxSize:(uint64_t)maxByteSize;

+ (int)isEnabledForLevel:(CXLogLevel)level;


/// 初始化日志需要调用的接口
/// @param mode 日志打印模式
/// @param dir 日志写入目录,
/// @param nameprefix 日志文件名前缀,文件名有 前缀+日期+后缀组成
/// @param pubKey 加密所用的 pubKey
+ (void)open:(CXAppenderMode)mode dir:(NSString*)dir nameprefix:(NSString*)nameprefix pubKey:(nullable NSString *)pubKey;


/// 获取当前日志的目录
+ (NSString*)getCurrentLogDirectory;


/// 获取所有日志路径
+ (NSArray<NSString*> *)getAllFilePath;


/// 获取fromDaysAgo天前到toDaysAgo之间的日志文件路径,只提供路径，不确认文件是否存在
/// @param fromDaysAgo <#fromDaysAgo description#>
/// @param toDaysAgo <#toDaysAgo description#>
/// @param namePrefix <#namePrefix description#>
+ (NSArray<NSString*>*)getFilePathFromDaysAgo:(uint32_t)fromDaysAgo toDaysAgo:(uint32_t)toDaysAgo namePrefix:(NSString*)namePrefix;


/// 获取第daysAgo天的日志信息,只提供路径，不确认文件是否存在
/// @param daysAgo <#daysAgo description#>
/// @param namePrefix <#namePrefix description#>
+ (NSArray<NSString*>*)getFilePathDaysAgo:(uint32_t)daysAgo namePrefix:(NSString*)namePrefix;

+ (void)flush;
+ (void)syncFlush;
+ (void)close;
+ (void)setMode:(CXAppenderMode)mode;



/// 设置日志是否输出到控制台
/// @param open <#open description#>
+ (void)setConsole:(BOOL)open;

@end

FOUNDATION_EXPORT void CXLogInternal(CXLogLevel level,NSString * _Nullable module,const char *file, int line, const char *func, NSString * _Nullable prefix, NSString *format,...);

///**
// *  Module Logging
// */
#define CX_LOG_ERROR(module, format, ...) CXLogInternal(CXLogLevelError, module, __FILENAME__, __LINE__, __FUNCTION__, @"Error:", format, ##__VA_ARGS__)


#define CX_LOG_WARNING(module, format, ...) CXLogInternal(CXLogLevelWarn, module, __FILENAME__, __LINE__, __FUNCTION__, @"Warning:", format, ##__VA_ARGS__)

#define CX_LOG_INFO(module, format, ...) CXLogInternal(CXLogLevelInfo, module, __FILENAME__, __LINE__, __FUNCTION__, @"Info:", format, ##__VA_ARGS__)

#define CX_LOG_DEBUG(module, format, ...) CXLogInternal(CXLogLevelDebug, module, __FILENAME__, __LINE__, __FUNCTION__, @"Debug:", format, ##__VA_ARGS__)

#define CXLogError(format, ...) CX_LOG_ERROR(nil, format,  ##__VA_ARGS__)

#define CXLogWarning(format, ...) CX_LOG_WARNING(nil, format,  ##__VA_ARGS__)

#define CXLogInfo(format, ...) CX_LOG_INFO(nil, format,  ##__VA_ARGS__)

#define CXLogDebug(format, ...) CX_LOG_DEBUG(nil, format,  ##__VA_ARGS__)

#define CXLog(format, ...) CXLogInfo(format,  ##__VA_ARGS__)



NS_ASSUME_NONNULL_END
