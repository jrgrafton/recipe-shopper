//
//  HTTPStore.h
//  RecipeShopper
//
//  Created by James Grafton on 6/1/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HTTPStore : NSObject {
	NSInteger storeID;
	NSString *storeName;
	NSString *storeType;
	NSNumber *storeDistanceFromCurrentLocation;
	NSNumber *storeLatitude;
	NSNumber *storeLongitude;
}

@property (readonly,assign) NSInteger storeID;
@property (readonly,copy) NSString *storeName;
@property (readonly,copy) NSString *storeType;
@property (readonly,copy) NSNumber *storeDistanceFromCurrentLocation;
@property (readonly,copy) NSNumber *storeLatitude;
@property (readonly,copy) NSNumber *storeLongitude;


- (id)initWithStoreID: (NSInteger)inStoreID andStoreName:(NSString*)inStoreName 
	   andStoreType:(NSString*)inStoreType andStoreDistanceFromCurrentLocation:(NSNumber*)inStoreDistanceFromCurrentLocation 
	   andStoreLatitude:(NSNumber*)inStoreLatitude andStoreLongitude:(NSNumber*)inStoreLongitude;

- (NSComparisonResult) compareByDistanceFromMyLocation:(HTTPStore *)obj;

@end
