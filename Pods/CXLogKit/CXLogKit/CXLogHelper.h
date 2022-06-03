//
//  CXLoggerBase.h
//  CXLog
//
//  Created by 李笑清 on 2020/7/10.
//  Copyright © 2020 李笑清. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CXLogDeclare.h"

NS_ASSUME_NONNULL_BEGIN


/// 获取日志级别
FOUNDATION_EXPORT  CXLogLevel cx_logger_Level(void);


/// 设置日志级别
/// @param level <#level description#>
FOUNDATION_EXPORT void cx_logger_SetLevel(CXLogLevel level);


FOUNDATION_EXPORT int  cx_logger_IsEnabledFor(CXLogLevel level);


/// 初始化日志需要调用的接口
/// @param mode 日志打印模式
/// @param dir 日志写入目录,
/// @param nameprefix 日志文件名前缀
/// @param pub_key 加密所用的 pub_key
FOUNDATION_EXPORT void cx_logger_appender_open(CXAppenderMode mode, const char* dir, const char* nameprefix,const char* pub_key);


/* 将缓存的日志写入文件
 * 当日志写入模式为异步时，调用接口会把内存中的日志写入到文件。appender_flush_sync 为同步 flush，flush 结束后才会返回。 appender_flush 为异步 flush，不等待 flush 结束就返回。
 */
FOUNDATION_EXPORT void cx_logger_appender_flush(void);
FOUNDATION_EXPORT void cx_logger_appender_flush_sync(void);

//关闭日志，程序退出时使用
FOUNDATION_EXPORT void cx_logger_appender_close(void);


/// 设置日志默认缓存多少天，默认是10天，最少时间是1天，单位 秒, 1天:24*60*60
/// @param max_time <#max_time description#>
FOUNDATION_EXPORT void cx_logger_appender_set_max_alive_duration(long max_time);


/// 设置单个文件大小
/// @param max_byte_size <#max_byte_size description#>
FOUNDATION_EXPORT void cx_logger_appender_set_max_file_size(uint64_t max_byte_size);


/// 设置日志模式
/// @param mode <#mode description#>
FOUNDATION_EXPORT void cx_logger_appender_setmode(CXAppenderMode mode);


/// 获取当前日志文件相关信息
/// @param log_path 路径，
/// @param len 长度
FOUNDATION_EXPORT bool cx_logger_appender_get_current_log_path(char* log_path, unsigned int len);

/* 获取文件路径
 */
FOUNDATION_EXPORT NSArray<NSString*> *cx_logger_appender_getfilepath_from_timespan(int timespan, const char* prefix);

/*
 *  获取日志缓存目录
 */
FOUNDATION_EXPORT bool cx_logger_appender_get_current_log_cache_path(char* logPath, unsigned int len);

/*
*  是否会把日志打印到控制台中， 默认不打印。
*  is_open : true 为打印，false为不打印。
*/
FOUNDATION_EXPORT void cx_logger_appender_set_console_log(bool is_open);



@interface CXLogHelper : NSObject

+ (void)logWithLevel:(CXLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName message:(NSString *)message;

+ (void)logWithLevel:(CXLogLevel)logLevel moduleName:(NSString *)moduleName fileName:(const char*)fileName lineNumber:(int)lineNumber funcName:(const char*)funcName format:(NSString *)format, ... ;

+ (BOOL)shouldLog:(CXLogLevel)level;

@end


NS_ASSUME_NONNULL_END
