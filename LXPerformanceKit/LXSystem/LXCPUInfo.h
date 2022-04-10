//
//  LXCPUInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXCPUInfo : NSObject
@property (nonatomic, assign) NSUInteger   activeCPUCount;
@property (nonatomic, assign) NSUInteger   physicalCPUCount;
@property (nonatomic, assign) NSUInteger   physicalCPUMaxCount;
@property (nonatomic, assign) NSUInteger   logicalCPUCount;
@property (nonatomic, assign) NSUInteger   logicalCPUMaxCount;
@property (nonatomic, assign) NSUInteger   l1DCache;
@property (nonatomic, assign) NSUInteger   l1ICache;
@property (nonatomic, assign) NSUInteger   l2Cache;
@property (nonatomic, copy)   NSString     *cpuType;
@property (nonatomic, copy)   NSString     *cpuSubtype;
@property (nonatomic, copy)   NSString     *endianess;

//当前使用百分比
- (float)usage;


@end

NS_ASSUME_NONNULL_END
