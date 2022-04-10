//
//  LXCPUInfo.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import "LXCPUInfo.h"
#import <sys/sysctl.h>
#import <sys/types.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <mach/mach.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>
#import "LXSystemUtil.h"

@implementation LXCPUInfo
- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.activeCPUCount = [LXSystemUtil getSysCtl64WithSpecifier:"hw.activecpu"];
        self.physicalCPUCount = [LXSystemUtil getSysCtl64WithSpecifier:"hw.physicalcpu"];
        self.physicalCPUMaxCount = [LXSystemUtil getSysCtl64WithSpecifier:"hw.physicalcpu_max"];
        self.logicalCPUCount = [LXSystemUtil getSysCtl64WithSpecifier:"hw.logicalcpu"];
        self.logicalCPUMaxCount = [LXSystemUtil getSysCtl64WithSpecifier:"hw.logicalcpu_max"];
        
        self.l1ICache = [self __l1ICache];
        self.l1DCache = [self __l1DCache];
        self.l2Cache = [self __l2Cache];
        
        self.cpuType = [self __cpuType];
        self.cpuSubtype = [self __cpuSubType];
        self.endianess = [self __endianess];
    }
    
    return self;
}

#pragma mark - private methods

- (NSUInteger)__l1DCache{
    
    NSInteger val = (NSInteger)[LXSystemUtil getSysCtl64WithSpecifier:"hw.l1dcachesize"];
    if (val<0) {
        val = 0;
    }
    
    return val;
}

- (NSUInteger)__l1ICache{
    NSInteger val = (NSInteger)[LXSystemUtil getSysCtl64WithSpecifier:"hw.l1icachesize"];
    if (val<0) {
        val = 0;
    }
    
    return val;
}

- (NSUInteger)__l2Cache{
    NSInteger val = (NSInteger)[LXSystemUtil getSysCtl64WithSpecifier:"hw.l2cachesize"];
    if (val<0) {
        val = 0;
    }
    
    return val;
}

- (NSString *)__cpuType{
    cpu_type_t cpuType = (cpu_type_t)[LXSystemUtil getSysCtl64WithSpecifier:"hw.cputype"];
    
    switch (cpuType) {
        case CPU_TYPE_ANY:      return @"Unknown";          break;
        case CPU_TYPE_ARM:      return @"ARM";              break;
        case CPU_TYPE_ARM64:    return @"ARM64";            break;
        case CPU_TYPE_HPPA:     return @"HP PA-RISC";       break;
        case CPU_TYPE_I386:     return @"Intel i386";       break;
        case CPU_TYPE_X86_64:   return @"Intel X86_64";     break;
        case CPU_TYPE_I860:     return @"Intel i860";       break;
        case CPU_TYPE_MC680x0:  return @"Motorola 680x0";   break;
        case CPU_TYPE_MC88000:  return @"Motorola 88000";   break;
        case CPU_TYPE_MC98000:  return @"Motorola 98000";   break;
        case CPU_TYPE_POWERPC:  return @"Power PC";         break;
        case CPU_TYPE_POWERPC64:return @"Power PC64";       break;
        case CPU_TYPE_SPARC:    return @"SPARC";            break;
        default:                return [NSString stringWithFormat:@"%ld",(long)cpuType];          break;
    }
}

- (NSString *)__cpuSubType{
    cpu_subtype_t cpuSubtype = (cpu_subtype_t)[LXSystemUtil getSysCtl64WithSpecifier:"hw.cpusubtype"];
    switch (cpuSubtype) {
        case CPU_SUBTYPE_ARM_ALL:   return @"ARM";          break;
        case CPU_SUBTYPE_ARM_V4T:   return @"ARMv4T";       break;
        case CPU_SUBTYPE_ARM_V5TEJ: return @"ARMv5TEJ";     break;
        case CPU_SUBTYPE_ARM_V6:    return @"ARMv6";        break;
        case CPU_SUBTYPE_ARM_V7:    return @"ARMv7";        break;
        case CPU_SUBTYPE_ARM_V7F:   return @"ARMv7F";       break;
        case CPU_SUBTYPE_ARM_V7K:   return @"ARMv7K";       break;
        case CPU_SUBTYPE_ARM_V7S:   return @"ARMv7S";       break;
        case CPU_SUBTYPE_ARM_V8M:   return @"ARMv8M";       break;
 //       case CPU_SUBTYPE_ARM64_V8:  return @"ARM64 V8";     break;
        case CPU_SUBTYPE_ARM64E:    return @"ARM64E";       break;
#if !(TARGET_IPHONE_SIMULATOR) // Simulator headers don't include such subtype.
        case CPU_SUBTYPE_ARM64_V8:  return @"ARM64 V8";        break;
#endif
        default:                    return [NSString stringWithFormat:@"%ld",(long)cpuSubtype];      break;
    }
}

- (NSString *)__endianess{
    NSUInteger value = (NSUInteger)[LXSystemUtil getSysCtl64WithSpecifier:"hw.byteorder"];
    
    if (value == 1234){
        return @"Little endian";
    }else if (value == 4321){
        return @"Big endian";
    }else{
        return @"-";
    }
}

- (float)usage{
    kern_return_t kr;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    thread_basic_info_t basic_info_th;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    long  total_sec  = 0;
    long  total_usec = 0;
    float total_cpu  = 0;
    int j;
    
    for (j = 0; j < thread_count; j++){
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        basic_info_th = (thread_basic_info_t)thinfo;
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            total_sec  = total_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            total_usec = total_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            total_cpu = total_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    }
    //fixed thread_list leak
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return total_cpu;
}


@end
