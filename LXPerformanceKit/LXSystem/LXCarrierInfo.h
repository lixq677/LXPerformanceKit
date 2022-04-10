//
//  LXCarrierInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//运营商信息
@interface LXCarrierInfo : NSObject

// Carrier Name
+ (nullable NSString *)carrierName;

// Carrier Country
+ (nullable NSString *)carrierCountry;

// Carrier Mobile Country Code
+ (nullable NSString *)carrierMobileCountryCode;

// Carrier ISO Country Code
+ (nullable NSString *)carrierISOCountryCode;

// Carrier Mobile Network Code
+ (nullable NSString *)carrierMobileNetworkCode;

// Carrier Allows VOIP
+ (BOOL)carrierAllowsVOIP;


@end

NS_ASSUME_NONNULL_END
