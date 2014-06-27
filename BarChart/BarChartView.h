//
//  BarChartView.h
//  BarChart
//
//  Created by versille on 6/20/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarChartView : UIView

@property (nonatomic, assign) CGFloat barLength;
@property (nonatomic, assign) CGFloat barHeight;
@property (nonatomic, assign) CGFloat barStartPosition;
@property (nonatomic, assign) CGFloat chartMargin;
-(void)loadBarchart;

@end
