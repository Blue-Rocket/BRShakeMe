//
//  AppDelegate.h
//  ShakeMeHard
//
//  Created by Jess on 3/10/16.
//  Copyright (c) 2013 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

extern NSString *NUMBER_OF_AWAKENINGS;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(NSInteger)numberOfSuspendedModeAwakenings;
-(void)resetUserDefaults;

@end

