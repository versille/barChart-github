//
//  ViewController.m
//  BarChart
//
//  Created by versille on 6/17/14.
//  Copyright (c) 2014 versille. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.barChart loadBarchart];
    [self.multiBarChart setDatasource:self];
    [self.multiBarChart loadMultiBarChart];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSArray *)getData
{
    return [NSArray arrayWithObjects:@12, @77, @55, @44, @11, @44, @33, nil];
}

@end
