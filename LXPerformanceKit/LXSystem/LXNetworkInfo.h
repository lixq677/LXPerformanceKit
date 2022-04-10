//
//  LXNetworkInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXNetworkInfo : NSObject

// Get Current IP Address
+ (nullable NSString *)currentIPAddress;

// Get Current MAC Address
+ (nullable NSString *)currentMACAddress;

// Get the External IP Address
+ (nullable NSString *)externalIPAddress;

// Get Cell IP Address
+ (nullable NSString *)cellIPAddress;

// Get Cell IPv6 Address
+ (nullable NSString *)cellIPv6Address;

// Get Cell MAC Address
+ (nullable NSString *)cellMACAddress;

// Get Cell Netmask Address
+ (nullable NSString *)cellNetmaskAddress;

// Get Cell Broadcast Address
+ (nullable NSString *)cellBroadcastAddress;

// Get WiFi IP Address
+ (nullable NSString *)wiFiIPAddress;

// Get WiFi IPv6 Address
+ (nullable NSString *)wiFiIPv6Address;

// Get WiFi MAC Address
+ (nullable NSString *)wiFiMACAddress;

// Get WiFi Netmask Address
+ (nullable NSString *)wiFiNetmaskAddress;

// Get WiFi Broadcast Address
+ (nullable NSString *)wiFiBroadcastAddress;

// Get WiFi Router Address
+ (nullable NSString *)wiFiRouterAddress;

// Connected to WiFi?
+ (BOOL)connectedToWiFi;

// Connected to Cellular Network?
+ (BOOL)connectedToCellNetwork;

+ (nullable NSString *)fetchHttpProxy;

//当前网络是否使用了VPN
+ (BOOL)connectedByVPN;


@end

NS_ASSUME_NONNULL_END
