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
- (void) loadXAxisLabels;
- (NSInteger)getCurrentSelectedOnTouch:(CGPoint)point;
- (void) setViewSelectedAtIndex:(NSInteger)currentIndex;
- (void) setViewDeselectedAtIndex:(NSInteger)currentIndex;

@end

@implementation multiBarChartView
{
    UIView *mBarChartView;
    UIView *chartArea;
    NSTimer *animationTimer;
    NSMutableArray *xAxisLabels;
    NSInteger selectedViewIndex;
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
        selectedViewIndex = -1;

        self.barMargin = 20;
        self.xScale = 7;
        self.yScale = 100;
        self.xAxisLabel = [[UILabel alloc] init];
        self.barColor = [UIColor orangeColor];
        self.barCornerRadius = 3.0;
        self.barStrokeWidth = 3.0;
        self.chartMargin = 15;
        self.barMargin = 3.0;
        self.labelColor = [UIColor whiteColor];
        self.labelFont = [UIFont boldSystemFontOfSize:MAX((int)self.bounds.size.width/self.xScale, 5)];
        xAxisLabels = [[NSMutableArray alloc]init];
        [self addSubview:mBarChartView];

        CGRect chartAreaRect = CGRectMake(self.chartMargin, self.chartMargin, mBarChartView.frame.size.width - self.chartMargin*2, self.frame.size.height - self.chartMargin*3);
        
        chartArea = [[UIView alloc]initWithFrame:chartAreaRect];
        chartArea.backgroundColor = [UIColor clearColor];
        [mBarChartView addSubview:chartArea];
        CGRect rect = chartArea.frame;

        //add base bars
        int totalBars = 7;
        self.barWidth = (chartArea.frame.size.width - totalBars*self.barMargin) / totalBars;

        for (int i=0; i<7; i++) {
            CGFloat height = chartArea.frame.size.height;

            
//            CGFloat currentX = i*self.barWidth+3;
//            CGFloat currentY = chartArea.frame.size.height - round(self.chartMargin*(i+1));
              CGFloat currentX = i*self.barWidth+self.barMargin*i;
              CGFloat currentY = 0;
            
            CGRect barRect = CGRectMake(currentX, currentY, self.barWidth, chartArea.frame.size.height);
//            CGRect barRect = CGRectMake(currentX, currentY, self.barWidth, self.chartMargin*(i+1));
//            CGRect barRect = CGRectMake(currentX, 0, rect.size.width, rect.size.height);
            UIView *baseBar = [[UIView alloc] initWithFrame:barRect];
//            baseBar.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
//            baseBar.backgroundColor = [UIColor clearColor];
            baseBar.layer.cornerRadius = 3.0;
            baseBar.layer.masksToBounds = YES;
            baseBar.layer.borderColor = [UIColor clearColor].CGColor;
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
    [self loadXAxisLabels];
    mBarLayer *axisLayer = [mBarLayer layer];
    
    //draw Axis
    UIBezierPath *axisPath = [UIBezierPath bezierPath];
    [axisPath moveToPoint:CGPointMake(self.chartMargin, self.chartMargin)];
    [axisPath addLineToPoint:CGPointMake(self.chartMargin, self.frame.size.height-self.chartMargin*2)];
    [axisPath addLineToPoint:CGPointMake(self.frame.size.width-self.chartMargin, self.frame.size.height-self.chartMargin*2)];
    
    axisLayer.path = axisPath.CGPath;

    axisLayer.fillColor = [UIColor clearColor].CGColor;
    axisLayer.strokeColor = [UIColor grayColor].CGColor;
    axisLayer.lineWidth = 5.0;
    axisLayer.lineCap = kCALineCapRound;
    [mBarChartView.layer addSublayer:axisLayer];
    
    // add bars to the chart
    NSArray *barArray = [chartArea subviews];
    NSArray *dataArray = [self.datasource getData];
    
    double sum = [[dataArray valueForKeyPath: @"@sum.self"] doubleValue];

    for (int i=0; i< barArray.count; i++) {
    
        UIView* baseBarView = [barArray objectAtIndex:i];
        mBarLayer *bar = [mBarLayer layer];
        mBarLayer *selectBarLayer = [mBarLayer layer];
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(self.barWidth/2, baseBarView.frame.size.height)];
        [path addLineToPoint:CGPointMake(self.barWidth/2, 0)];
        path.lineCapStyle = kCGLineCapRound;
        
        bar.path = path.CGPath;
        bar.lineWidth = self.barWidth;
        bar.strokeColor = [UIColor yellowColor].CGColor;
        bar.strokeEnd    = 0.0;
        CGRect rect = baseBarView.frame;
        [baseBarView.layer addSublayer:selectBarLayer];
        [baseBarView.layer addSublayer:bar];
        double percentage = [[dataArray objectAtIndex:i] doubleValue]/sum;
        if (percentage <=0.2) {
            percentage = percentage *4.9;
        }
        else if (percentage <=0.5 && percentage > 0.2) {
            percentage = percentage * 1.9;
        }
        else if (percentage<=0.8 && percentage >0.5){
            percentage = percentage *1.2;
        }
        [bar createArcAnimationForKey:@"strokeEnd" fromValue:@0.0 toValue:[NSNumber numberWithDouble:percentage] timing:2.0 Delegate:self];
        bar.strokeEnd = percentage;
    }
    
/*
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
*/
 
}

- (void)loadXAxisLabels
{
    
//    xAxisLabels = [NSMutableArray arrayWithObjects:@"9/1",@"9/2",@"9/3",@"9/4",@"9/5",@"9/6",@"9/7", nil];
    [self getDateLabelsForLastWeek];
    CGRect xAxisLabelViewRect = CGRectMake( chartArea.frame.origin.x, chartArea.frame.size.height,chartArea.frame.size.width, self.chartMargin*2);
    UIView *xAxisLabelView = [[UIView alloc] initWithFrame:xAxisLabelViewRect];
    CGFloat labelWidth = (chartArea.frame.size.width-xAxisLabels.count*self.barMargin) / 7.0;
    [xAxisLabels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(idx*(labelWidth+self.barMargin)+self.barMargin, self.chartMargin, labelWidth, self.chartMargin*2)];
        xLabel.text = [NSString stringWithFormat:@"%@",obj];
        xLabel.textColor = [UIColor blackColor];
        xLabel.font = [xLabel.font fontWithSize:12];
        [xAxisLabelView addSubview:xLabel];
    }];
    [mBarChartView addSubview:xAxisLabelView];
}

- (void)getDateLabelsForLastWeek
{
    NSDate *today = [NSDate date];
    NSTimeInterval secondsPerDay = 60*60*24;
    NSDate *dayIter = [today dateByAddingTimeInterval:secondsPerDay*(-7)];

    for (int i=0;i<7;i++)
    {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:dayIter];
        NSInteger day = [components day];
        NSInteger month = [components month];
        NSString *newDateString = [NSString stringWithFormat:@"%2d/%2d", month,day];
        NSLog(@"%@", newDateString);
        [xAxisLabels addObject:newDateString];
        dayIter = [dayIter dateByAddingTimeInterval:secondsPerDay];
    }

}

- (NSInteger)getCurrentSelectedOnTouch:(CGPoint)point
{
    __block NSUInteger selectedIndex = -1;
    
//    CGAffineTransform transform = CGAffineTransformIdentity;
    
    NSArray *barViews = [chartArea subviews];
    
    [barViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIView *barView = (UIView *)obj;
        
        if (CGRectContainsPoint(barView.frame, point)) {
            selectedIndex = idx;
        }
    }];
    return selectedIndex;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesMoved:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:chartArea];
    [self getCurrentSelectedOnTouch:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:chartArea];
    NSInteger currentIndex = [self getCurrentSelectedOnTouch:point];
    if (currentIndex!=-1) {
        if(currentIndex != selectedViewIndex)
        {
            [self setViewSelectedAtIndex:currentIndex];
            if (selectedViewIndex!=-1) {
                [self setViewDeselectedAtIndex:selectedViewIndex];
            }
            selectedViewIndex = currentIndex;
        }
        else
        {
            [self setViewDeselectedAtIndex:selectedViewIndex];
            selectedViewIndex = -1;
        }
    }
    
}

- (void)setViewSelectedAtIndex:(NSInteger)currentIndex
{
    UIView *barView = [[chartArea subviews] objectAtIndex:currentIndex];
    mBarLayer *selectBarLayer = [[barView.layer sublayers] objectAtIndex:0];
    selectBarLayer.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5].CGColor;
//    barView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.7];
    
}

-(void)setViewDeselectedAtIndex:(NSInteger)currentIndex
{
    UIView *barView = [[chartArea subviews] objectAtIndex:currentIndex];
    mBarLayer *selectBarLayer = [[barView.layer sublayers] objectAtIndex:0];
    selectBarLayer.backgroundColor = [UIColor clearColor].CGColor;
//    barView.backgroundColor = [UIColor clearColor];
    
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
