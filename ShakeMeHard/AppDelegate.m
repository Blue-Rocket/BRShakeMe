//
//  AppDelegate.m
//  BRShakeMe
//
//  Created by Jess on 3/10/16.
//  Copyright (c) 2013 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "AppDelegate.h"
#import "BRLocationFinder.h"
#import <CoreMotion/CoreMotion.h>

static const BOOL USE_HIGH_POWER_LOCATIONS = NO;
static const BOOL USE_ONBOARD_RECORDED_ACC = NO; // WatchOS only, but interesting possibility

@interface AppDelegate () <BRLocationFinderDelegate>
    @property(nonatomic,strong) BRLocationFinder *currentLocationFinder;
    @property(nonatomic,strong) CMMotionManager *motionManager;
    @property(nonatomic,strong) CMSensorRecorder *sensorRecorder;

    @property (nonatomic) NSInteger numberOfLocations;
    @property (nonatomic) NSInteger numberOfAccelerations;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    // 1. First initalization before restoring UI state or launched from suspended state
    //
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //
    // 2. Final initialization after restoring UI state or launched from suspended state
    //
    [self initializeCurrentLocationFinder];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
        [self incrementNumberOfAwakeningsCount];
        
        NSString *notificationText = [NSString stringWithFormat:@"Awoken from suspended mode %d times", (int)[self numberOfSuspendedModeAwakenings]];
        [self scheduleNotificationWithString:notificationText];
        
        if (USE_HIGH_POWER_LOCATIONS) {
            [self.currentLocationFinder startupBackgroundHighPower];
        } else {
            [self.currentLocationFinder startupBackgroundLowPower];
        }

    } else {
        
        [self.currentLocationFinder startupForground];
        [self registerForNotifications];
        
    }
    
    if (USE_ONBOARD_RECORDED_ACC) {
        [self startOnboardRecordingOfAccelerations];
    } else {
        [self startAccelerationUpdates];
        
    }

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //
    // 1. Called before applicationDidBecomeActive
    //
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
    } else if (appState == UIApplicationStateBackground) {
        //
        // Case of Foreground to Background
        //
        NSString *notificationText = @"Forground to Background";
        [self scheduleNotificationWithString:notificationText];
        
        [self initializeCurrentLocationFinder];
        
        if (USE_HIGH_POWER_LOCATIONS) {
            [self.currentLocationFinder startupBackgroundHighPower];
        } else {
            [self.currentLocationFinder startupBackgroundLowPower];
        }
        
        if (USE_ONBOARD_RECORDED_ACC) {
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
}

#pragma mark
#pragma mark Location Services

-(void)initializeCurrentLocationFinder
{
    if (self.currentLocationFinder != nil) {
        [self.currentLocationFinder tearDownLocationResources];
    }
    self.currentLocationFinder = [[BRLocationFinder alloc] init];
    self.currentLocationFinder.delegate = self;
}

-(void)newLocationObtained
{
    NSString *notificationText = @"Location Found";
    [self scheduleNotificationWithString:notificationText];
    
    if (USE_ONBOARD_RECORDED_ACC) {
        [self processOnboardRecordedAccelerations];
    } else {
    }
}

-(void)newLocationNotObtained
{
    
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
                            _numberOfAccelerations += 1;
                            if (_numberOfAccelerations == 40) {
                                _numberOfAccelerations = 0;
                                NSString *notificationText = [NSString stringWithFormat:@"Acceleration=%@",[data description]];
                                [self scheduleNotificationWithString:notificationText];
                            }
                        });
     }
     ];
}

static const NSInteger secondsIn12Hours = 60*60*12;

-(void)startOnboardRecordingOfAccelerations
{
    if (self.sensorRecorder == nil) {
        self.sensorRecorder = [[CMSensorRecorder alloc] init];
    }
    [self.sensorRecorder recordAccelerometerForDuration:(secondsIn12Hours / 2)]; // six hours
}

-(void)processOnboardRecordedAccelerations
{
    BOOL Available = [CMSensorRecorder isAccelerometerRecordingAvailable];
    BOOL Authorized = [CMSensorRecorder isAuthorizedForRecording];
    
    if (Available && Authorized) {
        
        if (self.sensorRecorder == nil) {
            self.sensorRecorder = [[CMSensorRecorder alloc] init];
        }

        NSDate *now = [NSDate date];
        NSDate *yesterday = [now dateByAddingTimeInterval:(-1*secondsIn12Hours / 4)]; // 3 hours ago
        
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
}

#pragma mark
#pragma mark Notifications

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
#pragma mark User Defaults

NSString *NUMBER_OF_AWAKENINGS = @"NumberOfAwakenings";

-(void)resetUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:NUMBER_OF_AWAKENINGS];
    [defaults synchronize];
    [NSUserDefaults resetStandardUserDefaults];
}

-(NSInteger)numberOfSuspendedModeAwakenings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:NUMBER_OF_AWAKENINGS];
}

-(void)incrementNumberOfAwakeningsCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger numberOfAwakenings = [defaults integerForKey:NUMBER_OF_AWAKENINGS];
    numberOfAwakenings += 1;
    NSLog(@"App awoken from suspended mode %d times", (int)numberOfAwakenings);
    [defaults setInteger:numberOfAwakenings forKey:NUMBER_OF_AWAKENINGS];
    [defaults synchronize];
}


@end
