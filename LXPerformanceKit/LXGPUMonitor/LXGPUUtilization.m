//
//  LXGPUUtilization.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import "LXGPUUtilization.h"
#import "LXIOKit.h"

const char *kIOServicePlane = "IOService";
#define GPU_UTILI_KEY(key, value)   static NSString * const GPU ## key ##Key = @#value;

GPU_UTILI_KEY(DeviceUtilization, Device Utilization %)
GPU_UTILI_KEY(RendererUtilization, Renderer Utilization %)
GPU_UTILI_KEY(TilerUtilization, Tiler Utilization %)
GPU_UTILI_KEY(HardwareWaitTime, hardwareWaitTime)
GPU_UTILI_KEY(FinishGLWaitTime, finishGLWaitTime)
GPU_UTILI_KEY(FreeToAllocGPUAddressWaitTime, freeToAllocGPUAddressWaitTime)
GPU_UTILI_KEY(ContextGLCount, contextGLCount)
GPU_UTILI_KEY(RenderCount, CommandBufferRenderCount)
GPU_UTILI_KEY(RecoveryCount, recoveryCount)
GPU_UTILI_KEY(TextureCount, textureCount)

@implementation LXGPUUtilization{
    NSDictionary        * _utilizationInfo;
}

+ (NSDictionary *)utilizeDictionary{
    NSDictionary *dictionary = nil;
    io_iterator_t iterator;
#if TARGET_IPHONE_SIMULATOR
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceNameMatching("IntelAccelerator"), &iterator) == kIOReturnSuccess) {
        for (io_registry_entry_t regEntry = IOIteratorNext(iterator); regEntry; regEntry = IOIteratorNext(iterator)) {
            CFMutableDictionaryRef serviceDictionary;
            if (IORegistryEntryCreateCFProperties(regEntry, &serviceDictionary, kCFAllocatorDefault, kNilOptions) != kIOReturnSuccess) {
                IOObjectRelease(regEntry);
                continue;
            }
            dictionary = ((__bridge NSDictionary *)serviceDictionary)[@"PerformanceStatistics"];
            CFRelease(serviceDictionary);
            IOObjectRelease(regEntry);
            break;
        }
        IOObjectRelease(iterator);
    }
#elif TARGET_OS_IOS
    if (IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceNameMatching("sgx"), &iterator) == kIOReturnSuccess) {
        for (io_registry_entry_t regEntry = IOIteratorNext(iterator); regEntry; regEntry = IOIteratorNext(iterator)) {
            io_iterator_t innerIterator;
            if (IORegistryEntryGetChildIterator(regEntry, kIOServicePlane, &innerIterator) == kIOReturnSuccess) {
                for (io_registry_entry_t gpuEntry = IOIteratorNext(innerIterator); gpuEntry ; gpuEntry = IOIteratorNext(innerIterator)) {
                    CFMutableDictionaryRef serviceDictionary;
                    if (IORegistryEntryCreateCFProperties(gpuEntry, &serviceDictionary, kCFAllocatorDefault, kNilOptions) != kIOReturnSuccess) {
                        IOObjectRelease(gpuEntry);
                        continue;
                    }else {
                        dictionary = ((__bridge NSDictionary *)serviceDictionary)[@"PerformanceStatistics"];
                        CFRelease(serviceDictionary);
                        IOObjectRelease(gpuEntry);
                        break;
                    }
                }
                IOObjectRelease(innerIterator);
                IOObjectRelease(regEntry);
                break;
            }
            IOObjectRelease(regEntry);
        }
        IOObjectRelease(iterator);
    }
#endif
    return dictionary;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _utilizationInfo = [LXGPUUtilization utilizeDictionary];
    }
    return self;
}

+ (LXGPUUtilization *)current{
    return [[self alloc] init];
}

- (float)gpuUsage{
    return [_utilizationInfo[GPUDeviceUtilizationKey] floatValue];
}

+ (float)gpuUsage{
    return [[self utilizeDictionary][GPUDeviceUtilizationKey] floatValue];
}



- (NSInteger)deviceUtilization{
    return [_utilizationInfo[GPUDeviceUtilizationKey] integerValue];
}

- (NSInteger)rendererUtilization{
    return [_utilizationInfo[GPURendererUtilizationKey] integerValue];
}

- (NSInteger)tilerUtilization{
    return [_utilizationInfo[GPUTilerUtilizationKey] integerValue];
}

- (int64_t)hardwareWaitTime{
    return [_utilizationInfo[GPUHardwareWaitTimeKey] longLongValue];
}

- (int64_t)finishGLWaitTime{
    return [_utilizationInfo[GPUFinishGLWaitTimeKey] longLongValue];
}

- (int64_t)freeToAllocGPUAddressWaitTime{
    return [_utilizationInfo[GPUFreeToAllocGPUAddressWaitTimeKey] longLongValue];
}

- (NSInteger)contextGLCount{
    return [_utilizationInfo[GPUContextGLCountKey] integerValue];
}

- (NSInteger)renderCount{
    return [_utilizationInfo[GPURenderCountKey] integerValue];
}

- (NSInteger)recoveryCount{
    return [_utilizationInfo[GPURecoveryCountKey] integerValue];
}

- (NSInteger)textureCount{
    return [_utilizationInfo[GPUTextureCountKey] integerValue];
}




@end
