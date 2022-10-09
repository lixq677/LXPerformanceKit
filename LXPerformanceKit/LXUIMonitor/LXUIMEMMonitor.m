//
//  LXUIMEMMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/22.
//

#import "LXUIMEMMonitor.h"
#import "LXWaveView.h"
#import "LXExceptViewController.h"
#import <LXPerformanceKit/LXMEMMonitor.h>
#import <LXPerformanceKit/LXToolsBox.h>

#define LX_MEM_MONITOR_THRESHOLD_KEY @"lx_mem_monitor_threshold"

@interface LXUIMEMMonitor ()<LXWaveViewDelegate>

@property (nonatomic,strong)LXWaveView *waveView;

@property (nonatomic,strong)NSMutableDictionary<NSString *,NSString *> *logs;

@end

@implementation LXUIMEMMonitor

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
    [self startMemorySizeMonitor];
}

- (void)stopMonitor{
    if (![self isMonitor]) return;
    [self stopMemorySizeMonitor];
}

- (void)startMemorySizeMonitor{
    [self.waveView start];
    __weak typeof(self) weakSelf = self;
    [[LXMEMMonitor defaultMonitor] startMemorySizeMonitorWithTimeInterval:0.5 handler:^(LXMemoryInfo * _Nonnull memory) {
        __strong typeof(weakSelf) self = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            double memoryUsage = memory.appPhysFootprintMemory;
            self.waveView.progress = memoryUsage/[memory totalMemory];
            self.waveView.title = [NSString stringWithFormat:@"%.2f\nMb",memoryUsage];
        });
    }];
}

- (void)stopMemorySizeMonitor{
    [self.waveView stop];
    [[LXMEMMonitor defaultMonitor] stopMemorySizeMonitor];
}

- (void)startMallocStackMonitor{
    NSNumber *threshholdInBytes = [[NSUserDefaults standardUserDefaults] objectForKey:LX_MEM_MONITOR_THRESHOLD_KEY];
    [[LXMEMMonitor defaultMonitor] startMallocStackMonitorWithThreshholdInBytes:(threshholdInBytes ? threshholdInBytes.integerValue:1024*1024) block:^(NSString * _Nonnull stackLog, NSString * _Nonnull stack, size_t bytes) {
        NSString *time = [self stringWithDate:NSDate.date];
        NSString *log = [NSString stringWithFormat:@"malloc size:%zu KB %@",bytes,stackLog];
        [self.logs setObject:log forKey:time];
        [self.waveView startTwinkle];
    }];
}

- (void)stopMallocStackMonitor{
    [[LXMEMMonitor defaultMonitor] stopMallocStackMonitor];
}


- (void)scanExceptions{
        UIViewController *controller = [[LXExceptViewController alloc] initWithSource:self.logs];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [[LXToolsBox topViewController] presentViewController:nav animated:YES completion:nil];
}


- (NSString *)stringWithDate:(NSDate *)date{
    time_t t = [date timeIntervalSince1970];
    const int strlen1 = 50;
    char tmpBuf[strlen1];
    strftime(tmpBuf, strlen1,"%T", localtime(&t));
    NSString *rerutnStr = [NSString stringWithCString:tmpBuf encoding:NSUTF8StringEncoding];
    return rerutnStr;
}

#pragma mark PGWaterWaveView Delegate
- (void)waterWaveView:(LXWaveView *)waterView didDoubleTapAction:(id)sender{
    if (NO == [[LXMEMMonitor defaultMonitor] isSingleMallocMonitor] || self.logs.count == 0)return;
    [self scanExceptions];
}

- (void)waterWaveView:(LXWaveView *)waterView didLongPressAction:(id)sender{
    if (NO == [[LXMEMMonitor defaultMonitor] isSingleMallocMonitor])return;
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"设置单次内存分配监听" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入单次内存分配监控阀值，单位KB";
        textField.font = [UIFont systemFontOfSize:14.0f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
   
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"停止" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self stopMallocStackMonitor];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [controller.textFields firstObject];
        NSInteger memoryUsage = [textField.text integerValue];
        if (memoryUsage > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@(memoryUsage) forKey:LX_MEM_MONITOR_THRESHOLD_KEY];
        }
        [self stopMallocStackMonitor];
        [self startMallocStackMonitor];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action1];
    [controller addAction:action2];
    [controller addAction:action3];
}



#pragma mark getter
- (LXWaveView *)waveView{
    if (!_waveView) {
        _waveView = [[LXWaveView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 60, 80, 60, 60)];
        _waveView.progress = 0.5;
        _waveView.delegate = self;
    }
    return _waveView;
}


- (NSMutableDictionary<NSString *,NSString *> *)logs{
    if (!_logs) {
        _logs = [NSMutableDictionary dictionary];
    }
    return _logs;
}

- (BOOL)isMonitor{
    return [[LXMEMMonitor defaultMonitor] isMemorySizeMonitor];
}

@end
