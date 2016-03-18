//
//  CurrentLocationFinderDelegate.h
//  eqglobe
//
//  Created by Jess on 4/2/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CurrentLocationFinderDelegate <NSObject>

@optional
-(void)newLocationObtained;
-(void)newLocationNotObtained;

@end
