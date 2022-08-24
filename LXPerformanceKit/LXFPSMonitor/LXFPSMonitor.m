//
//  LXFPSMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/16.
//

#import "LXFPSMonitor.h"
#import <UIKit/UIKit.h>

@interface LXFPSMonitor ()

@property (nonatomic, strong,readonly) CADisplayLink *link;

@property (nonatomic, assign)int count;

@property (nonatomic, assign)NSTimeInterval lastTime;

@property (nonatomic,strong)void(^fpsBlock)(int fps);

@end

@implementation LXFPSMonitor
@synthesize link = _link;

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)tick:(CADisplayLink *)link{
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    _count++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta >= 1) {
        _lastTime = link.timestamp;
        int fps = (int)round((NSTimeInterval)_count/delta);
        if (self.fpsBlock) {
            self.fpsBlock(fps);
        }
        _count = 0;
    }
}

//开始监控
- (void)startMonitorWithBlock:(void(^)(int fps))block{
    if (_monitor || block == nil)return;
    _monitor = YES;
    _fpsBlock = block;
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }else{
        _link.paused = NO;
    }
}

//停止监控
- (void)stopMonitor{
    _monitor = NO;
    if (_link) {
        _link.paused = YES;
        [_link invalidate];
        _link = nil;
    }
    _lastTime = 0;
    _count = 0;
}


@end
