//
//  LXGPUUtilization.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXGPUUtilization : NSObject

+ (LXGPUUtilization *)current;

@property (nonatomic, readonly) NSInteger deviceUtilization;

@property (nonatomic, readonly) NSInteger rendererUtilization;

@property (nonatomic, readonly) NSInteger tilerUtilization;

@property (nonatomic, readonly) int64_t hardwareWaitTime;

@property (nonatomic, readonly) int64_t finishGLWaitTime;

@property (nonatomic, readonly) int64_t freeToAllocGPUAddressWaitTime;

@property (nonatomic, readonly) NSInteger contextGLCount;

@property (nonatomic, readonly) NSInteger renderCount;

@property (nonatomic, readonly) NSInteger recoveryCount;

@property (nonatomic, readonly) NSInteger textureCount;

@property (nonatomic, readonly) float gpuUsage;

#if __has_feature(objc_class_property)
@property (nonatomic, class, readonly) float gpuUsage;
#else
+ (float)gpuUsage;
#endif

@end

NS_ASSUME_NONNULL_END
