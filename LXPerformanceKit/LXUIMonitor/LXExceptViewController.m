//
//  LXExceptViewController.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import "LXExceptViewController.h"
#import "LXLogViewController.h"

@interface LXExceptViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic,strong,readonly)NSDictionary<NSString *,NSString *> *exceptDictionary;

@property (nonatomic,strong,readonly)NSArray<NSString *> *timeArray;

@end

@implementation LXExceptViewController

- (instancetype)initWithSource:(NSDictionary<NSString *,NSString *> *)exceptDictionary;{
    if (self = [super init]) {
        _exceptDictionary = exceptDictionary;
        _timeArray = [[_exceptDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *  _Nonnull obj1, NSString *  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.frame = self.view.bounds;
    [self.view addSubview:self.tableView];
    self.title = @"线程信息";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
}

- (void)dismiss{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.exceptDictionary.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"xxx"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"xxx"];
    }
    
    cell.textLabel.text = @"异常日志";
    cell.detailTextLabel.text = [self.timeArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *time = [self.timeArray objectAtIndex:indexPath.row];
    NSString *log = [self.exceptDictionary objectForKey:time];
    UIViewController *controller = [[LXLogViewController alloc] initWithLog:log];
    [self.navigationController pushViewController:controller animated:YES];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


@end
