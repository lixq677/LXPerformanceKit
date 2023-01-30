//
//  LXCrashInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXCrash : NSObject<NSCoding>

@property (nonatomic, copy) NSString *uuid; //唯一性：避免同一份崩溃报告多次写入大数据

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSDictionary *userInfo;
@property (nonatomic, copy) NSString  *crashType; //异常类型
@property (nonatomic, copy) NSNumber *crashThread;//崩溃线程号
@property (nonatomic, copy) NSString *baseInfo; //堆栈信息
@property (nonatomic, copy) NSString *crashStack; //堆栈信息
@property (nonatomic, copy) NSString *stacks;//所有线程的堆栈；
//@property (nonatomic, copy) NSString *sysLog; //系统日志

@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *app; //应用名
@property (nonatomic, copy) NSString *version; //APP 版本

//系统信息
@property (nonatomic, copy) NSString *sysVersion;
@property (nonatomic, copy) NSString *machineName;

@property (nonatomic, copy) NSString *diskTotal; //总磁盘空间
@property (nonatomic, copy) NSString *diskUsage; //百分比
@property (nonatomic, copy) NSString *memTotal; //内存大小
@property (nonatomic, copy) NSString *memUsage; //内存百分比

- (instancetype)initWithException:(NSException *)exception stackTrace:(NSString *)stack symbol:(NSString *)symbol;

- (instancetype)initWithName:(const char*)name reason:(const char *)reason crashStack:(NSArray *)stack symbol:(nullable const char*)symbol;

- (instancetype)initWithName:(NSString *)name reason:(NSString *)reason;

- (NSDictionary *)toDictionary;

/**
 过滤掉一些不必要的key值

 @param keys except keys
 @return key-value
 */
- (NSDictionary *)toDictionaryExcept:(NSArray *)keys;


@end

NS_ASSUME_NONNULL_END
