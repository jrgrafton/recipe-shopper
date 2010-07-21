//
//  HTTPStore.m
//  RecipeShopper
//
//  Created by James Grafton on 6/1/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "HTTPStore.h"

@interface HTTPStore ()
@property (readwrite,assign) NSInteger storeID;
@property (readwrite,copy) NSString *storeName;
@property (readwrite,copy) NSString *storeType;
@property (readwrite,copy) NSNumber *storeDistanceFromCurrentLocation;
@property (readwrite,copy) NSNumber *storeLatitude;
@property (readwrite,copy) NSNumber *storeLongitude;
@end

@implementation HTTPStore

@synthesize storeID,storeName,storeType,storeDistanceFromCurrentLocation,storeLatitude,storeLongitude;

- (id)initWithStoreID: (NSInteger)inStoreID andStoreName:(NSString*)inStoreName 
		 andStoreType:(NSString*)inStoreType andStoreDistanceFromCurrentLocation:(NSNumber*)inStoreDistanceFromCurrentLocation 
		 andStoreLatitude:(NSNumber*)inStoreLatitude andStoreLongitude:(NSNumber*)inStoreLongitude {
	
	if (self = [super init]) {
		[self setStoreID:inStoreID];
		[self setStoreName:inStoreName];
		[self setStoreType:inStoreType];
		[self setStoreDistanceFromCurrentLocation:inStoreDistanceFromCurrentLocation];
		[self setStoreLatitude:inStoreLatitude];
		[self setStoreLongitude:inStoreLongitude];
	}
	return self;		
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Store: ID=%d Name=%@ Type=%@ DistanceFromUs=%@M Lat=%@ Lon=%@",storeID,storeName,storeType,storeDistanceFromCurrentLocation,storeLatitude,storeLongitude];
}

// Class instance method to compare self with object "obj"
- (NSComparisonResult) compareByDistanceFromMyLocation:(HTTPStore *)obj
{
    NSComparisonResult retVal = NSOrderedSame;
	
    if ([[self storeDistanceFromCurrentLocation] floatValue] < [[obj storeDistanceFromCurrentLocation] floatValue]){
		retVal = NSOrderedAscending;
	}
    else if ([[self storeDistanceFromCurrentLocation] floatValue] > [[obj storeDistanceFromCurrentLocation] floatValue]){
		retVal = NSOrderedDescending;
	}
	
    return retVal;
}


- (void)dealloc {
	[storeName release];
	[storeType release];
	[storeDistanceFromCurrentLocation release];
	[storeLongitude release];
	[storeLatitude release];
	[super dealloc];
}

@end
