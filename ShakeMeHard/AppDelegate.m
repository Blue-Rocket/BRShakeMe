//
//  AppDelegate.m
//  ShakeMeHard
//
//  Created by Jess on 3/10/16.
//  Copyright © 2016 Blue Rocket. All rights reserved.
//

#import "AppDelegate.h"
#import "CurrentLocationFinder.h"
#import <CoreMotion/CoreMotion.h>

@interface AppDelegate () <CurrentLocationFinderDelegate>
    @property(nonatomic,strong) CurrentLocationFinder *currentLocationFinder;
    @property(nonatomic,strong) CMMotionManager *motionManager;
    @property(nonatomic,strong) CMSensorRecorder *sensorRecorder;

    @property (nonatomic) NSInteger numberOfLocations;
    @property (nonatomic) NSInteger numberOfAccelerations;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    // 1. First initalization before restoring UI state
    //
    _currentLocationFinder = [[CurrentLocationFinder alloc] init];
    _currentLocationFinder.delegate = self;

    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    // 2. Final initialization after restoring UI state
    //
    [self registerForNotifications];
    [self.currentLocationFinder startupForground];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //
    // 1. Called before applicationDidBecomeActive
    //
    if (self.motionManager) {
        [self.motionManager stopAccelerometerUpdates];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //
    // 2. Called after applicationWillEnterForeground
    //    or when temporary intteruptions finish (like a phone call)
    //    or when launch initializations are finalized
    //
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //
    // 1. Called before applicationDidEnterBackground or when temporary interruptions initiate (like a phone call)
    //
}

static const BOOL HIGH_POWER = YES;
static const BOOL ONBOARD_RECORDED_ACC = NO;

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //
    // 2. Called after applicationWillResignActive or when app is relaunched from a sleeping state
    //
    UIApplicationState appState = [UIApplication sharedApplication].applicationState;
    if (appState == UIApplicationStateActive) {
        //
        // Case of running in the foreground
        //
    } else if (appState == UIApplicationStateInactive) {
        //
        // Case of Awoken from Backgound
        //
        NSString *notificationText = @"Suspended to Background";
        [self scheduleNotificationWithString:notificationText];
        
        [self.currentLocationFinder tearDownLocationResources];

        if (HIGH_POWER) {
            [self.currentLocationFinder startupBackgroundHighPower];
        } else {
            [self.currentLocationFinder startupBackgroundLowPower];
        }
        
        if (ONBOARD_RECORDED_ACC) {
            [self startOnboardRecordingOfAccelerations];
        } else {
            [self startAccelerationUpdates];

        }
        
    } else if (appState == UIApplicationStateBackground) {
        //
        // Case of Foreground to Background
        //
        NSString *notificationText = @"Forground to Background";
        [self scheduleNotificationWithString:notificationText];
        
        [self.currentLocationFinder tearDownLocationResources];
        [self.currentLocationFinder tearDownLocationResources];
        
        if (HIGH_POWER) {
            [self.currentLocationFinder startupBackgroundHighPower];
        } else {
            [self.currentLocationFinder startupBackgroundLowPower];
        }
        
        if (ONBOARD_RECORDED_ACC) {
            [self startOnboardRecordingOfAccelerations];
        } else {
            [self startAccelerationUpdates];
            
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSString *notificationText = @"App was terminated";
    [self scheduleNotificationWithString:notificationText];
    
    [self.motionManager stopAccelerometerUpdates];
}

#pragma mark
#pragma mark Location Services

static const NSInteger secondsIn12Hours = 60*60*12;

-(void)newLocationObtained
{
    NSString *notificationText = @"Location Found";
    [self scheduleNotificationWithString:notificationText];
    
    if (ONBOARD_RECORDED_ACC) {
        [self processOnboardRecordedAccelerations];
    } else {
    }
}

-(void)newLocationNotObtained
{
    
}

-(void)registerForNotifications
{
    UIUserNotificationType types = (UIUserNotificationType) (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
    UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    
}

-(void)scheduleNotificationWithString:(NSString*)text
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = nil;
    localNotification.alertBody = text;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark
#pragma mark Accelerations

-(void)startAccelerationUpdates
{
    if (self.motionManager) {
        [self.motionManager stopAccelerometerUpdates];
        self.motionManager = nil;
    }
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.05; // 20 hz
    
    
    [self.motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init]
                                             withHandler:^(CMAccelerometerData *data, NSError *error)
     {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                        ^{
                            NSString *notificationText = [NSString stringWithFormat:@"Acceleration=%@",[data description]];
                            [self scheduleNotificationWithString:notificationText];
                        });
     }
     ];
}

-(void)startOnboardRecordingOfAccelerations
{
    self.sensorRecorder = [[CMSensorRecorder alloc] init];
    [self.sensorRecorder recordAccelerometerForDuration:(secondsIn12Hours)];
}

-(void)processOnboardRecordedAccelerations
{
    if (self.sensorRecorder == nil) {
        self.sensorRecorder = [[CMSensorRecorder alloc] init];
    }
    
    NSDate *now = [NSDate date];
    NSDate *yesterday = [now dateByAddingTimeInterval:(-1*secondsIn12Hours / 2)]; // 6 hours
    
    CMSensorDataList *list = [self.sensorRecorder accelerometerDataFromDate:yesterday
                                                                     toDate:now];
    
    if (list) {
        NSInteger count = 0;
        for (CMRecordedAccelerometerData* data in list) {
            count = count + 1;
            NSLog(@"%@",[data description]);
        }
        
        NSString *notificationText = [NSString stringWithFormat:@"%i accelerations found", (int) count];
        [self scheduleNotificationWithString:notificationText];
        
    } else {
        
        NSString *notificationText = @"No accelerations returned";
        [self scheduleNotificationWithString:notificationText];
        
    }
}

@end
