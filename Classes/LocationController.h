//
//  LocationController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/1/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

@interface  LocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
}

+ (LocationController *)sharedInstance;

-(void) start;
-(void) stop;
-(BOOL) locationKnown;

@property (copy) CLLocation *currentLocation;

@end

