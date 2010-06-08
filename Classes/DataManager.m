//
//  DataManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#import "DataManager.h"
#import "DatabaseRequestManager.h"
#import "APIRequestManager.h"
#import "ApplicationRequestManager.h"
#import "LogManager.h"
#import "Reachability.h"
#import "LocationController.h"
#import "HTTPRequestManager.h"

static DatabaseRequestManager *databaseRequestManager;
static APIRequestManager *apiRequestManager;
static HTTPRequestManager *httpRequestManager;
static ApplicationRequestManager *applicationRequestManager;

static LocationController *locationController;
static BOOL phoneIsOnline;

@implementation DataManager

+ (void)initialiseAll {
	//Network availability
	Reachability *r = [Reachability reachabilityWithHostName:@"techfortesco.com"];
	NetworkStatus internetStatus = [r currentReachabilityStatus];
	phoneIsOnline = ((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN));
	
	//Location services
	#ifdef DEBUG
		[LogManager log:@"Initialising location controller" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	locationController = [[LocationController alloc] init];
	
	//Data managers
	#ifdef DEBUG
		[LogManager log:@"Initialising request managers" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	#ifdef DEBUG
		[LogManager log:@"Initialising database request manager" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	databaseRequestManager = [[DatabaseRequestManager alloc] init];
	#ifdef DEBUG
		[LogManager log:@"Initialising API request manager" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	apiRequestManager = [[APIRequestManager alloc] init];
	#ifdef DEBUG
		[LogManager log:@"Initialising HTTP request manager" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	httpRequestManager = [[HTTPRequestManager alloc] init];
	#ifdef DEBUG
		[LogManager log:@"Initialising Application request manager" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	applicationRequestManager = [[ApplicationRequestManager alloc] init];
}

+ (void)deinitialiseAll {
	#ifdef DEBUG
		[LogManager log:@"Deinitialising request managers" withLevel:LOG_INFO fromClass:@"DataManager"];
	#endif
	[databaseRequestManager release];
	[apiRequestManager release];
	[httpRequestManager release];
	[applicationRequestManager release];
}

+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger)count {
	return [databaseRequestManager fetchLastPurchasedRecipes:count];
}
+ (NSArray*)fetchAllRecipesInCategory: (NSString*) category {
	return [databaseRequestManager fetchAllRecipesInCategory:category];
}

+ (NSString*)fetchUserPreference: (NSString*) key {
	return [databaseRequestManager fetchUserPreference:key];
}

+ (void)putUserPreference: (NSString*)key andValue:(NSString*) value {
	[databaseRequestManager putUserPreference: key andValue:value];
}

+ (void)putRecipeHistory: (NSInteger)recipeID {
	[databaseRequestManager putRecipeHistory: recipeID];
}

+ (NSString*)fetchUserDocumentsPath {
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

+ (BOOL)fileExistsInUserDocuments: (NSString*) fileName {
	NSString *processedPath = [[DataManager fetchUserDocumentsPath] stringByAppendingPathComponent:fileName];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:processedPath];
}

+ (BOOL)phoneIsOnline {	
	return phoneIsOnline;
}

+ (NSArray*)getCurrentLatitudeLongitude{
	int MAX_LOCATION_WAITS = 10;
	int locationWaits = 0;
	while (![locationController locationKnown]) {
		[NSThread sleepForTimeInterval:1.0f];
		locationWaits+=1;
		if (locationWaits > MAX_LOCATION_WAITS) {
			return nil;
		}
	}
	
#ifndef DEBUG
	CLLocation *location = [locationController currentLocation];
	CLLocationCoordinate2D myLocation = [location coordinate];
	NSNumber *latitude = [NSNumber numberWithDouble: myLocation.latitude];
	NSNumber *longitude = [NSNumber numberWithDouble: myLocation.longitude];
#else
	//BRIXTON HOUSE :D
	NSNumber *latitude = [NSNumber numberWithDouble:51.448494657351866];
	NSNumber *longitude = [NSNumber numberWithDouble:-0.118095651268958];
#endif
	return [NSArray arrayWithObjects:latitude,longitude,nil];
}

+ (NSArray*)fetchClosestStoresToGeolocation: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) count{
	return [httpRequestManager fetchClosestStoresToGeolocation:latitudeLongitude andReturnUpToThisMany:count];
}

+ (NSArray*)fetchGeolocationFromAddress: (NSString*)address{
	return [httpRequestManager fetchGeolocationFromAddress: (NSString*)address];
}

+ (void)addRecipeToBasket: (DBRecipe*)recipe {
	[applicationRequestManager addRecipeToBasket:recipe];
}

+ (NSInteger)getBasketSize {
	return [applicationRequestManager getBasketSize];
}

@end
