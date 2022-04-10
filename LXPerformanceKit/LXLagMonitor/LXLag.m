//
//  LXLagInfo.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import "LXLag.h"
#import <YYModel/YYModel.h>
#import "LXPTools.h"
#import <YYCache/YYCache.h>
#include <mach-o/dyld.h>
#import <execinfo.h>
#import "LXBacktraceLogger.h"
#import "LXDiskInfo.h"
#import "LXDeviceInfo.h"
#import "LXMemoryInfo.h"


@implementation LXLag

- (instancetype)init{
    self = [super init];
    if (self) {
        self.uuid = [LXPTools createUUID];
        self.createTime = @([[NSDate date] timeIntervalSince1970]);
        self.sysVersion = [LXDeviceInfo systemVersion];
        self.machineName = [LXDeviceInfo machine];
        
        self.diskTotal = [LXDiskInfo diskSpace];
        self.diskUsage = [LXDiskInfo usedDiskSpace:YES];
        
        self.memTotal = [NSString stringWithFormat:@"%0.2fGB",[LXMemoryInfo totalMemory]/1024];
        self.memUsage = [NSString stringWithFormat:@"%0.2f%%",[LXMemoryInfo usedMemory:YES]];
        
        self.app = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        self.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    
    return self;
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        return [self yy_modelInitWithCoder:decoder];
    }
    
    return nil;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [self yy_modelEncodeWithCoder:coder];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    return [self yy_modelCopy];
}

- (NSUInteger)hash {
    return [self yy_modelHash];
}

- (BOOL)isEqual:(id)object {
    return [self yy_modelIsEqual:object];
}

- (NSString *)description {
    return [self yy_modelDescription];
}

@end
