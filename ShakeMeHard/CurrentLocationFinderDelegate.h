//
//  CurrentLocationFinderDelegate.h
//  eqglobe
//
//  Created by Jess on 4/2/15.
//  Copyright (c) 2013 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@protocol CurrentLocationFinderDelegate <NSObject>

@optional
-(void)newLocationObtained;
-(void)newLocationNotObtained;

@end
