//
//  BRLocationFinder.h
//  ShakeMe
//
//  Created by Jess on 4/2/15.
//  Copyright (c) 2013 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>
#import "BRLocationFinderDelegate.h"

@interface BRLocationFinder : NSObject

@property (weak,nonatomic) id<BRLocationFinderDelegate> delegate;

+(BOOL)locationServiceIsAuthorized;

-(void)startupForground;
-(void)startupBackgroundHighPower;
-(void)startupBackgroundLowPower;
-(void)tearDownLocationResources;

-(void)obtainPermissions;

@end
