//
//  LXDeviceInfo.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import "LXDeviceInfo.h"
#import <UIKit/UIKit.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt",
    "/User/Applications/"
};

@implementation LXDeviceInfo


+ (NSString *)systemName{
    // Get the current system name
    if ([[UIDevice currentDevice] respondsToSelector:@selector(systemName)]) {
        // Make a string for the system name
        NSString *systemName = [[UIDevice currentDevice] systemName];
        // Set the output to the system name
        return systemName;
    } else {
        // System name not found
        return nil;
    }
}

+ (NSString *)machine{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}


+ (NSString *)systemVersion{
    // Get the current system version
    if ([[UIDevice currentDevice] respondsToSelector:@selector(systemVersion)]) {
        // Make a string for the system version
        NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
        // Set the output to the system version
        return systemVersion;
    } else {
        // System version not found
        return nil;
    }
}

+ (LXDeviceSize)screenSize{
    // Get the screen width
    LXDeviceSize retSize;
    retSize.width = -1;
    retSize.height = -1;
    @try {
        // Screen bounds
        CGRect ret = [[UIScreen mainScreen] bounds];
        if (ret.size.width>0 && ret.size.height>0) {
            retSize.width = ret.size.width;
            retSize.height = ret.size.height;
        }
    }
    @catch (NSException *exception) {
        // Error
    }
    
    return retSize;
}

+ (NSString *)screenResolutionString{
    NSString *result = @"";
    LXDeviceSize size = [[self class] screenSize];
    if (size.width>0 && size.height>0) {
        float scale = [UIScreen mainScreen].scale;
        
        result = [NSString stringWithFormat:@"%ld*%ld",(long)(size.width*scale),(long)(size.height*scale)];
    }
    
    return result;
}

+ (float)screenBrightness{
    // Get the screen brightness
    @try {
        // Brightness
        float brightness = [UIScreen mainScreen].brightness;
        // Verify validity
        if (brightness < 0.0 || brightness > 1.0) {
            // Invalid brightness
            return -1;
        }
        
        // Successful
        return (brightness * 100);
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}


+ (BOOL)isJailBreak{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;
        }
    }
    return NO;
}

@end
