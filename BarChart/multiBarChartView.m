//
//  multiBarChartView.m
//  BarChart
//
//  Created by versille on 6/30/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import "multiBarChartView.h"

@interface mBarLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat   barValue;
@property (nonatomic, assign) CGFloat   percentage;
@property (nonatomic, assign) double    startPosition;
@property (nonatomic, assign) double    endPosition;
@property (nonatomic, assign) BOOL      isSelected;
@property (nonatomic, strong) NSString  *text;
@property (nonatomic, strong) UILabel   *barLabel;
- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to timing:(CFTimeInterval)duration Delegate:(id)delegate;
@end

@implementation mBarLayer
- (NSString*)description
{
    return [NSString stringWithFormat:@"calorie:%f, percentage:%0.0f, start:%f, end:%f", _barValue, _percentage, _startPosition/M_PI*180, _endPosition/M_PI*180];
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
        if ([layer isKindOfClass:[mBarLayer class]]) {
            self.strokeEnd = [(mBarLayer *)layer strokeEnd];
            self.strokeStart = [(mBarLayer *)layer strokeStart];
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

@interface multiBarChartView(Private)
- (mBarLayer*) createBarLayer;


@end

@implementation multiBarChartView
{
    UIView *mBarChartView;
    UIView *chartArea;
    NSTimer *animationTimer;
    NSMutableArray *xAxisLabels;    
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
    if (self)
    {
        mBarChartView = [[UIView alloc] initWithFrame:self.bounds];
        

        self.barMargin = 20;
        self.xScale = 7;
        self.yScale = 100;
        self.xAxisLabel = [[UILabel alloc] init];
        self.barColor = [UIColor orangeColor];
        self.barCornerRadius = 3.0;
        self.barStrokeWidth = 3.0;
        self.chartMargin = 20;
        self.labelColor = [UIColor whiteColor];
        self.labelFont = [UIFont boldSystemFontOfSize:MAX((int)self.bounds.size.width/self.xScale, 5)];
        xAxisLabels = [[NSMutableArray alloc]init];
        [self addSubview:mBarChartView];

        CGRect chartAreaRect = CGRectMake(self.chartMargin, self.chartMargin, mBarChartView.frame.size.width - self.chartMargin*2, self.frame.size.height - self.chartMargin*2);
        
        chartArea = [[UIView alloc]initWithFrame:chartAreaRect];
        chartArea.backgroundColor = [UIColor greenColor];
        [mBarChartView addSubview:chartArea];
        CGRect rect = chartArea.frame;

        //add base bars
        int totalBars = 7;
        self.barWidth = chartArea.frame.size.width / totalBars;
        for (int i=0; i<1; i++) {
            CGFloat height = chartArea.frame.size.height;
            
            CGFloat currentX = i*self.barWidth+3;
            CGFloat currentY = chartArea.frame.size.height - round(self.chartMargin*(i+1));
            
            CGRect barRect = CGRectMake(currentX, currentY, self.barWidth, self.chartMargin*(i+1));
//            CGRect barRect = CGRectMake(currentX, 0, rect.size.width, rect.size.height);
            UIView *baseBar = [[UIView alloc] initWithFrame:barRect];
            baseBar.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
            baseBar.layer.cornerRadius = 3.0;
            baseBar.layer.masksToBounds = YES;
            baseBar.layer.borderColor = [UIColor whiteColor].CGColor;
            baseBar.layer.borderWidth = 3.0;
            
//            [baseBars addObject:baseBar];
            [chartArea addSubview:baseBar];
        }
    }
    return self;
}



- (UIView*)createSingleBarView
{
    UIView *newBar = [[UIView alloc]init];
/*    if(newBar)
    {
    }
*/    return newBar;
 
}

- (void)loadMultiBarChart
{
    mBarLayer *axisLayer = [mBarLayer layer];
    
    //draw Axis
    UIBezierPath *axisPath = [UIBezierPath bezierPath];
    [axisPath moveToPoint:CGPointMake(self.chartMargin, self.chartMargin)];
    [axisPath addLineToPoint:CGPointMake(self.chartMargin, self.frame.size.height-self.chartMargin)];
                                         //+self.frame.size.height-self.chartMargin)];
    [axisPath addLineToPoint:CGPointMake(self.frame.size.width-self.chartMargin, self.frame.size.height-self.chartMargin)];
    
    axisLayer.path = axisPath.CGPath;

    axisLayer.fillColor = [UIColor clearColor].CGColor;
    axisLayer.strokeColor = [UIColor grayColor].CGColor;
    axisLayer.lineWidth = 5.0;
    axisLayer.lineCap = kCALineCapRound;
    [mBarChartView.layer addSublayer:axisLayer];
    
    // add bars to the chart
    NSArray *barArray = [chartArea subviews];

    
    
    UIView *baseBar = [[chartArea subviews] objectAtIndex:0];
    mBarLayer *bar = [mBarLayer layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.barWidth/2, baseBar.frame.size.height)];
    [path addLineToPoint:CGPointMake(self.barWidth/2, 0)];

    
    
    bar.path = path.CGPath;
    bar.lineWidth = self.barWidth;
    bar.strokeColor = [UIColor yellowColor].CGColor;
    bar.strokeEnd    = 1.0;
    CGRect rect = baseBar.frame;
    [baseBar.layer addSublayer:bar];
    
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
