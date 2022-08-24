//
//  LXUICPUMonitor.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import "LXUICPUMonitor.h"
#import "LXWaveView.h"
#import "LXCurveChartView.h"
#import <LXPerformanceKit/LXToolsBox.h>
#import <LXPerformanceKit/LXCPUMonitor.h>
#import <LXPerformanceKit/LXBacktrace.h>
#import <mach/mach.h>
#import <UIKit/UIKit.h>
#import "LXExceptViewController.h"

//static BOOL IS_Null_String(NSString *string){
//    if (string == nil || string == NULL) {
//        return YES;
//    }
//    if ([string isKindOfClass:[NSNull class]]) {
//        return YES;
//    }
//    NSString *str = [string stringByReplacingOccurrencesOfString:@"\a" withString:@""];
//    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//    if ([str length] == 0) {
//        return YES;
//    }
//    return NO;
//}

#define LX_CPU_MONITOR_THRESHOLD_KEY @"lx_cpu_monitor_threshold"

@interface LXUICPUMonitor ()<LXWaveViewDelegate,LXCurveChartViewDelegate,LXCurveChartViewDataSource>

@property (nonatomic,strong)LXWaveView *waveView;

@property (nonatomic,strong)LXCurveChartView *chartView;

@property (nonatomic,strong,readonly)NSMutableArray<LXChartValueModel *> *values;

@property (nonatomic,strong,readonly)NSArray<NSString *> *vTitles;

@property (nonatomic,assign)BOOL showChart;

@property (nonatomic,strong)NSMutableDictionary<NSString *,NSString *> *logs;

/*0-100之间的数字,表示阀值*/
@property (nonatomic,assign)float cpuThreshold;

@end

@implementation LXUICPUMonitor
@synthesize values = _values;

+(id)defaultMonitor{
    static id shareInstance= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    NSNumber *cpuUsage = [[NSUserDefaults standardUserDefaults] objectForKey:LX_CPU_MONITOR_THRESHOLD_KEY];
    if (cpuUsage) {
        _cpuThreshold = cpuUsage.floatValue;
    }else{
        _cpuThreshold = 70;
    }
    _vTitles = @[@"0",@"20",@"40",@"60",@"80",@"100"];
}


- (void)startMonitor{
    if ([self isMonitor]) {
        return;
    }
    [self.waveView start];
    __weak typeof(self) weakSelf = self;
    [[LXCPUMonitor defaultMonitor] startMonitorWithTimeInterval:0.5 handler:^(float cpuUsage, NSDictionary<NSNumber *,NSNumber *> * _Nonnull threadUsage) {
        __strong typeof(weakSelf) self = weakSelf;
        if (cpuUsage*100 > self.cpuThreshold) {
            NSMutableString *log = [NSMutableString string];
            [log appendFormat:@"CPU 使用率：%d%%\n",(int)(cpuUsage * 100)];
            thread_t mainTh = [LXBacktrace machThreadFromNSThread:[NSThread mainThread]];
            [threadUsage enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                if (mainTh == key.intValue) {
                    [log appendFormat:@"主线程%@,CPU 使用率:%d%%\n",key,(int)(obj.floatValue*100)];
                }else{
                    [log appendFormat:@"线程号%@,CPU 使用率:%d%%\n",key,(int)(obj.floatValue*100)];
                }
                NSString *stackInfo = [LXBacktrace  backtraceThread:key.intValue];
                [log appendFormat:@"%@\n",stackInfo];
            }];
            NSString *time = [self stringWithDate:NSDate.date];
            [self.logs setObject:log forKey:time];
        }
        
        if (self.showChart) {
            LXChartValueModel *model = [[LXChartValueModel alloc] init];
            model.value = cpuUsage * 100;
            [self.values addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.waveView.progress = cpuUsage;
            self.waveView.title = [NSString stringWithFormat:@"CPU:\n%02d%%",(int)(cpuUsage*100)];
            if (self.showChart) {
                [self.chartView loadNewData];
            }
        });
    }];
}

/// 停止监控
- (void)stopMonitor{
    if (NO == [self isMonitor]) return;
    [self.waveView stop];
    self.showChart = NO;
    if (self.chartView.isShow) {
        [self.chartView dismiss];
    }
    if (self.chartView.superview) {
        [self.chartView removeFromSuperview];
    }
    [[LXCPUMonitor defaultMonitor] stopMonitor];
}



#pragma mark PGWaterWaveView Delegate
- (void)waterWaveView:(LXWaveView *)waterView didDoubleTapAction:(id)sender{
    if (NO == self.chartView.isShow) {
        [self.chartView show];
    }else{
        [self.chartView dismiss];
    }
}

- (void)waterWaveView:(LXWaveView *)waterView didLongPressAction:(id)sender{
   
}

#pragma mark chartView Data source

- (NSInteger)numberOfVerticalLinesOfChartView:(LXCurveChartView *)chartView{
    return self.vTitles.count;
}

- (NSInteger)numberOfHorizontalDataOfChartView:(LXCurveChartView *)chartView{
    return  self.values.count;
}

- (NSString *)chartView:(LXCurveChartView *)chartView titleForVerticalAtIndex:(NSInteger)index{
    return [self.vTitles objectAtIndex:index];
}

//- (NSString *)chartView:(PGCurveChartView *)chartView titleForHorizontalAtIndex:(NSInteger)index{
//    PGChartValueModel *model = [self.values objectAtIndex:index];
//    return model.title;
//}

- (CGFloat)chartView:(LXCurveChartView *)chartView valueAtIndex:(NSInteger)index{
    LXChartValueModel *model = [self.values objectAtIndex:index];
    return model.value;
}

- (void)chartView:(LXCurveChartView *)chartView scanThreadAction:(id)sender{
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"设置CPU异常阀值" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self alert];
    }];
    [controller addAction:action1];
    
    if(self.logs.count > 0){
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"查看异常线程" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self scanExceptions];
        }];
        [controller addAction:action2];
        
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"清除异常信息" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.logs removeAllObjects];
        }];
        [controller addAction:action3];
    }
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:action4];
    [[LXToolsBox topViewController] presentViewController:controller animated:YES completion:nil];
}

- (void)showWithChartView:(LXCurveChartView *)chartView{
    self.showChart = YES;
}

- (void)dimissWithChartView:(LXCurveChartView *)chartView{
    self.showChart = NO;
    [self.values removeAllObjects];
}

- (void)alert{
    NSString *msg = [NSString stringWithFormat:@"当前cpu异常阀值:%.2f%%",self.cpuThreshold];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"设置CPU异常阀值" message:msg preferredStyle:UIAlertControllerStyleAlert];
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入100以内的正整数";
        textField.font = [UIFont systemFontOfSize:14.0f];
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = [controller.textFields firstObject];
        NSInteger cpuUsage = [textField.text integerValue];
        if (cpuUsage > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:@(cpuUsage) forKey:LX_CPU_MONITOR_THRESHOLD_KEY];
            self.cpuThreshold = cpuUsage;
        }
    }];
    [controller addAction:action1];
    [controller addAction:action2];
    [[LXToolsBox topViewController] presentViewController:controller animated:YES completion:nil];
}

- (void)scanExceptions{
    UIViewController *controller = [[LXExceptViewController alloc] initWithSource:self.logs];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
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

#pragma mark getter
- (LXWaveView *)waveView{
    if (!_waveView) {
        _waveView = [[LXWaveView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 60, 80, 60, 60)];
        _waveView.progress = 0.5;
        _waveView.delegate = self;
    }
    return _waveView;
}

- (LXCurveChartView *)chartView{
    if (!_chartView) {
        _chartView = [[LXCurveChartView alloc] initWithFrame:CGRectMake(0, 300, CGRectGetWidth([UIScreen.mainScreen bounds]), 200)];
        _chartView.dataSource = self;
        _chartView.delegate = self;
        _chartView.orign = CGPointMake(40, 40);
        _chartView.hSpace = 20;
        _chartView.vSpace = 20;
        _chartView.valueRef = 20;
    }
    return _chartView;
}

- (NSMutableArray<LXChartValueModel *> *)values{
    if (!_values) {
        _values = [NSMutableArray array];
    }
    return _values;
}

- (NSMutableDictionary<NSString *,NSString *> *)logs{
    if (!_logs) {
        _logs = [NSMutableDictionary dictionary];
    }
    return _logs;
}

- (BOOL)isMonitor{
    return [[LXCPUMonitor defaultMonitor] isMonitor];
}


@end
