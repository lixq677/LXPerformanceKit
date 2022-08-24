//
//  LXWaveView.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import "LXWaveView.h"
#import <LXPerformanceKit/LXToolsBox.h>


#define LXRefBottomWaveColor [UIColor greenColor]
#define LXRefTopWaveColor  [UIColor redColor]

// 默认高度
static CGFloat const LXWaveAmplitude = 10;
//默认初相
static CGFloat const LXWaveX = 0;

@interface LXWaveView ()<CAAnimationDelegate>{
    CADisplayLink *_disPlayLink;
    /** 曲线角速度 */
    CGFloat _wavePalstance;
    /** 曲线初相 */
    CGFloat _waveX;
    /** 曲线偏距 */
    CGFloat _waveY;
    
    int _interval;
}
 /** 两条波浪 */
@property (nonatomic,strong)CAShapeLayer * waveLayer1;
@property (nonatomic,strong)CAShapeLayer * waveLayer2;

@property (nonatomic,strong)UILabel *textLabel;

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;

@property (nonatomic,strong)UITapGestureRecognizer *tapGesture;

@property (nonatomic,strong)UILongPressGestureRecognizer *longPressGesture;

@property (nonatomic,assign)BOOL twinkle;

@property (nonatomic,assign)BOOL showIt;

@property (nonatomic,weak)UIWindow *appWindow;

@end

@implementation LXWaveView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.bounds = CGRectMake(0, 0, MIN(frame.size.width, frame.size.height), MIN(frame.size.width, frame.size.height));
        //振幅
        _waveAmplitude = LXWaveAmplitude;
        //角速度
        /*
         决定波的宽度和周期，比如，我们可以看到上面的例子中是一个周期的波曲线，
         一个波峰、一个波谷，如果我们想在0到2π这个距离显示2个完整的波曲线，那么周期就是π。
         ω常量 _wavePalstance计算如下 可以根据自己的需求计算
         */
        _wavePalstance = M_PI/self.bounds.size.width;
        //偏距
        _waveY = self.bounds.size.height;
        //初相
        _waveX = LXWaveX;
        //x轴移动速度
        _waveMoveSpeed = _wavePalstance * 2;
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI{
    //初始化波浪
    [self.layer addSublayer:self.waveLayer1];
    //上层
    [self.layer addSublayer:self.waveLayer2];
    
    self.textLabel.frame = CGRectMake(0, CGRectGetMidY(self.bounds)-20, CGRectGetWidth(self.bounds), 40);
    [self addSubview:self.textLabel];
    //圆
    self.layer.cornerRadius = self.bounds.size.width/2.0f;
    self.layer.borderColor = [UIColor.redColor CGColor];
    self.layer.borderWidth = 2;
    
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
   
    self.clipsToBounds = YES;
    self.userInteractionEnabled = YES;
    
    [self addGestureRecognizer:self.panGesture];
    [self addGestureRecognizer:self.tapGesture];
    [self addGestureRecognizer:self.longPressGesture];
    [self.tapGesture requireGestureRecognizerToFail:self.panGesture];
    [self.longPressGesture requireGestureRecognizerToFail:self.tapGesture];
}


#pragma mark gesture action

- (void)panAction:(UIPanGestureRecognizer *)gesture{
    if (self.appWindow == nil) {
        if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
            self.appWindow = [[[UIApplication sharedApplication] delegate] window];
        }else{
            self.appWindow = [[UIApplication sharedApplication] keyWindow];
        }
    }
    CGPoint panPoint = [gesture locationInView:self.appWindow];
    
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(gesture.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }else if(gesture.state == UIGestureRecognizerStateEnded
             || gesture.state == UIGestureRecognizerStateCancelled) {
        self.alpha = .5;
        CGFloat touchWidth = self.frame.size.width;
        CGFloat touchHeight = self.frame.size.height;
        CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        // fabs 是取绝对值的意思
        CGFloat left = fabs(panPoint.x);
        CGFloat right = fabs(screenWidth - left);
        CGFloat top = fabs(panPoint.y);
        CGFloat bottom = fabs(screenHeight - top);
        CGFloat minSpace = MIN(MIN(MIN(top, left), bottom), right);
    
        CGPoint newCenter = CGPointZero;
        CGFloat targetY = 0;
        //校正Y
        if (panPoint.y < 15 + touchHeight / 2.0) {
            targetY = 15 + touchHeight / 2.0;
        }else if (panPoint.y > (screenHeight - touchHeight / 2.0 - 15)) {
            targetY = screenHeight - touchHeight / 2.0 - 15;
        }else{
            targetY = panPoint.y;
        }
        
        if (minSpace == left) {
            newCenter = CGPointMake(touchHeight / 3, targetY);
        }else if (minSpace == right) {
            newCenter = CGPointMake(screenWidth - touchHeight / 3, targetY);
        }else if (minSpace == top) {
            newCenter = CGPointMake(panPoint.x, touchWidth / 3);
        }else if (minSpace == bottom) {
            newCenter = CGPointMake(panPoint.x, screenHeight - touchWidth / 3);
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            self.center = newCenter;
        }];
    }else{
        NSLog(@"pan state : %zd", gesture.state);
    }
}

- (void)doubleTapAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(waterWaveView:didDoubleTapAction:)]) {
        [self.delegate waterWaveView:self didDoubleTapAction:sender];
    }
}

- (void)longPressAction:(id)sender{
    if (self.longPressGesture.state != UIGestureRecognizerStateBegan) return;
    if ([self.delegate respondsToSelector:@selector(waterWaveView:didLongPressAction:)]) {
        [self.delegate waterWaveView:self didLongPressAction:sender];
    }
}


#pragma mark -- 波动动画实现
- (void)waveAnimation:(CADisplayLink *)link{
    if (self.twinkle) return;
    _interval++;
    if (_interval % 3 == 0) {
        _interval = 0;
        _waveX += _waveMoveSpeed;
        [self updateWaveY];//更新波浪的高度位置
        [self updateWave];//波浪轨迹和动画
    }
}

//更新偏距的大小 直到达到目标偏距 让wave有一个匀速增长的效果
-(void)updateWaveY{
    CGFloat targetY = self.bounds.size.height - _progress * self.bounds.size.height;
    if (_waveY < targetY) {
        _waveY += 2;
    }
    if (_waveY > targetY ) {
        _waveY -= 2;
    }
}

-(void)updateWave{
    //波浪宽度
    CGFloat waterWaveWidth = self.bounds.size.width;
    //初始化运动路径
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGMutablePathRef maskPath = CGPathCreateMutable();
    //设置起始位置
    CGPathMoveToPoint(path, nil, 0, _waveY);
    //设置起始位置
    CGPathMoveToPoint(maskPath, nil, 0, _waveY);
    //初始化波浪其实Y为偏距
    CGFloat y = _waveY;
    //正弦曲线公式为： y=Asin(ωx+φ)+k;
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * sin(_wavePalstance * x + _waveX) + _waveY;
        
        CGPathAddLineToPoint(path, nil, x, y);
        
    }
    for (float x = 0.0f; x <= waterWaveWidth ; x++) {
        y = _waveAmplitude * cos(_wavePalstance * x + _waveX) + _waveY;
        
        CGPathAddLineToPoint(maskPath, nil, x, y);
    }
    [self updateLayer:_waveLayer1 path:path];
    [self updateLayer:_waveLayer2 path:maskPath];
}

-(void)updateLayer:(CAShapeLayer *)layer path:(CGMutablePathRef )path{
    //填充底部颜色
    CGFloat waterWaveWidth = self.bounds.size.width;
    CGPathAddLineToPoint(path, nil, waterWaveWidth, self.bounds.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.bounds.size.height);
    CGPathCloseSubpath(path);
    layer.path = path;
    CGPathRelease(path);
}



- (void)startTwinkle{
    DISPATCH_MAIN_ASYNC(^{
        self.twinkle = YES;
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        anim.duration =0.3;
        anim.fromValue = (__bridge id _Nullable)([UIColor clearColor].CGColor);
        anim.toValue = (__bridge id _Nullable)([UIColor redColor].CGColor);
        anim.repeatCount = 3;
        anim.autoreverses = YES;
        anim.removedOnCompletion = YES;
        anim.fillMode = kCAFillModeBoth;
        anim.beginTime = 0.0f;
        anim.delegate = self;
        [self.layer addAnimation:anim forKey:@"anim"];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.twinkle = NO;
}

#pragma mark - setter

-(void)setWaveBackgroundColor:(UIColor *)waveBackgroundColor{
    _waveBackgroundColor = waveBackgroundColor;
    self.backgroundColor = waveBackgroundColor;
}

-(void)setProgress:(CGFloat)progress{
    _progress = progress;
    UIColor *color1 = [LXToolsBox transformFromColor:LXRefBottomWaveColor toColor:LXRefTopWaveColor progress:progress];
    const CGFloat *components = CGColorGetComponents(color1.CGColor);
    UIColor *color2 = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.3];
    self.waveLayer1.fillColor = color1.CGColor;
    self.waveLayer1.strokeColor = color1.CGColor;
    self.waveLayer2.fillColor = color2.CGColor;
    self.waveLayer2.strokeColor = color2.CGColor;
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.textLabel.text = title;
}

#pragma mark - 停止动画
-(void)stop{
    DISPATCH_MAIN_ASYNC(^{
        self.showIt = NO;
        if (self->_disPlayLink) {
            [self->_disPlayLink invalidate];
            self->_disPlayLink = nil;
        }
        [self removeFromSuperview];
    });
}

- (void)start{
    DISPATCH_MAIN_ASYNC(^{
        self.showIt = YES;
        if (self.appWindow == nil) {
            if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
                self.appWindow = [[[UIApplication sharedApplication] delegate] window];
            }else{
                self.appWindow = [[UIApplication sharedApplication] keyWindow];
            }
        }
        [self.appWindow addSubview:self];
        self->_disPlayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(waveAnimation:)];
        [self->_disPlayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    });
}

-(void)dealloc{
    [self stop];
    if (_waveLayer1) {
        [_waveLayer1 removeFromSuperlayer];
        _waveLayer1 = nil;
    }
    if (_waveLayer2) {
        [_waveLayer2 removeFromSuperlayer];
        _waveLayer2 = nil;
    }
}


#pragma mark getter methods for lazy load

-(CAShapeLayer *)waveLayer1{
    if (!_waveLayer1) {
        _waveLayer1 = [CAShapeLayer layer];
        _waveLayer1.fillColor = LXRefBottomWaveColor.CGColor;
        _waveLayer1.strokeColor = LXRefBottomWaveColor.CGColor;
    }
    return _waveLayer1;
}

-(CAShapeLayer *)waveLayer2{
    if (!_waveLayer2) {
        _waveLayer2 = [CAShapeLayer layer];
        const CGFloat *components = CGColorGetComponents(LXRefBottomWaveColor.CGColor);
        CGColorRef color = [UIColor colorWithRed:components[0] green:components[1] blue:components[2] alpha:0.3].CGColor;
        _waveLayer2.fillColor = color;
        _waveLayer2.strokeColor = color;
    }
    return _waveLayer2;
}

- (UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:14.0f];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    }
    return _panGesture;
}

- (UITapGestureRecognizer *)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapAction:)];
        _tapGesture.numberOfTapsRequired = 2;
    }
    return _tapGesture;
}

- (UILongPressGestureRecognizer *)longPressGesture{
    if (!_longPressGesture) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPressGesture.minimumPressDuration = 2;
    }
    return _longPressGesture;
}

- (BOOL)isShow{
    return self.showIt;
}

@end
