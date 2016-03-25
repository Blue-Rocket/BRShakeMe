//
//  AppDelegate.h
//  ShakeMeHard
//
//  Created by Jess on 3/10/16.
//  Copyright © 2016 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *NUMBER_OF_AWAKENINGS;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(NSInteger)numberOfSuspendedModeAwakenings;
-(void)resetUserDefaults;

@end

