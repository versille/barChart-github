//
//  BarChartView.m
//  BarChart
//
//  Created by versille on 6/20/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import "BarChartView.h"

@interface barLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat   calorie;
@property (nonatomic, assign) CGFloat   percentage;
@property (nonatomic, assign) double    startPosition;
@property (nonatomic, assign) double    endPosition;
@property (nonatomic, assign) BOOL      isSelected;
@property (nonatomic, strong) NSString  *text;
- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to timing:(CFTimeInterval)duration Delegate:(id)delegate;
@end

@implementation barLayer
- (NSString*)description
{
    return [NSString stringWithFormat:@"calorie:%f, percentage:%0.0f, start:%f, end:%f", _calorie, _percentage, _startPosition/M_PI*180, _endPosition/M_PI*180];
}
+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"strokeEnd"] || [key isEqualToString:@"strokeStart"]) {
        return YES;
    }
    else {
        return NO;
    }
}
- (id)initWithLayer:(id)layer
{
    if (self = [super initWithLayer:layer])
    {
        if ([layer isKindOfClass:[barLayer class]]) {
            self.strokeEnd = [(barLayer *)layer strokeEnd];
            self.strokeStart = [(barLayer *)layer strokeStart];
            self.isSelected = NO;
        }
    }
    return self;
}
- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to timing:(CFTimeInterval)duration Delegate:(id)delegate
{
    CABasicAnimation *arcAnimation = [CABasicAnimation animationWithKeyPath:key];
    NSNumber *currentAngle = [[self presentationLayer] valueForKey:key];
    if(!currentAngle) currentAngle = from;
    
    arcAnimation.duration = duration;
    [arcAnimation setFromValue:currentAngle];
    [arcAnimation setToValue:to];
    [arcAnimation setDelegate:delegate];
    [arcAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    //    [arcAnimation setDuration:10.0];
    [self addAnimation:arcAnimation forKey:key];
    [self setValue:to forKey:key];
}
@end



@interface BarChartView (Private)

- (void)updateTimerFired;
- (UILabel *)createNumberLabel:(NSNumber*)number xpos:(CGFloat)x ypos:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

@end

@implementation BarChartView
{
    NSMutableArray *baseBars;
    
    // container for the bars
    UIView *barChart;
    UILabel *numberLabel;
    UILabel *zeroLabel;
    
    NSTimer *animationTimer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        //init base bars
        baseBars = [[NSMutableArray alloc] init];
        barChart = [[UIView alloc]initWithFrame:self.bounds];
        barChart.backgroundColor = [UIColor clearColor];
        self.barStartPosition = 10;
        self.barHeight = 20;
        self.chartMargin = 20;
        self.barLength = self.bounds.size.width-2*self.chartMargin;
        for (int i=1; i<2; i++) {
            CGFloat currentX = self.chartMargin;
            CGFloat currentY = self.chartMargin + (self.frame.size.height - 2*self.chartMargin)*i/4 - 15;
            
            CGRect barRect = CGRectMake(currentX, currentY, self.barLength, 30);
            UIView *baseBar = [[UIView alloc] initWithFrame:barRect];
            baseBar.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
            baseBar.layer.cornerRadius = 3.0;
            baseBar.layer.masksToBounds = YES;
            baseBar.layer.borderColor = [UIColor whiteColor].CGColor;
            baseBar.layer.borderWidth = 3.0;
            
            [baseBars addObject:baseBar];
            [barChart addSubview:baseBar];
        }
        [self addSubview:barChart];

    }
    return self;
}

- (UILabel *)createNumberLabel:(NSNumber *)number xpos:(CGFloat)x ypos:(CGFloat)y width:(CGFloat)width height:(CGFloat)height
{
//x    UIView *baseBar = [[barChart subviews] objectAtIndex:0];
    UILabel *returnLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,y,width,height)];
    //    zeroLabel = [[UILabel alloc] init];
    returnLabel.backgroundColor = [UIColor grayColor];
    returnLabel.textColor = [UIColor purpleColor];
    returnLabel.textAlignment = NSTextAlignmentCenter;
    returnLabel.text = [NSString stringWithFormat:@"%@", number];
    returnLabel.font=[returnLabel.font fontWithSize:14];
    return returnLabel;
}

- (void)loadBarchart
{
    UIView *baseBar = [[barChart subviews] objectAtIndex:0];
    barLayer *bar = [barLayer layer];

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, self.chartMargin/2+5)];
    [path addLineToPoint:CGPointMake(baseBar.frame.size.width, self.chartMargin/2+5)];

    bar.lineWidth = baseBar.frame.size.height;
    bar.fillColor = [UIColor greenColor].CGColor;
    bar.strokeColor = [UIColor yellowColor].CGColor;
    bar.strokeEnd    = 0.0;
    bar.calorie = 1800;
    CGRect rect = baseBar.frame;
    [baseBar.layer addSublayer:bar];

    zeroLabel = [self createNumberLabel:@0 xpos:baseBar.frame.origin.x-baseBar.frame.size.width/20 ypos:baseBar.frame.size.height+ baseBar.frame.origin.y width:baseBar.frame.size.width/10 height:baseBar.frame.size.height];
    [barChart addSubview:zeroLabel];

    numberLabel = [self createNumberLabel:@1800 xpos:baseBar.frame.origin.x ypos:baseBar.frame.origin.y width:baseBar.frame.size.width/6 height:baseBar.frame.size.height];
    [barChart addSubview:numberLabel];

    bar.path = path.CGPath;
    
    [bar createArcAnimationForKey:@"strokeEnd" fromValue:@0.0 toValue:@1.0f timing:2.0 Delegate:self];

}

- (void)updateTimerFired
{
    UIView *baseBar = [[barChart subviews] objectAtIndex:0];
    barLayer *bar = [[baseBar.layer sublayers] objectAtIndex:0];
    CGFloat currentXPercent= [[[bar presentationLayer] valueForKey:@"strokeEnd"] doubleValue];
    CGFloat currentXPos = round(baseBar.frame.size.width*currentXPercent- numberLabel.frame.size.width/12);
    CGRect currentRect = CGRectMake(currentXPos, zeroLabel.frame.origin.y, numberLabel.frame.size.width, numberLabel.frame.size.height);
    
    NSNumber *calorie = @(currentXPercent * bar.calorie);
    
    numberLabel.frame = currentRect;
    numberLabel.text = [NSString stringWithFormat:@"%d", [calorie integerValue]];
    
    NSLog(@"currentYPos : %d\n", [calorie integerValue]);
    
//    numberLabel.frame.origin = CGPointMake(, <#CGFloat y#>)
    

    
}


- (void)animationDidStart:(CAAnimation *)anim
{
    
    if (animationTimer == nil) {
        static float timeInterval = 1.0/60.0;
        // Run the animation timer on the main thread.
        // We want to allow the user to interact with the UI while this timer is running.
        // If we run it on this thread, the timer will be halted while the user is touching the screen (that's why the chart was disappearing in our collection view).
        animationTimer= [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateTimerFired) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:animationTimer forMode:NSRunLoopCommonModes];
    }
    
    
//    [animations addObject:anim];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
{
    
//    [animations removeObject:anim];
    
//    if ([animations count] == 0) {
        [animationTimer invalidate];
        animationTimer = nil;
//    }
    
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
