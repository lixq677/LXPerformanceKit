//
//  LXCurveChartView.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface LXChartValueModel : NSObject
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, copy) NSString *title;

@end

@class  LXCurveChartView;

@protocol LXCurveChartViewDataSource <NSObject>
/*水平数量*/
- (NSInteger)numberOfHorizontalDataOfChartView:(LXCurveChartView *)chartView;

/*value*/
- (CGFloat)chartView:(LXCurveChartView *)chartView valueAtIndex:(NSInteger)index;

/*垂直个数*/
- (NSInteger)numberOfVerticalLinesOfChartView:(LXCurveChartView *)chartView;

@optional
- (NSString *)chartView:(LXCurveChartView *)chartView titleForHorizontalAtIndex:(NSInteger)index;

- (NSString *)chartView:(LXCurveChartView *)chartView titleForVerticalAtIndex:(NSInteger)index;

@end

@protocol LXCurveChartViewDelegate <NSObject>

@optional

- (void)chartView:(LXCurveChartView *)chartView scanThreadAction:(id)sender;

- (void)dimissWithChartView:(LXCurveChartView *)chartView;

- (void)showWithChartView:(LXCurveChartView *)chartView;

@end

@interface LXCurveChartView : UIView

@property (nonatomic, weak) id<LXCurveChartViewDataSource> dataSource;

@property (nonatomic, weak) id<LXCurveChartViewDelegate> delegate;

@property (nonatomic, assign)CGPoint orign;

/*垂直间隔*/
@property (nonatomic,assign)CGFloat vSpace;

/*水平间隔*/
@property (nonatomic,assign)CGFloat hSpace;

@property (nonatomic,assign)CGFloat valueRef;

/*重新加载刷新*/
- (void)reloadData;

/*只刷新新数据，降低CPU 的使用率,减少工具对CPU 的影响*/
- (void)loadNewData;

-(void)dismiss;

- (void)show;

@property (nonatomic,readonly)BOOL isShow;

@end

NS_ASSUME_NONNULL_END
