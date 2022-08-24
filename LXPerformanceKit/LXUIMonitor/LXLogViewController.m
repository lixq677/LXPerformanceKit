//
//  LXLogViewController.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import "LXLogViewController.h"

@interface LXLogViewController ()

@property (nonatomic,strong)UITextView *textView;

@property (nonatomic,strong)NSString *log;

@end

@implementation LXLogViewController

- (instancetype)initWithLog:(NSString *)log{
    if (self = [super init]) {
        _log = log;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"堆栈信息";
    [self.view addSubview:self.textView];
    self.textView.frame = self.view.bounds;
    self.textView.text = self.log;
}


- (UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectZero];
        _textView.editable = NO;
        _textView.font = [UIFont systemFontOfSize:14.0f];
    }
    return _textView;
}

@end
