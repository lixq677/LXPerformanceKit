//
//  LXUIGPUMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/22.
//

#import "LXUIGPUMonitor.h"
#import <UIKit/UIKit.h>
#import <LXPerformanceKit/LXGPUMonitor.h>
#import <LXPerformanceKit/LXToolsBox.h>


@interface LXUIGPUMonitor ()

@property (nonatomic,strong)UILabel *displayLabel;

@property (nonatomic,strong)UIWindow *window;

@property (nonatomic,assign)NSUInteger count;

@property (nonatomic,assign)NSUInteger total;

@end

@implementation LXUIGPUMonitor

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
    [[LXGPUMonitor defaultMonitor] startMonitorWithTimeInterval:0.01 handler:^(LXGPUUtilization * _Nonnull GPUUtilization) {
        NSUInteger usage = [GPUUtilization deviceUtilization];
        if (self.count == 50) {
            NSUInteger gpuUsage = self.total/50;
            NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"GPU: %02lu%%",(unsigned long)gpuUsage]];
            // 根据卡顿程度显示颜色
            UIColor *color = nil;
            if (gpuUsage < 30) {
                color = [UIColor greenColor];
            } else if (gpuUsage < 50 && gpuUsage >= 20) {
                color = [UIColor purpleColor];
            } else {
                color = [UIColor redColor];
            }
            [text addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, 4)];
            [text addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(4, text.length-4)];
            self.displayLabel.attributedText = text;
            self.count = 0;
            self.total = 0;
        }
        self.count++;
        self.total += usage;
    }];
}

- (void)stopMonitor{
    if (![self isMonitor]) return;
    [self.displayLabel removeFromSuperview];
    [self.window setHidden:YES];
    [[LXGPUMonitor defaultMonitor] stopMonitor];
}

#pragma mark getter
- (UILabel *)displayLabel{
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(UIScreen.mainScreen.bounds) - 90, 0, 60, 20)];
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
    return [[LXGPUMonitor defaultMonitor] isMonitor];
}

@end
