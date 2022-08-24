//
//  LXCurveChartView.m
//  LXPerformanceKit
//
//  Created by Xiaoqing Li on 2022/8/21.
//

#import "LXCurveChartView.h"

static inline UIColor * HexRGBA(int rgbValue,float alv){
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alv/1.0];
}

@implementation LXChartValueModel

@end

@interface LXCurveChartView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic,strong)UIButton *scanDetailBtn;

@property (nonatomic, strong) NSMutableArray <UILabel *>*leftLabels;

@property (nonatomic, strong) NSMutableArray <LXChartValueModel *>*values;

@property (nonatomic, strong) CAShapeLayer *lineLayer;

@property (nonatomic, strong) CAShapeLayer *coordinateLayer;

@property (nonatomic, strong) CAShapeLayer *bgLineLayer;

@property (nonatomic,strong)UIPanGestureRecognizer *panGesture;

@property (nonatomic,weak)UIWindow *appWindow;

@end


@implementation LXCurveChartView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.vSpace = 30;
        self.hSpace = 60;
        [self setupUI];
    }
    return self;
}


- (void)setupUI{
    self.backgroundColor =  HexRGBA(0x0, 0.4);
    [self addSubview:self.titleLabel];
    [self addSubview:self.closeBtn];
    [self addSubview:self.scanDetailBtn];
    [self addSubview:self.scrollView];
    [self.layer  addSublayer:self.bgLineLayer];
    [self.layer addSublayer:self.coordinateLayer];
    [self.scrollView.layer addSublayer:self.lineLayer];
    [self addGestureRecognizer:self.panGesture];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
}


- (void)reloadData{
    if (!_dataSource) {
        return;
    }
    NSInteger vertical = [_dataSource numberOfVerticalLinesOfChartView:self];
    if (self.leftLabels.count > vertical) {
        for (NSInteger i = vertical; i < _leftLabels.count; i ++) {
            UILabel *label = _leftLabels[i];
            [label removeFromSuperview];
            [self.leftLabels removeObject:label];
        }
    }else {
        for (NSInteger i = self.leftLabels.count; i < vertical; i ++) {
            UILabel *label = [UILabel new];
            label.textAlignment = NSTextAlignmentRight;
            label.font = [UIFont systemFontOfSize:12.0f];
            label.textColor = HexRGBA(0x008b8b, 1.0f);
            if ([self.dataSource respondsToSelector:@selector(chartView:titleForVerticalAtIndex:)]) {
                label.text = [self.dataSource chartView:self titleForVerticalAtIndex:i];
            }
            [self.leftLabels addObject:label];
            [self addSubview:label];
        }
    }
    
    NSInteger items = [_dataSource numberOfHorizontalDataOfChartView:self];
    [self.values removeAllObjects];
    if (items == 0) {
        return;
    }
    
    NSMutableArray<NSValue *> *points = [NSMutableArray array];
    CGFloat ref = self.valueRef/self.vSpace;
    for (int i = 0; i < items; i++) {
        LXChartValueModel *model = [LXChartValueModel new];
        model.value = [self.dataSource chartView:self valueAtIndex:i];
        if ([self.dataSource respondsToSelector:@selector(chartView:titleForHorizontalAtIndex:)]) {
            model.title = [self.dataSource chartView:self titleForHorizontalAtIndex:i];
        }
        [self.values addObject:model];
        
        CGFloat y =  CGRectGetHeight(self.scrollView.bounds) - (self.orign.y + model.value * ref);
        CGFloat x = self.hSpace * i;
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    if (self.scrollView.isDragging) {
        return;
    }
    
    CGFloat width = self.values.count * self.vSpace;
    self.scrollView.contentSize = CGSizeMake(width, 0);
    CGPoint offset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width, 0);
    if (offset.x > 0) {
        [self.scrollView setContentOffset:offset animated:YES];
    }
    self.lineLayer.path = [[self class] curvePathWithPoints:points isCurve:YES].CGPath;
    LXChartValueModel *model = [self.values lastObject];
    self.titleLabel.text = [NSString stringWithFormat:@"CPU使用率:%02d",(int)model.value];
}

- (void)loadNewData{
    NSInteger items = [_dataSource numberOfHorizontalDataOfChartView:self];
    if (items == 0) {
        return;
    }
    NSInteger valuesCount =  self.values.count;
    if (valuesCount >= items) {
        return;
    }
    NSMutableArray<NSValue *> *points = [NSMutableArray array];
    for (NSInteger i = valuesCount; i < items; i++) {
        LXChartValueModel *model = [LXChartValueModel new];
        model.value = [self.dataSource chartView:self valueAtIndex:i];
        if ([self.dataSource respondsToSelector:@selector(chartView:titleForHorizontalAtIndex:)]) {
            model.title = [self.dataSource chartView:self titleForHorizontalAtIndex:i];
        }
        [self.values addObject:model];
        
        CGFloat ref = self.valueRef/self.vSpace;
        CGFloat y =  CGRectGetHeight(self.scrollView.bounds) - (self.orign.y + model.value * ref);
        CGFloat x = self.hSpace * i;
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
    }
    
    if (self.scrollView.isDragging) {
        return;
    }
    
    CGFloat width = self.values.count * self.vSpace;
    self.scrollView.contentSize = CGSizeMake(width, 0);
    CGPoint offset = CGPointMake(self.scrollView.contentSize.width - self.scrollView.frame.size.width, 0);
    if (offset.x > 0) {
        [self.scrollView setContentOffset:offset animated:YES];
    }
    if (self.lineLayer.path == nil) {
        self.lineLayer.path = [[self class] curvePathWithPoints:points isCurve:YES].CGPath;
    }else{
        UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:self.lineLayer.path];
        self.lineLayer.path = [[self class] curvePathWithPoints:points isCurve:YES forBezierPath:path].CGPath;
    }
    LXChartValueModel *model = [self.values lastObject];
    self.titleLabel.text = [NSString stringWithFormat:@"CPU使用率:%02d",(int)model.value];
}

- (void)layoutForV{
    self.titleLabel.frame = CGRectMake(0, 10, 180, 30);
    self.closeBtn.frame = CGRectMake(CGRectGetWidth(self.bounds)-60, 10, 30, 30);
    self.scanDetailBtn.frame = CGRectMake(CGRectGetMidX(self.bounds)-60, 0, 120, 40);
    UIEdgeInsets edge = UIEdgeInsetsMake(60, self.orign.x, self.orign.y, 20);
    self.scrollView.frame = CGRectMake(edge.left, edge.top, CGRectGetWidth(self.bounds)-edge.left-edge.right, CGRectGetHeight(self.bounds)-edge.top);
    
    CGFloat maxY = CGRectGetHeight(self.bounds)-edge.bottom;
    //CGFloat maxX = CGRectGetWidth(self.bounds)-edge.right;
    
    __block CGFloat lastY = maxY;
    UIBezierPath *bg_path = [UIBezierPath bezierPath];
    [self.leftLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(0, lastY - 10, self.orign.x-10, 20);
        if (idx > 0) {
            [bg_path moveToPoint:CGPointMake(self.orign.x, lastY)];
            [bg_path addLineToPoint:CGPointMake(self.bounds.size.width-20, lastY)];
        }
        lastY = lastY - self.vSpace;
    }];
    
    CGFloat lastX = self.orign.x;
    int colum = CGRectGetWidth(self.scrollView.frame)/self.hSpace;
    for (int i = 0; i <= colum; i++) {
        [bg_path moveToPoint:CGPointMake(lastX, maxY)];
        [bg_path addLineToPoint:CGPointMake(lastX, lastY+ self.vSpace)];
        lastX = lastX + self.hSpace;
    }
    self.bgLineLayer.path = bg_path.CGPath;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(edge.left, lastY+ self.vSpace)];
    [path addLineToPoint:CGPointMake(edge.left, CGRectGetHeight(self.bounds)-edge.bottom)];
    [path addLineToPoint:CGPointMake(self.bounds.size.width-edge.right, CGRectGetHeight(self.bounds)-edge.bottom)];
    self.coordinateLayer.path = path.CGPath;
    
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self layoutForV];
}


#pragma mark private metods
+ (UIBezierPath *)curvePathWithPoints:(NSArray<NSValue *> *)points isCurve:(BOOL)isCurve{
    if (points.count <= 0) {
        return nil;
    }
    
    CGPoint p1 = [points.firstObject CGPointValue];
    
    UIBezierPath *beizer = [UIBezierPath bezierPath];
    
    [beizer moveToPoint:p1];
        
    for (int i = 1;i<points.count;i++ ) {
        
        CGPoint prePoint = [[points objectAtIndex:i-1] CGPointValue];
        CGPoint nowPoint = [[points objectAtIndex:i] CGPointValue];
            
        if (isCurve) {
            [beizer addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
        }else {
            [beizer addLineToPoint:nowPoint];
        }
    }
    return beizer;
}


+ (UIBezierPath *)curvePathWithPoints:(NSArray<NSValue *> *)points isCurve:(BOOL)isCurve forBezierPath:(UIBezierPath *)beizer{
    for (int i = 0;i<points.count;i++ ) {
        CGPoint prePoint = [beizer currentPoint];
        CGPoint nowPoint = [[points objectAtIndex:i] CGPointValue];
        if (isCurve) {
            [beizer addCurveToPoint:nowPoint controlPoint1:CGPointMake((nowPoint.x+prePoint.x)/2, prePoint.y) controlPoint2:CGPointMake((nowPoint.x+prePoint.x)/2, nowPoint.y)];
        }else {
            [beizer addLineToPoint:nowPoint];
        }
    }
    return beizer;
}



- (void)panAction:(UIPanGestureRecognizer *)gesture{
    if (self.appWindow == nil) {
        if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
            self.appWindow = [[[UIApplication sharedApplication] delegate] window];
        }else{
            self.appWindow = [[UIApplication sharedApplication] keyWindow];
        }
    }
    CGPoint panPoint = [gesture translationInView:self.appWindow];
    if (CGRectGetMinY(self.frame) < 0) {
        CGRect frame = self.frame;
        frame.origin.y = 0;
        self.frame = frame;
    }
    if (CGRectGetMaxY(self.frame) > CGRectGetMaxY(self.appWindow.bounds)) {
        CGRect frame = self.frame;
        frame.origin.y = CGRectGetMaxY(self.appWindow.bounds) - frame.size.height;
        self.frame = frame;
    }
    if(gesture.state == UIGestureRecognizerStateChanged) {
        self.transform =  CGAffineTransformMakeTranslation(0, panPoint.y);
    }else if (gesture.state == UIGestureRecognizerStateEnded){
        CGRect frame = self.frame;
        self.transform = CGAffineTransformIdentity;
        self.frame = frame;
    }
}

- (void)show{
    if (_isShow) {
        return;
    }
    _isShow = YES;
    if (self.appWindow == nil) {
        if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
            self.appWindow = [[[UIApplication sharedApplication] delegate] window];
        }else{
            self.appWindow = [[UIApplication sharedApplication] keyWindow];
        }
    }
    [self.appWindow addSubview:self];
    if ([self.delegate respondsToSelector:@selector(showWithChartView:)]) {
        [self.delegate showWithChartView:self];
    }
}

-(void)dismiss{
    if (NO == _isShow) {
        return;
    }
    _isShow = NO;
    [self.values removeAllObjects];
    self.lineLayer.path = nil;
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(dimissWithChartView:)]) {
        [self.delegate dimissWithChartView:self];
    }
}

- (void)scanThreadAction:(id)sender{
    if ([self.delegate respondsToSelector:@selector(chartView:scanThreadAction:)]) {
        [self.delegate chartView:self scanThreadAction:sender];
    }
}

- (UIImage *)imageNamed:(NSString *)imageName inBundle:(NSBundle *)bundle{
    if (!bundle) {
        bundle = [NSBundle mainBundle];
    }
    if (!bundle.loaded) {
        [bundle load];
    }
    
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    if (image == nil && bundle != [NSBundle mainBundle]) {
        image = [UIImage imageNamed:imageName];
    }
    return image;
}

#pragma mark getter for lazy

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.font = [UIFont systemFontOfSize:14.0f];
        _titleLabel.textColor = HexRGBA(0x008b8b, 1.0f);
    }
    return _titleLabel;
}

- (UIButton *)closeBtn{
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[self imageNamed:@"lx_close_dark" inBundle:[NSBundle bundleForClass:self.class]] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)scanDetailBtn{
    if (!_scanDetailBtn) {
        _scanDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanDetailBtn setTitle:@"查看线程" forState:UIControlStateNormal];
        [_scanDetailBtn setTitleColor:HexRGBA(0x008b8b, 1.0f) forState:UIControlStateNormal];
        [_scanDetailBtn addTarget:self action:@selector(scanThreadAction:) forControlEvents:UIControlEventTouchUpInside];
        _scanDetailBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _scanDetailBtn;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
       // _scrollView.delegate = self;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.directionalLockEnabled = YES;
    }
    return _scrollView;
}

- (CAShapeLayer *)lineLayer{
    if (!_lineLayer) {
        _lineLayer = [CAShapeLayer layer];
        _lineLayer.lineWidth = 1;
        _lineLayer.lineCap = kCALineCapRound;
        _lineLayer.lineJoin = kCALineJoinRound;
        _lineLayer.strokeColor = [UIColor purpleColor].CGColor;
        _lineLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _lineLayer;
}

- (CAShapeLayer *)bgLineLayer{
    if (!_bgLineLayer) {
        _bgLineLayer = [CAShapeLayer layer];
        _bgLineLayer.strokeColor = [HexRGBA(0x008b8b, 0.3) CGColor];
        _bgLineLayer.lineDashPattern = @[@(5), @(2)];
        _bgLineLayer.lineWidth = 1;
    }
    return _bgLineLayer;
}

- (CAShapeLayer *)coordinateLayer{
    if (!_coordinateLayer) {
        _coordinateLayer = [CAShapeLayer layer];
        _coordinateLayer.strokeColor = [HexRGBA(0x008b8b, 1.0f) CGColor];;
        _coordinateLayer.lineWidth = 1;
        _coordinateLayer.fillColor = [[UIColor clearColor] CGColor];
    }
    return _coordinateLayer;
}

- (NSMutableArray <UILabel *> *)leftLabels{
    if (!_leftLabels) {
        _leftLabels = [NSMutableArray array];
    }
    return _leftLabels;
}

- (NSMutableArray <LXChartValueModel *> *)values{
    if (!_values) {
        _values = [NSMutableArray array];
    }
    return _values;
}


- (UIPanGestureRecognizer *)panGesture{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    }
    return _panGesture;
}

@end

