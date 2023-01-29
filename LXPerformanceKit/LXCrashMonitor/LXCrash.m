//
//  LXCrashInfo.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import "LXCrash.h"
#import <YYModel/YYModel.h>
#import "LXSystem.h"
#import "LXToolsBox.h"

@implementation LXCrash

- (instancetype)init{
    self = [super init];
    if (self) {
        self.uuid = [LXToolsBox createUUID];
        self.sysVersion = [LXDeviceInfo systemVersion];
        self.machineName = [LXDeviceInfo machine];
        
        self.diskTotal = [LXDiskInfo diskSpace];
        self.diskUsage = [LXDiskInfo usedDiskSpace:YES];
        
        self.memTotal = [NSString stringWithFormat:@"%0.2fGB",[LXMemoryInfo totalMemory]/1024];
        self.memUsage = [NSString stringWithFormat:@"%0.2f%%",[LXMemoryInfo usedMemory]];
        
        self.app = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
        self.version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        self.time = [[NSDate date] descriptionWithLocale:[NSLocale currentLocale]];
    }
    
    return self;
}

- (instancetype)initWithException:(NSException *)exception stackTrace:(NSString *)stack symbol:(NSString *)symbol{
    self = [self init];
    if (self) {
        self.name = exception.name;
        if ([self.name length]<=0) {
            self.name = @"Unknown";
        }
        self.reason = exception.reason;
        self.userInfo = exception.userInfo;
        
        self.symbol = symbol.length > 0 ? symbol : @"none";
        
        NSString *trace = nil;//[NSString stringWithFormat:@"%@",exception];
        if (trace.length <=0) {
            trace = [NSString stringWithFormat:@"name: %@\nreason: %@\nstack: %@\ncallSymbols:%@",
                           exception.name,exception.reason,stack
                           ,exception.callStackSymbols
                           /*,exception.callStackReturnAddresses*/];
        }
        
        self.stack = trace;
    }
    
    return self;
}

- (instancetype)initWithName:(const char *)name reason:(const char *)reason stack:(NSArray *)stack symbol:(const char *)symbol{
    self = [self init];
    if (self) {
        if (name) {
            self.name = [NSString stringWithUTF8String:name];
        }else{
            self.name = @"Unknown";
        }
        if (reason) {
            self.reason = [NSString stringWithUTF8String:reason];
        }else if(symbol){
            self.reason = [NSString stringWithUTF8String:symbol];
        }
        
        NSString *t_symbol = nil;
        if(symbol){
            t_symbol = [NSString stringWithCString:symbol encoding:NSUTF8StringEncoding];
        }
        
        self.symbol = t_symbol.length > 0 ? t_symbol : @"none";
        
        if ([stack count]>0) {
            self.stack = [stack componentsJoinedByString:@"\n"];
        }
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name reason:(NSString *)reason{
    self = [super init];
    if (self) {
        self.name = name;
        self.reason = reason;
    }
    
    return self;
}


- (NSDictionary *)toDictionary{
    return [self yy_modelToJSONObject];
}

- (NSDictionary *)toDictionaryExcept:(NSArray *)keys{
    NSMutableDictionary *results = [NSMutableDictionary dictionaryWithDictionary:[self toDictionary]];
    for (NSString *key in keys) {
        [results removeObjectForKey:key];
    }
    
    return results;
}

//+ (NSString *)PASSWORD{
//    return @"lx_crashInfo_simple";
//}

+ (NSArray *)lx_unionPrimaryKeys{
    return @[@"uuid"];
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
