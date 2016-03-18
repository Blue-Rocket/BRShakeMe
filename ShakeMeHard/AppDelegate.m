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
//        [self.currentLocationFinder startupBackgroundHighPower];
        [self.currentLocationFinder startupBackgroundLowPower];
        
        [self startAccelerationUpdates];
//        [self startRecordingAccelerations];
        
    } else if (appState == UIApplicationStateBackground) {
        //
        // Case of Foreground to Background
        //
        NSString *notificationText = @"Forground to Background";
        [self scheduleNotificationWithString:notificationText];
        
        [self.currentLocationFinder tearDownLocationResources];
//        [self.currentLocationFinder startupBackgroundHighPower];
        [self.currentLocationFinder startupBackgroundLowPower];
        
        [self startAccelerationUpdates];
//        [self startRecordingAccelerations];
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

static const NSInteger secondsIn24Hours = 60*60*24;
static const NSInteger secondsIn12Hours = 60*60*12;

-(void)newLocationObtained
{
    _numberOfLocations += 1;
    if (_numberOfLocations > 10) {
        _numberOfLocations = 0;
        NSString *notificationText = @"Location Found";
        [self scheduleNotificationWithString:notificationText];
        
        [self processRecordedAccelerations];
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
         dispatch_async(dispatch_get_main_queue(),
                        ^{
                            _numberOfAccelerations += 1;
                            if (_numberOfAccelerations > 600) {
                                _numberOfAccelerations = 0;
                                NSString *notificationText = [NSString stringWithFormat:@"Acceleration=%@",[data description]];
                                [self scheduleNotificationWithString:notificationText];
                            }
                        });
     }
     ];
}

-(void)startRecordingAccelerations
{
    self.sensorRecorder = [[CMSensorRecorder alloc] init];
//    [self.sensorRecorder recordAccelerometerForDuration:(secondsIn12Hours)];
}

-(void)processRecordedAccelerations
{
    //
    // See what sensor data we got!
    //
    if (self.sensorRecorder) {
//        NSDate *now = [NSDate date];
//        NSDate *yesterday = [now dateByAddingTimeInterval:-1*secondsIn24Hours];
//        NSDate *tomorrow = [now dateByAddingTimeInterval:secondsIn24Hours];
//        CMSensorDataList *list = [self.sensorRecorder accelerometerDataFromDate:yesterday
//                                                                         toDate:tomorrow];
        
//        NSInteger count = 0;
//        for (CMRecordedAccelerometerData* data in list) {
//            count = count + 1;
//            NSLog(@"%@",[data description]);
//        }
//        NSString *notificationText = [NSString stringWithFormat:@"%i accelerations found", (int) count];
//        [self scheduleNotificationWithString:notificationText];
    }
}

@end
