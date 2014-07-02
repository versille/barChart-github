//
//  multiBarChartView.h
//  BarChart
//
//  Created by versille on 6/30/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface multiBarChartView : UIView

@property (nonatomic, assign) CGFloat xScale;
@property (nonatomic, assign) CGFloat yScale;
@property (nonatomic, strong) UIColor *barColor;
@property (nonatomic, strong) UILabel *xAxisLabel;
@property (nonatomic, strong) UIFont  *labelFont;
@property (nonatomic, strong) UIColor *labelColor;
@property (nonatomic, assign) CGFloat barMargin;
@property (nonatomic, assign) CGFloat barCornerRadius;
@property (nonatomic, assign) CGFloat barStrokeWidth;
@property (nonatomic, assign) CGFloat chartMargin;
@property (nonatomic, assign) CGFloat barWidth;

- (void) loadMultiBarChart;

@end
