//
//  LXLagInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(int,LXLagDegree) {
    LXLagDegreeSlight   =   0,//轻微卡顿
    LXLagDegreeMedium   =   1,//中等卡顿
    LXLagDegreeSerious  =   2,//严重卡顿
};

@interface LXLag : NSObject<NSCoding>

@property (nonatomic, copy) NSString *uuid;

@property (nonatomic, copy) NSNumber *createTime;

@property (nonatomic, copy) NSString *stack; //堆栈信息

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

@property (nonatomic,assign)LXLagDegree lagDegree;

@end

NS_ASSUME_NONNULL_END
