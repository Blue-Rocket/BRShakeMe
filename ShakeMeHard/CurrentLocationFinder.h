//
//  CurrentLocationFinder.h
//  eqglobe
//
//  Created by Jess on 4/2/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentLocationFinderDelegate.h"

@interface CurrentLocationFinder : NSObject

@property (weak,nonatomic) id<CurrentLocationFinderDelegate> delegate;

+(BOOL)locationServiceIsAuthorized;

-(void)startupForground;
-(void)startupBackgroundHighPower;
-(void)startupBackgroundLowPower;
-(void)tearDownLocationResources;

@end
