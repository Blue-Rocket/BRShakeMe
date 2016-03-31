//
//  CurrentLocationFinder.m
//  eqglobe
//
//  Created by Jess on 4/2/15.
//  Copyright (c) 2013 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "CurrentLocationFinder.h"
#import <CoreLocation/CoreLocation.h>

@interface CurrentLocationFinder () <CLLocationManagerDelegate>
    @property (strong, nonatomic) CLLocationManager *locationManager;
    @property(nonatomic) BOOL eventsDifferred;
@end

@implementation CurrentLocationFinder

- (id)init
{
    if ((self = [super init])) {
        _eventsDifferred = NO;
    }
    return self;
}

-(void)tearDownLocationResources
{
    if (self.locationManager == nil) {
        return;
    } else {
        [self stop];
        self.locationManager = nil;
    }
}

-(void)startupForground
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    [self startWithNotifyingUser];
}

-(void)startupBackgroundHighPower
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    [self startWithoutNotifyingUser];
}

-(void)startupBackgroundLowPower
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    self.locationManager.pausesLocationUpdatesAutomatically = YES; // Best set to no ...
    self.locationManager.activityType = CLActivityTypeFitness;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        //
        // About every 500 meters change or 5 minutes says documentation
        //
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

-(void)startWithoutNotifyingUser
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    }
}

-(void)startWithNotifyingUser;
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        [self.delegate newLocationNotObtained];
    }
}

-(void)obtainPermissions
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        return;
    } else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    } else {
        return;
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"New Location Obtained");
    [self.delegate newLocationObtained];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager startUpdatingLocation];
    } else if (status != kCLAuthorizationStatusNotDetermined) {
        [self.delegate newLocationNotObtained];
    }
}

-(void)stop
{
    [self.locationManager stopUpdatingLocation];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}

+(BOOL)locationServiceIsAuthorized
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        return YES;
    } else {
        return NO;
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Error: %@",[error description]);
}

#pragma mark
#pragma mark Deferred Updates

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    NSLog(@"Location Error: %@",[error description]);
//    _eventsDifferred = NO;
//    [self setupDefferedEvents];
}

-(void)setupDefferedEvents
{
    if (_eventsDifferred) {
        return;
    } else {
        //
        // Does not work in debug mode, device needs to power down for it to work.
        // TODO: Add as a refinement later
        //
        _eventsDifferred = YES;
        CLLocationDistance distance = kCLLocationAccuracyBestForNavigation;
        NSTimeInterval timeInterval = 1.0; // seconds
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:distance
                                                                timeout:timeInterval];
    }
}

@end
