//
//  LXDeviceInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

struct LXDeviceSize {
    float width;
    float height;
};
typedef struct LXDeviceSize LXDeviceSize;

@interface LXDeviceInfo : NSObject

+ (NSString *)machine;

// System Name
+ (nullable NSString *)systemName;

// System Version
+ (nullable NSString *)systemVersion;

+ (LXDeviceSize)screenSize;
+ (nullable NSString *)screenResolutionString; //320*480、640*960...

+ (float)screenBrightness;

+ (BOOL)isJailBreak;
@end

NS_ASSUME_NONNULL_END
