//
//  LXToolsBox.m
//  LXPerformance
//
//  Created by 李笑清 on 2020/11/22.
//

#import "LXToolsBox.h"

static UIWindow * _Nullable LXNormalWindow(void) {
    UIWindow *window = nil;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        window = [[[UIApplication sharedApplication] delegate] window];
    }else{
        window = [[UIApplication sharedApplication] keyWindow];
    }
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *temp in windows) {
            if (temp.windowLevel == UIWindowLevelNormal) {
                return temp;
            }
        }
    }
    return window;
}

static UIViewController * _Nullable LXTopControllerByWindow(UIWindow *window) {
    if (!window) return nil;
        
    UIViewController *top = nil;
    id nextResponder;
    if (window.subviews.count > 0) {
        UIView *frontView = [window.subviews objectAtIndex:0];
        nextResponder = frontView.nextResponder;
    }
    if (nextResponder && [nextResponder isKindOfClass:UIViewController.class]) {
        top = nextResponder;
    } else {
        top = window.rootViewController;
    }
    
    while ([top isKindOfClass:UITabBarController.class] || [top isKindOfClass:UINavigationController.class] || top.presentedViewController) {
        if ([top isKindOfClass:UITabBarController.class]) {
            top = ((UITabBarController *)top).selectedViewController;
        } else if ([top isKindOfClass:UINavigationController.class]) {
            top = ((UINavigationController *)top).topViewController;
        } else if (top.presentedViewController) {
            top = top.presentedViewController;
        }
    }
    return top;
}


static UIViewController * _Nullable LXTopController(void) {
    __block UIViewController *vc = nil;
    DISPATCH_MAIN_SYNC(^{
        vc = LXTopControllerByWindow(LXNormalWindow());
    });
    return vc;
}

@implementation LXToolsBox

+ (NSString *)createUUID{
    NSString *uuid;
    
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    
    if (result) {
        NSString *res =  result;
        
        res = [res stringByReplacingOccurrencesOfString:@"-" withString:@""];
        res = [res stringByReplacingOccurrencesOfString:@" " withString:@""];
        res = [res lowercaseString];
        uuid = res;
    }
    
    if([uuid length] <= 0){
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        formatter.locale = cnLocale;
        NSString *randStr = [formatter stringFromDate:date];
        randStr = [randStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
        
        NSString *outputStr = @"1234567890abcdefghijklmnopqrstuvwxyz";
        while ([randStr length]<32) {
            int index  = arc4random() % outputStr.length;
            NSString *indexString = [outputStr substringWithRange:NSMakeRange(index, 1)];
            
            randStr = [randStr stringByAppendingString:indexString];
        }
        
        if ([randStr length]>32) {
            randStr = [randStr substringToIndex:32];
        }
        
        uuid = randStr;
    }
    
    return uuid;
}

+ (UIColor *)transformFromColor:(UIColor*)fromColor toColor:(UIColor *)toColor progress:(CGFloat)progress{
    progress = progress >= 1 ? 1 : progress;
    progress = progress <= 0 ? 0 : progress;
    
    const CGFloat * fromeComponents = CGColorGetComponents(fromColor.CGColor);
    const CGFloat * toComponents = CGColorGetComponents(toColor.CGColor);
    
    size_t  fromColorNumber = CGColorGetNumberOfComponents(fromColor.CGColor);
    size_t  toColorNumber = CGColorGetNumberOfComponents(toColor.CGColor);
    
    if (fromColorNumber == 2) {
        CGFloat white = fromeComponents[0];
        fromColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        fromeComponents = CGColorGetComponents(fromColor.CGColor);
    }
    
    if (toColorNumber == 2) {
        CGFloat white = toComponents[0];
        toColor = [UIColor colorWithRed:white green:white blue:white alpha:1];
        toComponents = CGColorGetComponents(toColor.CGColor);
    }
    
    CGFloat r = fromeComponents[0]*(1 - progress) + toComponents[0]*progress;
    CGFloat g = fromeComponents[1]*(1 - progress) + toComponents[1]*progress;
    CGFloat b = fromeComponents[2]*(1 - progress) + toComponents[2]*progress;
    return [UIColor colorWithRed:r green:g blue:b alpha:1];
}

+ (UIViewController *)topViewController{
    return LXTopController();
}

@end
