//
//  LXDiskInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXDiskInfo : NSObject

// Total Disk Space
+ (nullable NSString *)diskSpace;

// Total Free Disk Space
+ (nullable NSString *)freeDiskSpace:(BOOL)inPercent;

// Total Used Disk Space
+ (nullable NSString *)usedDiskSpace:(BOOL)inPercent;

// Get the total disk space in long format
+ (long long)longDiskSpace;

// Get the total free disk space in long format
+ (long long)longFreeDiskSpace;


@end

NS_ASSUME_NONNULL_END
