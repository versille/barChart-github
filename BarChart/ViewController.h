//
//  ViewController.h
//  BarChart
//
//  Created by versille on 6/17/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarChartView.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet BarChartView *barChart;
@property (weak, nonatomic) IBOutlet BarChartView *multiBarChart;


@end
