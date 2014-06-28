//
//  BarChartView.m
//  BarChart
//
//  Created by versille on 6/20/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import "BarChartView.h"

@interface barLayer : CAShapeLayer
@property (nonatomic, assign) CGFloat   value;
@property (nonatomic, assign) CGFloat   percentage;
@property (nonatomic, assign) double    startPosition;
@property (nonatomic, assign) double    endPosition;
@property (nonatomic, assign) BOOL      isSelected;
@property (nonatomic, strong) NSString  *text;
- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to Delegate:(id)delegate;
@end

@implementation barLayer
- (NSString*)description
{
    return [NSString stringWithFormat:@"value:%f, percentage:%0.0f, start:%f, end:%f", _value, _percentage, _startPosition/M_PI*180, _endPosition/M_PI*180];
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

@end

@implementation BarChartView
{
    NSMutableArray *baseBars;
    UIView *barChart;
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
        for (int i=1; i<4; i++) {
            CGFloat currentX = self.chartMargin;
            CGFloat currentY = self.chartMargin + (self.frame.size.height - 2*self.chartMargin)*i/4 - 15;
            
            CGRect barRect = CGRectMake(currentX, currentY, self.barLength, 30);
            UIView *bar = [[UIView alloc] initWithFrame:barRect];
            bar.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
            bar.layer.cornerRadius = 3.0;
            bar.layer.masksToBounds = YES;
            bar.layer.borderColor = [UIColor whiteColor].CGColor;
            bar.layer.borderWidth = 3.0;
            [baseBars addObject:bar];
            [barChart addSubview:bar];
        }
        [self addSubview:barChart];

    }
    return self;
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
    [baseBar.layer addSublayer:bar];

    bar.path = path.CGPath;
    
    [bar createArcAnimationForKey:@"strokeEnd" fromValue:@0.0 toValue:@1.0f timing:5.0 Delegate:self];

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
