//
//  LXMemoryInfo.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import "LXMemoryInfo.h"
#import <sys/stat.h>
#import <mach/mach.h>

@implementation LXMemoryInfo

- (double)totalMemory{
    return [LXMemoryInfo totalMemory];
}

- (double)usedMemory{
    return [LXMemoryInfo usedMemory];
}

- (double)appPhysFootprintMemory{
    return [LXMemoryInfo appPhysFootprintMemory];
}


- (double)appUsedMemory{
    return [LXMemoryInfo appUsedMemory];
}


- (double)appMaxMemory{
    return [LXMemoryInfo appMaxMemory];
}


// Total Memory
+ (double)totalMemory {
    // Find the total amount of memory
    @try {
        // Set up the variables
        double TotalMemory = 0.00;
        double AllMemory = [[NSProcessInfo processInfo] physicalMemory];
        
        // Total Memory (formatted)
        TotalMemory = (AllMemory / 1024.0) / 1024.0;
        
        // Round to the nearest multiple of 256mb - Almost all RAM is a multiple of 256mb (I do believe)
        int toNearest = 256;
        int remainder = (int)TotalMemory % toNearest;
        
        if (remainder >= toNearest / 2) {
            // Round the final number up
            TotalMemory = ((int)TotalMemory - remainder) + 256;
        } else {
            // Round the final number down
            TotalMemory = (int)TotalMemory - remainder;
        }
        
        // Check to make sure it's valid
        if (TotalMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Free Memory
+ (double)freeMemory{
    // Find the total amount of free memory
    @try {
        // Set up the variables
        double TotalMemory = 0.00;
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
        
        if(kernReturn != KERN_SUCCESS) {
            return -1;
        }
        
        TotalMemory = ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
        
        // Check to make sure it's valid
        if (TotalMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Used Memory
+ (double)usedMemory{
    // Find the total amount of used memory
    @try {
        // Set up the variables
        double TotalUsedMemory = 0.00;
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        // Get the variable values
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        
        vm_statistics_data_t vm_stat;
        
        // Check for any system errors
        if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
            // Error, failed to get Virtual memory info
            return -1;
        }
        
        // Memory statistics in bytes
        natural_t UsedMemory = (natural_t)((vm_stat.active_count +
                                            vm_stat.inactive_count +
                                            vm_stat.wire_count) * pagesize);
        
        TotalUsedMemory = (UsedMemory / 1024.0) / 1024.0;
        
        // Check to make sure it's valid
        if (TotalUsedMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalUsedMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Active Memory
+ (double)activeMemory{
    // Find the Active memory
    @try {
        // Set up the variables
        double TotalMemory = 0.00;
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        // Get the variable values
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        
        vm_statistics_data_t vm_stat;
        
        // Check for any system errors
        if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
            // Error, failed to get Virtual memory info
            return -1;
        }
        
        TotalMemory = ((vm_stat.active_count * pagesize) / 1024.0) / 1024.0;
        
        // Check to make sure it's valid
        if (TotalMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Inactive Memory
+ (double)inactiveMemory{
    // Find the Inactive memory
    @try {
        // Set up the variables
        double TotalMemory = 0.00;
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        // Get the variable values
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        
        vm_statistics_data_t vm_stat;
        
        // Check for any system errors
        if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
            // Error, failed to get Virtual memory info
            return -1;
        }
        
        TotalMemory = ((vm_stat.inactive_count * pagesize) / 1024.0) / 1024.0;
        
        // Check to make sure it's valid
        if (TotalMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Wired Memory
+ (double)wiredMemory{
    // Find the Wired memory
    @try {
        // Set up the variables
        double TotalMemory = 0.00;
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        // Get the variable values
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        
        vm_statistics_data_t vm_stat;
        
        // Check for any system errors
        if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
            // Error, failed to get Virtual memory info
            return -1;
        }
        
        TotalMemory = ((vm_stat.wire_count * pagesize) / 1024.0) / 1024.0;
        
        // Check to make sure it's valid
        if (TotalMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

// Purgable Memory
+ (double)purgableMemory{
    // Find the Purgable memory
    @try {
        // Set up the variables
        double TotalMemory = 0.00;
        mach_port_t host_port;
        mach_msg_type_number_t host_size;
        vm_size_t pagesize;
        
        // Get the variable values
        host_port = mach_host_self();
        host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
        host_page_size(host_port, &pagesize);
        
        vm_statistics_data_t vm_stat;
        
        // Check for any system errors
        if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
            // Error, failed to get Virtual memory info
            return -1;
        }
        
        TotalMemory = ((vm_stat.purgeable_count * pagesize) / 1024.0) / 1024.0;
        
        // Check to make sure it's valid
        if (TotalMemory <= 0) {
            // Error, invalid memory value
            return -1;
        }
        
        // Completed Successfully
        return TotalMemory;
    }
    @catch (NSException *exception) {
        // Error
        return -1;
    }
}

+ (double)appPhysFootprintMemory{
    int64_t memoryUsageInByte = 0;
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        memoryUsageInByte = (int64_t) vmInfo.phys_footprint;
    }
    return (double)memoryUsageInByte/ 1024.0 / 1024.0;
}

+ (double)appUsedMemory{
    mach_task_basic_info_data_t taskInfo;
    unsigned infoCount = sizeof(taskInfo);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

+ (double)appMaxMemory{
    mach_task_basic_info_data_t taskInfo;
    unsigned infoCount = sizeof(taskInfo);
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         MACH_TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    return taskInfo.resident_size_max / 1024.0 / 1024.0;
}


@end
