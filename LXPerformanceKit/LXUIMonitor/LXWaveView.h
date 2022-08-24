//
//  LXWaveView.h
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LXWaveView;

@protocol LXWaveViewDelegate <NSObject>

@optional
- (void)waterWaveView:(LXWaveView *)waterView didDoubleTapAction:(id)sender;

- (void)waterWaveView:(LXWaveView *)waterView didLongPressAction:(id)sender;

@end

@interface LXWaveView : UIView

/** 进度 */
@property(nonatomic,assign)CGFloat progress;

/** 波浪1颜色 */
@property (nonatomic,strong)UIColor * firstWaveColor;

/** 波浪2颜色 */
@property (nonatomic,strong)UIColor * secondWaveColor;

/** 背景颜色 */
@property (nonatomic,strong)UIColor * waveBackgroundColor;

/** 曲线移动速度 */
@property (nonatomic,assign) CGFloat waveMoveSpeed;

/** 曲线振幅 */
@property (nonatomic,assign) CGFloat waveAmplitude;

@property (nonatomic,strong)NSString *title;

/** 停止动画 */
-(void)stop;

-(void)start;

- (BOOL)isShow;

- (void)startTwinkle;

@property (nonatomic,weak)id<LXWaveViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
