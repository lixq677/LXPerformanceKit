//
//  ViewController.m
//  Demo
//
//  Created by 李笑清 on 2020/11/25.
//

#import "ViewController.h"
#import <LXPerformanceKit/LXPerformanceKit.h>
#include <signal.h>
#include <unistd.h>

@interface ViewController ()
/*测试卡顿*/
@property (nonatomic,strong)UIButton *testLagBtn;

/*测试崩溃*/
@property (nonatomic,strong)UIButton *testCrashBtn;
@property (nonatomic,strong)UIButton *testGPUBtn;
@property (nonatomic,strong)UIButton *testCPUBtn;
@property (nonatomic,strong)UIButton *testFPSBtn;
@property (nonatomic,strong)UIButton *testMEMBtn;

@property (nonatomic,assign)BOOL dismissed;

@end

@implementation ViewController

- (void)didReceiveMemoryWarning{
    NSLog(@"***");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *testLagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testLagBtn setTitle:@"测试卡顿" forState:UIControlStateNormal];
    [testLagBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    testLagBtn.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-100, 100, 200, 50);
    [testLagBtn addTarget:self action:@selector(testLagAction:) forControlEvents:UIControlEventTouchUpInside];
    self.testLagBtn = testLagBtn;
    [self.view addSubview:testLagBtn];
    
    UIButton *testCrashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testCrashBtn setTitle:@"测试崩溃" forState:UIControlStateNormal];
    [testCrashBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    testCrashBtn.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-100, 170, 200, 50);
    [testCrashBtn addTarget:self action:@selector(testCrashAction:) forControlEvents:UIControlEventTouchUpInside];
    self.testCrashBtn = testCrashBtn;
    [self.view addSubview:testCrashBtn];
    
    UIButton *testGPUBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testGPUBtn setTitle:@"GPU" forState:UIControlStateNormal];
    [testGPUBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    testGPUBtn.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-100, 240, 200, 50);
    [testGPUBtn addTarget:self action:@selector(testGPUAction:) forControlEvents:UIControlEventTouchUpInside];
    self.testGPUBtn = testGPUBtn;
    [self.view addSubview:testGPUBtn];
    
    UIButton *testCPUBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testCPUBtn setTitle:@"CPU" forState:UIControlStateNormal];
    [testCPUBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    testCPUBtn.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-100, 310, 200, 50);
    [testCPUBtn addTarget:self action:@selector(testCPUAction:) forControlEvents:UIControlEventTouchUpInside];
    self.testCPUBtn = testCPUBtn;
    [self.view addSubview:testCPUBtn];
    
    UIButton *testMEMBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testMEMBtn setTitle:@"MEM" forState:UIControlStateNormal];
    [testMEMBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    testMEMBtn.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-100, 380, 200, 50);
    [testMEMBtn addTarget:self action:@selector(testMEMAction:) forControlEvents:UIControlEventTouchUpInside];
    self.testMEMBtn = testMEMBtn;
    [self.view addSubview:testMEMBtn];
    
    UIButton *testFPSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [testFPSBtn setTitle:@"FPS" forState:UIControlStateNormal];
    [testFPSBtn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    testFPSBtn.frame = CGRectMake(CGRectGetMidX(self.view.bounds)-100, 450, 200, 50);
    [testFPSBtn addTarget:self action:@selector(testFPSAction:) forControlEvents:UIControlEventTouchUpInside];
    self.testFPSBtn = testFPSBtn;
    [self.view addSubview:testFPSBtn];

//    signal(SIGABRT, mySignalHandler);
//    signal(SIGSEGV, mySignalHandler);
//    signal(SIGBUS, mySignalHandler);
//    signal(SIGILL, mySignalHandler);
    
    pid_t pid = getpid();
    printf("主函数开跑 进程：%d\n",pid);
    

    
    [[LXLagMonitor defaultMonitor] startMonitorWithReportBlock:^(LXLag * _Nonnull lagInfo) {
        NSLog(@"卡顿发生：%@",lagInfo.description);
        [self showLag:lagInfo];
    }];
    
    [[LXCrashMonitor defaultMonitor] startMonitorWithTypes:LXCrashTypeAll reportBlock:^(LXCrash * _Nonnull crashInfo) {
        NSLog(@"崩溃发生了：%@",crashInfo.description);
        [self showCrash:crashInfo];
    }];
    
}


- (void)testLagAction:(id)sender{
    [NSThread sleepForTimeInterval:0.35];
}

- (void)testCrashAction:(id)sender{
//    pid_t pid = getpid();
//    printf("pid 进程：%d\n",pid);
//    kill(getpid(), SIGABRT);

    
    //[self test];
    NSArray *array = @[];
  //  越个界试试
    id t = [array objectAtIndex:0];
}

- (void)testGPUAction:(id)sender{
    if ([LXUIMonitor  isMonitor:LXUIMonitorTypeGPU]) {
        [LXUIMonitor stopMonitor:LXUIMonitorTypeGPU];
    }else{
        [LXUIMonitor startMonitor:LXUIMonitorTypeGPU];
    }
}

- (void)testCPUAction:(id)sender{
    if ([LXUIMonitor  isMonitor:LXUIMonitorTypeCPU]) {
        [LXUIMonitor stopMonitor:LXUIMonitorTypeCPU];
    }else{
        [LXUIMonitor startMonitor:LXUIMonitorTypeCPU];
    }
}

- (void)testMEMAction:(id)sender{
    if ([LXUIMonitor  isMonitor:LXUIMonitorTypeMEM]) {
        [LXUIMonitor stopMonitor:LXUIMonitorTypeMEM];
    }else{
        [LXUIMonitor startMonitor:LXUIMonitorTypeMEM];
    }
}

- (void)testFPSAction:(id)sender{
    if ([LXUIMonitor  isMonitor:LXUIMonitorTypeFPS]) {
        [LXUIMonitor stopMonitor:LXUIMonitorTypeFPS];
    }else{
        [LXUIMonitor startMonitor:LXUIMonitorTypeFPS];
    }
}



- (void)showLag:(LXLag *)lagInfo{
    NSString *title = nil;
    if(lagInfo.lagDegree == LXLagDegreeSerious){
        title = @"你完了！严重卡顿！老板说要杀一个程序员祭天";
    }else if (lagInfo.lagDegree == LXLagDegreeMedium){
        title = @"请注意！你开发的功能有点卡！老板要问候你,请呆在厕所，不要出来";
    }else{
        title = @"不要慌！轻微卡顿！就算天王老子来了，也是测试的幻觉！";
    };
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:lagInfo.description preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
   
}

- (void)test{
    //创建异常
//    NSString *exceptionName = @"hi,我是一个异常";
//    NSString *excaptionReason = @"我不开心了，所以我要让程序崩溃";
//    NSDictionary *exceptionUserInfo = nil;
//    NSException *exception = [NSException exceptionWithName:exceptionName reason:excaptionReason userInfo:exceptionUserInfo];
//
//    //抛出异常
//    @throw exception;
 //   abort();
    [self test];
}

void mySignalHandler(int signal) {
    NSLog(@"*******");
}


- (void)showCrash:(LXCrash *)crashInfo{
    self.dismissed = NO;
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"崩溃日志" message:crashInfo.description preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.dismissed = YES;
    }];
    [controller addAction:action];
    [self presentViewController:controller animated:YES completion:nil];
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!self.dismissed) {
        for (NSString* mode in (__bridge NSArray*)allModes) {
            //为阻止线程退出，使用（CFRunLoopRunInMode(model,0.001,false)等待系统消息，false表示RunLoop没有超时
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    CFRelease(allModes);
}

@end
