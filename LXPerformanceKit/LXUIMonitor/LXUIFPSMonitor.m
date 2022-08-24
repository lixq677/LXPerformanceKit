//
//  LXUIFPSMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/22.
//

#import "LXUIFPSMonitor.h"
#import <UIKit/UIKit.h>
#import <LXPerformanceKit/LXFPSMonitor.h>
#import <LXPerformanceKit/LXToolsBox.h>

@interface LXUIFPSMonitor ()

@property (nonatomic,strong)UILabel *displayLabel;

@property (nonatomic,strong)UIWindow *window;

@end

@implementation LXUIFPSMonitor

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)startMonitor{
    if ([self isMonitor]) return;
    [self.window setHidden:NO];
    [self.window addSubview:self.displayLabel];
    [[LXFPSMonitor defaultMonitor] startMonitorWithBlock:^(int fps) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
           
           // 根据卡顿程度显示颜色
        UIColor *fpscolor = nil;
        if (fps >= 55.0) {
            fpscolor = [UIColor greenColor];
        } else if (fps>=50 && fps<55) {
            fpscolor = [UIColor blueColor];
        } else {
            fpscolor = [UIColor redColor];
        }
        [text addAttribute:NSForegroundColorAttributeName value:fpscolor range:NSMakeRange(0, text.length - 3)];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:NSMakeRange(text.length - 3, 3)];
        self.displayLabel.attributedText = text;
    }];
}

- (void)stopMonitor{
    if (![self isMonitor]) return;
    [self.displayLabel removeFromSuperview];
    [self.window setHidden:YES];
    [[LXFPSMonitor defaultMonitor] stopMonitor];
}

#pragma mark getter
- (UILabel *)displayLabel{
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 50, 20)];
        _displayLabel.font = [UIFont systemFontOfSize:12];
        _displayLabel.layer.cornerRadius = 5;
        _displayLabel.clipsToBounds = YES;
        _displayLabel.textAlignment = NSTextAlignmentCenter;
        _displayLabel.userInteractionEnabled = NO;
        _displayLabel.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.700];
    }
    return _displayLabel;
}

- (UIWindow *)window{
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds), 20)];
        _window.windowLevel = UIWindowLevelStatusBar + 100;
        if(@available(iOS 13.0,*)){
            NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
            if (!_window.windowScene) {
                for (UIWindowScene *windowScene in array) {
                    if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                        _window.windowScene = windowScene;
                    }
                }
            }
        }
        _window.backgroundColor = [UIColor clearColor];
        _window.rootViewController = [UIViewController new];
    }
    return _window;
}

- (BOOL)isMonitor{
    return [[LXFPSMonitor defaultMonitor] isMonitor];
}

@end
