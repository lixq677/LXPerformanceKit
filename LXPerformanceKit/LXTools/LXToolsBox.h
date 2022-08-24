//
//  LXToolsBox.h
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define DISPATCH_MAIN_ASYNC(block) \
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define DISPATCH_MAIN_SYNC(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

@interface LXToolsBox : NSObject

+ (NSString *)createUUID;

+ (UIColor *)transformFromColor:(UIColor*)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress;

+ (UIViewController *)topViewController;

@end

NS_ASSUME_NONNULL_END
