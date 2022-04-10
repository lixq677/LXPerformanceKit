//
//  LXSystemUtil.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import "LXSystemUtil.h"
#import <sys/sysctl.h>

@implementation LXSystemUtil

+ (uint64_t)getSysCtl64WithSpecifier:(char *)specifier{
    size_t size = -1;
    uint64_t val = 0;
    
    if (!specifier){
        return -1;
    }
    if (strlen(specifier) == 0){
        return -1;
    }
    
    if (sysctlbyname(specifier, NULL, &size, NULL, 0) == -1){
        return -1;
    }
    
    if (size == -1){
        return -1;
    }
    
    if (sysctlbyname(specifier, &val, &size, NULL, 0) == -1){
        return -1;
    }
    
    return val;
}


@end
