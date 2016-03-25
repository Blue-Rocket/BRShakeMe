//
//  ViewController.m
//  ShakeMeHard
//
//  Created by Jess on 3/10/16.
//  Copyright © 2016 Blue Rocket. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSInteger number = [(AppDelegate*)[[UIApplication sharedApplication] delegate] numberOfSuspendedModeAwakenings];
    self.awakenings.text = [NSString stringWithFormat:@"Awoken from suspended mode %d times", (int)number];
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)reset:(id)sender
{
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] resetUserDefaults];
}

@end
