//
//  HTTPRequestManager.h
//  RecipeShopper
//
//  Created by James Grafton on 6/1/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPRequestManager : NSObject {

}

- (NSArray*)fetchClosestStoresToGeolocation: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) maxNumber;
- (NSArray*)fetchGeolocationFromAddress: (NSString*)address;
- (id)init;

@end
