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

- (NSArray*)fetchClosestStores: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) count;
- (id)init;

@end
