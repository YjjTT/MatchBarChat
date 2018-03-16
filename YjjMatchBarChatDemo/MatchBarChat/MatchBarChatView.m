//
//  MatchBarChatView.m
//  YjjMatchBarChatDemo
//
//  Created by YjjTT on 2018/3/16.
//  Copyright © 2018年 YjjTT. All rights reserved.
//


#define ViewGap 10.0f
#define BarHeight 20.0f// 中间小白条的高度
#define FontSize 12.0f// 中间小白条的高度
#define Textwidth 70.0f//"进十场"文字宽度

#define TextRightGap 0.0f//"进十场"文字与第一条柱状图的宽度

//设定柱状图在界面显示的最大最小值
#define BarChatMaxHeight 70.0f
#define BarChatMinHeight 10.0f

#define BallFlyingTime 1.0f//小球飞行时间
#define BallScaleTime 0.1f//小球缩放时间
#define BarChatRiseTime 0.25f//柱状图上升时间

//颜色的快速输入
#define UIColorFromRGB0_255(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
//设备尺寸
#define SCREEN_WIDTH  [[UIScreen mainScreen] bounds].size.width //屏幕宽度
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height //屏幕高度

#define customDelay 2

#import "MatchBarChatView.h"
#import "MatchAmountConverter.h"
#import "CustomTextLayer.h"

@interface MatchBarChatView () <CAAnimationDelegate>

@property (nonatomic, assign)CGFloat barChatWidth;//柱状图宽度
@property (nonatomic, assign)CGFloat barChatStartX;//柱状图起始点的x坐标
@property (nonatomic, strong)NSArray *interfaceArray;//界面显示数组,储存的是每个柱状图的高度
@property (nonatomic, assign)CGFloat scaleBallHeight;//缩放小球的高度
@property (nonatomic, strong)NSArray *dataArray;//源数据
@property (nonatomic, strong) UIButton *button;

@end

@implementation MatchBarChatView

- (instancetype)initWithFrame:(CGRect)frame array:(NSArray *)array
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat sumWidth = frame.size.width - ViewGap * 2 - Textwidth - TextRightGap - TextRightGap / 2;
        _barChatWidth = sumWidth / (10 * 2);
        _barChatStartX = ViewGap + Textwidth + TextRightGap;
        _scaleBallHeight = _barChatWidth < BarHeight ? _barChatWidth : BarHeight;
        _dataArray = [NSArray arrayWithArray:array];
        _interfaceArray = [self calculateInterfaceArrayWithArray:array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //画大背景
    [self drawBigView];
    //柱状图
    [self drawBarChat];
    //画中间的白条
    [self drawCenterRectangle];
    //文本绘制
    [self drawContextText];
    //画飞球
    [self drawFlyingBall];
    //画小球
    [self drawSmallBall];
}

- (void)drawRisingText:(NSDictionary *)dic
{
    CustomTextLayer *textLayer = [[CustomTextLayer alloc] init];
    textLayer.fontSize = 15.0f;
    textLayer.frame = CGRectMake(0, 0, _barChatWidth * 2, BarHeight);
    textLayer.position = CGPointFromString([dic objectForKey:@"point"]);
    NSInteger index = [[dic objectForKey:@"index"] integerValue];
    
    NSInteger gameScore = 0;
    if ([[dic objectForKey:@"status"] isEqualToString:@"up"]) {
        gameScore = [_dataArray[index][0] integerValue];
        textLayer.foregroundColor = UIColorFromRGB0_255(79, 214, 194).CGColor;
    }else if ([[dic objectForKey:@"status"] isEqualToString:@"down"]){
        gameScore = [_dataArray[index][1] integerValue];
        textLayer.foregroundColor = UIColorFromRGB0_255(250, 198, 131).CGColor;
    }
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    
    [textLayer startTime:gameScore];
    
    [self.layer addSublayer:textLayer];
    
}


- (void)drawRisingText
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 动画选项的设定
    animation.duration = BarChatRiseTime; // 持续时间
    animation.repeatCount = 1; // 重复次数
    animation.fillMode = kCAFillModeForwards;
    
    animation.removedOnCompletion = NO;
    
    for (NSInteger i = 0; i < _interfaceArray.count; i++) {
        
        //动画开始时间
        animation.beginTime = CACurrentMediaTime() + i * BallScaleTime + BallFlyingTime;
        
        //起始position
        CGPoint upStartPoint = CGPointMake(_barChatStartX + _barChatWidth / 2, height / 2 - BarHeight / 2);
        //终止position
        CGFloat upHeight = [[[_interfaceArray objectAtIndex:i] objectAtIndex:0] floatValue];
        CGPoint endStartPoint = CGPointMake(_barChatStartX + _barChatWidth / 2, height / 2 - BarHeight / 2 - upHeight - BarHeight);
        
        
        CATextLayer *upTextLayer = [[CATextLayer alloc] init];
        upTextLayer.fontSize = 15.0f;
        upTextLayer.frame = CGRectMake(upStartPoint.x, upStartPoint.y, _barChatWidth, BarHeight);
        upTextLayer.string = [NSString stringWithFormat:@"%@", _dataArray[i][0]];
        upTextLayer.contentsScale = [UIScreen mainScreen].scale;
        upTextLayer.alignmentMode = kCAAlignmentCenter;
        upTextLayer.foregroundColor = [UIColor darkGrayColor].CGColor;
        upTextLayer.backgroundColor = [UIColor yellowColor].CGColor;
        
        
        // 起始帧设定
        animation.fromValue = [NSValue valueWithCGPoint:upStartPoint];
        //终止帧设定
        animation.toValue = [NSValue valueWithCGPoint:endStartPoint];
        
        animation.delegate = self;
        
        NSDictionary *dic = @{@"name":@"hhe"};
        [animation setValue:dic forKey:@"animationName"];
        
        // 添加动画
        [upTextLayer addAnimation:animation forKey:nil];
        
        [self.layer addSublayer:upTextLayer];
        
        _barChatStartX += _barChatWidth * 2;
    }
    
    _barChatStartX = ViewGap + Textwidth + TextRightGap;
}

- (void)drawFlyingBall
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0,
                             0,
                             BarHeight,
                             BarHeight);
    layer.position = CGPointMake(- BarHeight, height / 2);
    layer.contents =(id)[UIImage imageNamed:@"qiu"].CGImage;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 动画选项的设定
    animation.duration = BallFlyingTime; // 持续时间
    animation.repeatCount = 1; // 重复次数
    // 起始帧和终了帧的设定
    animation.fromValue = [NSValue valueWithCGPoint:layer.position]; // 起始帧
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(width + BarHeight, height / 2)]; // 终了帧
    self.layer.masksToBounds = YES;//保证小球在该view的frame外不显示
    
    // 添加动画
    [layer addAnimation:animation forKey:nil];
    
    [self.layer addSublayer:layer];
    
    
}

//---------上行柱状图---------
- (UIBezierPath *)startUpPathWithStartX:(CGFloat)startX
{
    
    CGFloat width = self.frame.size.width;
    CGFloat theHeight = self.frame.size.height;
    
    //第一种方法:
    //  CGRect rect = CGRectMake(startX, (theHeight / 2 - BarHeight / 2), _barChatWidth, 0.001);
    //  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(self.frame.size.width, self.frame.size.width)];
    
    //第二种方法:
    CGRect rect = CGRectMake(startX, theHeight / 2, _barChatWidth, BarHeight / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    
    return path;
}

- (UIBezierPath *)endUpPathWithStartX:(CGFloat)startX height:(CGFloat)height
{
    
    CGFloat width = self.frame.size.width;
    CGFloat theHeight = self.frame.size.height;
    
    //第一种方法:
    //  CGRect rect = CGRectMake(startX, (theHeight / 2 - BarHeight / 2) - height, _barChatWidth, height);
    //  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(self.frame.size.width, self.frame.size.width)];
    
    //第二种方法:
    CGRect rect = CGRectMake(startX, (theHeight / 2 - BarHeight / 2) - height, _barChatWidth, height + BarHeight / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    return path;
}

//---------下行柱状图---------
- (UIBezierPath *)startDownPathWithStartX:(CGFloat)startX
{
    
    CGFloat width = self.frame.size.width;
    CGFloat theHeight = self.frame.size.height;
    
    //第一种方法:
    //  CGRect rect = CGRectMake(startX, (theHeight / 2 + BarHeight / 2), _barChatWidth, 0.001);
    //  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(self.frame.size.width, self.frame.size.width)];
    
    //第二种方法:
    CGRect rect = CGRectMake(startX, theHeight / 2, _barChatWidth, BarHeight / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    
    return path;
}

- (UIBezierPath *)endDownPathWithStartX:(CGFloat)startX height:(CGFloat)height
{
    
    CGFloat width = self.frame.size.width;
    CGFloat theHeight = self.frame.size.height;
    
    
    //第一种方法:
    //  CGRect rect = CGRectMake(startX, theHeight / 2, _barChatWidth, height + BarHeight / 2);
    //  UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(self.frame.size.width, self.frame.size.width)];
    
    //第二种方法:
    CGRect rect = CGRectMake(startX, theHeight / 2, _barChatWidth, height + BarHeight / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10];
    
    
    return path;
}



- (void)drawSmallBall
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // 动画选项设定
    animation.duration = BallScaleTime; // 动画持续时间
    animation.repeatCount = 1; // 重复次数
    animation.autoreverses = NO; // 动画结束时执行逆动画
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:10.0]; // 结束时的倍率
    //设置动画的速度变化
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    
    for (NSInteger i = 0; i < _interfaceArray.count; i++) {
        
        //动画开始时间
        animation.beginTime = CACurrentMediaTime() + i * BallScaleTime + BallFlyingTime;
        
        CALayer *layer = [[CALayer alloc] init];
        
        CGPoint layerCenter = CGPointMake(_barChatStartX + _barChatWidth / 2, height / 2);
        
        CGSize layerSize = CGSizeMake(_scaleBallHeight/10, _scaleBallHeight/10);
        
        layer.frame = CGRectMake(layerCenter.x - layerSize.width / 2,
                                 layerCenter.y - layerSize.height / 2,
                                 layerSize.width,
                                 layerSize.height);
        
        layer.contents =(id)[UIImage imageNamed:@"qiu"].CGImage;
        
        // 添加动画
        [layer addAnimation:animation forKey:nil];
        
        [self.layer addSublayer:layer];
        
        _barChatStartX += _barChatWidth * 2;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(layerCenter.x - layerSize.width / 2,
                                  layerCenter.y - layerSize.height / 2,
                                  BarHeight,
                                  BarHeight);
        button.center = CGPointMake(layerCenter.x - layerSize.width / 2, layerCenter.y - layerSize.height / 2);
        [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i + 99;
        [self addSubview:button];
    }
    _barChatStartX = ViewGap + Textwidth + TextRightGap;
    
}

- (void)clickAction:(UIButton *)button
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedBallAtIndex:)]) {
        [self.delegate didSelectedBallAtIndex:(button.tag - 99)];
    }
}


- (void)drawBarChat
{
    CABasicAnimation  *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = BarChatRiseTime;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.delegate = self;
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    for (NSInteger i = 0; i < _interfaceArray.count; i++) {
        
        //动画开始时间
        pathAnimation.beginTime = CACurrentMediaTime() + i * BallScaleTime + BallFlyingTime;
        
        CGFloat upHeight = [[[_interfaceArray objectAtIndex:i] objectAtIndex:0] floatValue];
        
        //绘制上行柱状图
        CAShapeLayer * upLayer = [CAShapeLayer layer];
        upLayer.fillColor = UIColorFromRGB0_255(79, 214, 194).CGColor;
        upLayer.lineCap = kCALineCapRound;
        
        UIBezierPath *startUpPath = [self startUpPathWithStartX:_barChatStartX];
        UIBezierPath *endUpPath = [self endUpPathWithStartX:_barChatStartX height:upHeight];
        pathAnimation.fromValue = (id)startUpPath.CGPath;
        pathAnimation.toValue = (id)endUpPath.CGPath;
        
        CGPoint upPoint = CGPointMake(_barChatStartX + _barChatWidth/2, height / 2 - BarHeight / 2 - upHeight - BarHeight);
        NSDictionary *dic0 = @{@"status":@"up",
                               @"index":@(i),
                               @"point":NSStringFromCGPoint(upPoint)};
        [pathAnimation setValue:dic0 forKey:@"barChatAnimation"];
        
        [upLayer addAnimation:pathAnimation forKey:nil];
        [self.layer addSublayer:upLayer];
        
        CGFloat downHeight = [[[_interfaceArray objectAtIndex:i] objectAtIndex:1] floatValue];
        
        //绘制下行柱状图
        CAShapeLayer * downLayer = [CAShapeLayer layer];
        downLayer.fillColor = UIColorFromRGB0_255(250, 198, 131).CGColor;
        downLayer.lineCap = kCALineCapRound;
        
        UIBezierPath *startDownPath = [self startDownPathWithStartX:_barChatStartX];
        UIBezierPath *endDownPath = [self endDownPathWithStartX:_barChatStartX height:downHeight];
        pathAnimation.fromValue = (id)startDownPath.CGPath;
        pathAnimation.toValue = (id)endDownPath.CGPath;
        
        CGPoint downPoint = CGPointMake(_barChatStartX + _barChatWidth/2, height / 2 + BarHeight / 2 + downHeight + BarHeight);
        NSDictionary *dic2 = @{@"status":@"down",
                               @"index":@(i),
                               @"point":NSStringFromCGPoint(downPoint)};
        [pathAnimation setValue:dic2 forKey:@"barChatAnimation"];
        
        [downLayer addAnimation:pathAnimation forKey:nil];
        
        [self.layer addSublayer:downLayer];
        
        _barChatStartX += _barChatWidth * 2;
    }
    _barChatStartX = ViewGap + Textwidth + TextRightGap;
}

- (void)drawContextText
{
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.fontSize = 11.0f;
    
    textLayer.frame = CGRectMake(ViewGap, height / 2 - BarHeight / 2 + 3, Textwidth, BarHeight);
    NSString *string = [NSString stringWithFormat:@"%lu", (unsigned long)_interfaceArray.count];
    textLayer.string = [NSString stringWithFormat:@"近%@场", convert(string)];;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.alignmentMode = kCAAlignmentLeft;
    textLayer.foregroundColor = [UIColor grayColor].CGColor;
    [self.layer addSublayer:textLayer];
    
}


- (void)drawCenterRectangle
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    //获得根图层
    CALayer *layer=[[CALayer alloc]init];
    //设置背景颜色,由于QuartzCore是跨平台框架，无法直接使用UIColor
    layer.backgroundColor=[UIColor whiteColor].CGColor;
    //设置中心点
    layer.position=CGPointMake(width/2, height/2);
    //设置大小
    layer.bounds=CGRectMake(0, 0, width,BarHeight);
    //设置阴影
    layer.shadowColor=[UIColor grayColor].CGColor;
    layer.shadowOffset=CGSizeMake(2, 2);
    layer.shadowOpacity=.9;
    
    [self.layer addSublayer:layer];
}

- (void)drawBigView
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    // 简便起见，这里把圆角半径设置为长和宽平均值的1/10
    CGFloat radius = (width + height) * 0.005;
    // 获取CGContext，注意UIKit里用的是一个专门的函数
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//设置填充颜色,即画布颜色
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);//设置画笔颜色
    CGContextSetLineWidth(context, 0.15);//设置线条粗细宽度
    
    // 移动到初始点
    CGContextMoveToPoint(context, ViewGap, radius + ViewGap);
    // 绘制1/4圆弧(左上)
    CGContextAddArc(context, radius + ViewGap, radius + ViewGap, radius, M_PI, M_PI * 3 / 2, 0);
    // 绘制1/4圆弧(右上)
    CGContextAddArc(context, width - radius - ViewGap, radius + ViewGap, radius, M_PI * 3 / 2, M_PI * 2, 0);
    // 绘制1/4圆弧(右下)
    CGContextAddArc(context, width - radius - ViewGap, height - radius - ViewGap, radius, 0, M_PI / 2, 0);
    // 绘制1/4圆弧(左下)
    CGContextAddArc(context, radius + ViewGap, height - radius - ViewGap, radius, M_PI / 2, M_PI, 0);
    
    CGContextSetShadowWithColor(context, CGSizeMake(0.0, 0.0), 1.0, [UIColor blackColor].CGColor);//这块使用阴影也可以,然后可以不绘制路径,只填充就行
    
    // 闭合路径
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);//kCGPathStroke//kCGPathFill//kCGPathFillStroke
    
    
}

- (NSArray *)calculateInterfaceArrayWithArray:(NSArray *)array
{
    CGFloat gap = BarChatMaxHeight - BarChatMinHeight;
    
    NSArray *maxMinArray = [MatchBarChatView findMaxMinWithArr:array];
    
    CGFloat maxData = [maxMinArray[0] floatValue];
    CGFloat minData = [maxMinArray[1] floatValue];
    
    CGFloat dif = maxData - minData;//数据差值
    
    NSMutableArray *sumArray = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i++) {
        
        NSArray *smallArray = array[i];//取出原始数据中的小数组
        
        NSMutableArray *tempArray = [NSMutableArray array];//存储原始数据中的小数组的转化数据
        
        for (NSInteger j = 0; j < smallArray.count; j++) {
            
            CGFloat data = [[smallArray objectAtIndex:j] floatValue];
            
            CGFloat dataH = gap * (data - minData) / dif + BarChatMinHeight;//比例公式
            if (data == 0) {
                dataH = 0;
            }
            [tempArray addObject:[NSNumber numberWithFloat:dataH]];
        }
        
        [sumArray addObject:tempArray];
        
    }
    return sumArray;
}


//通用类:找出最大最小值,传入的array可能是一维数组或者二维数组
+ (NSArray *)findMaxMinWithArr:(NSArray *)arr
{
    NSMutableArray *tempArr = [NSMutableArray array];
    id theObject = [arr objectAtIndex:0];
    if ([theObject isKindOfClass:[NSArray class]]) {//二维数组
        for (NSArray *smallArray in arr) {
            [tempArr addObjectsFromArray:smallArray];
        }
    }else{//一维数组
        for (NSInteger i = 0; i < arr.count; i++) {
            [tempArr addObject:[arr objectAtIndex:i]];
        }
    }
    NSNumber *max = [MatchBarChatView get_Max_WithArray:tempArr];
    
    NSNumber *min = [MatchBarChatView get_Min_WithArray:tempArr];
    NSLog(@"%@ %@", max, min);
    
    return @[max, min];
}


//通用类:求最大
+ (NSNumber *)get_Max_WithArray:(NSArray *)array
{
    CGFloat maxFloat = 0;
    
    if (array.count != 0) {
        maxFloat = [array[0] floatValue];
    }
    
    for (NSInteger i = 1; i < array.count; i++) {
        CGFloat singleF = [array[i] floatValue];
        maxFloat = maxFloat > singleF ? maxFloat : singleF;
    }
    
    NSNumber *maxNumber = [NSNumber numberWithFloat:maxFloat];
    
    return maxNumber;
}

//通用类:求最小
+ (NSNumber *)get_Min_WithArray:(NSArray *)array
{
    CGFloat minFloat = CGFLOAT_MAX;
    
    if (array.count != 0) {
        minFloat = [array[0] floatValue];
    }
    
    //    CGFloat minFloat = [array[0] floatValue];
    for (NSInteger i = 1; i < array.count; i++) {
        CGFloat singleF = [array[i] floatValue];
        minFloat = minFloat < singleF ? minFloat : singleF;
    }
    
    NSNumber *minNumber = [NSNumber numberWithFloat:minFloat];
    return minNumber;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    
    NSDictionary *animDic = [anim valueForKey:@"barChatAnimation"];
    [self drawRisingText:animDic];
    
}

@end
