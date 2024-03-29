//
//  ViewController.h
//  BarChart
//
//  Created by versille on 6/17/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarChartView.h"
#import "multiBarChartView.h"

@interface ViewController : UIViewController <BarChartViewDataSource>
@property (weak, nonatomic) IBOutlet BarChartView *barChart;
@property (weak, nonatomic) IBOutlet multiBarChartView *multiBarChart;


@end
