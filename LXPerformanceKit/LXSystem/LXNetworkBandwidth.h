//
//  LXNetworkBandwidth.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXNetworkBandwidth : NSObject

@property (nonatomic, copy)   NSString  *interface;
@property (nonatomic, assign) NSTimeInterval  timestamp;

//@property (nonatomic, assign) float     sent;
@property (nonatomic, assign) uint64_t  totalWiFiSent;
@property (nonatomic, assign) uint64_t  totalWWANSent;
//@property (nonatomic, assign) float     received;
@property (nonatomic, assign) uint64_t  totalWiFiReceived;
@property (nonatomic, assign) uint64_t  totalWWANReceived;

- (NSString*)readableCurrentInterface;

@end

NS_ASSUME_NONNULL_END
