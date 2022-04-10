//
//  LXSystemUtil.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/10/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXSystemUtil : NSObject

/* SysCtl */
+ (uint64_t)getSysCtl64WithSpecifier:(char*)specifier;


@end

NS_ASSUME_NONNULL_END
