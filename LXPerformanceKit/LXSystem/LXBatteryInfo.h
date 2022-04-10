//
//  LXBatteryInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//电池信息
@interface LXBatteryInfo : NSObject

/*当前电量*/
+ (float)batteryLevel;

///是否正在充电
+ (BOOL)isCharging;


/// 电池电量是否满充
+ (BOOL)isFullyCharged;

@end

NS_ASSUME_NONNULL_END
