//
//  ViewController.m
//  BRShakeMe
//
//  Created by Jess on 3/10/16.
//  Copyright (c) 2013 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
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
