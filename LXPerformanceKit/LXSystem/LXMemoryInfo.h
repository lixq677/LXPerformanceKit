//
//  LXMemoryInfo.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXMemoryInfo : NSObject
//单位，MB
@property (nonatomic,assign,readonly)double totalMemory;

@property (nonatomic,assign,readonly)double usedMemory;

@property (nonatomic,assign,readonly)double appPhysFootprintMemory;

@property (nonatomic,assign,readonly)double appUsedMemory;

@property (nonatomic,assign,readonly)double appMaxMemory;


// Total Memory[MB]
+ (double)totalMemory;

// Free Memory
+ (double)freeMemory;

// Used Memory
+ (double)usedMemory;

// Active Memory
+ (double)activeMemory;

// Inactive Memory
+ (double)inactiveMemory;

// Wired Memory
+ (double)wiredMemory;

// Purgable Memory
+ (double)purgableMemory;

+ (double)appPhysFootprintMemory;

+ (double)appUsedMemory;

+ (double)appMaxMemory;

@end

NS_ASSUME_NONNULL_END
