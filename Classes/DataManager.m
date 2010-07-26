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
#import "HTTPRequestManager.h"
#import "LogManager.h"
#import "Reachability.h"
#import "LocationController.h"
#import "LoadingView.h"

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

#pragma mark Database Functions
+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger)count {
	return [databaseRequestManager fetchLastPurchasedRecipes:count];
}
+ (NSArray*)fetchAllRecipesInCategory: (NSString*) category {
	return [databaseRequestManager fetchAllRecipesInCategory:category];
}

+ (NSString*)fetchUserPreference: (NSString*) key {
	return [databaseRequestManager fetchUserPreference:key];
}

+ (NSArray*)fetchProductsFromIDs: (NSArray*) productIDs{
	if ([DataManager phoneIsOnline]) {
		//Verify that all these products are still available if we are online
		return [apiRequestManager getFilteredProductList:productIDs];
	}
	
	return [databaseRequestManager fetchProductsFromIDs:productIDs];
}

+ (void)putUserPreference: (NSString*)key andValue:(NSString*) value {
	[databaseRequestManager putUserPreference: key andValue:value];
}

+ (void)putRecipeHistory: (NSNumber*)recipeID {
	[databaseRequestManager putRecipeHistory: recipeID];
}

#pragma mark SDK Functions
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
	//Try 10 times to get current location
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



#pragma mark Application Functions
+ (void)addRecipeToBasket: (DBRecipe*)recipe {
	[applicationRequestManager addRecipeToBasket:recipe];
}

+ (void)addProductToBasket: (DBProduct*)product {
	[applicationRequestManager addProductToBasket:product];
}

+ (void)removeProductFromBasket: (DBProduct*)product{
	[applicationRequestManager removeProductFromBasket:product];	
}

+ (NSMutableArray*)getRecipeBasket {
	return [applicationRequestManager recipeBasket];
}

+ (NSArray*)getProductBasket {
	return [applicationRequestManager getProductBasket];
}

+ (NSInteger)getCountForProduct: (DBProduct*)product {
	return [applicationRequestManager getCountForProduct:product];
}

+ (void)decreaseCountForProduct: (DBProduct*)product {
	[applicationRequestManager decreaseCountForProduct:product];
}

+ (void)increaseCountForProduct: (DBProduct*)product {
	[applicationRequestManager increaseCountForProduct:product];
}

+ (NSInteger)getTotalProductCount {
	return [applicationRequestManager getTotalProductCount];
}

+ (CGFloat)getTotalProductBasketCost {
	return [applicationRequestManager getTotalProductBasketCost];
}

+ (void)createProductListFromRecipeBasket {
	[applicationRequestManager createProductListFromRecipeBasket];
}

#pragma mark API functions
+ (NSArray*)fetchProductsMatchingSearchTerm: (NSString*)searchTerm onThisPage:(NSInteger) pageNumber andGiveMePageCount:(NSInteger*) pageCountHolder {
	return [apiRequestManager fetchProductsMatchingSearchTerm: searchTerm onThisPage: pageNumber andGiveMePageCount: pageCountHolder];
}
+ (NSArray*)fetchAvailableDeliverySlots{
	return [apiRequestManager fetchAvailableDeliverySlots];
}

+ (BOOL)loginToStore:(NSString*) email withPassword:(NSString*) password{
	return [apiRequestManager loginToStore:email withPassword:password];
}

+ (BOOL)addProductBasketToStoreBasket{
	return [apiRequestManager addProductBasketToStoreBasket];
}

+ (BOOL)chooseDeliverySlot:(APIDeliverySlot*)deliverySlot returningError:(NSString**)error{
	return [apiRequestManager chooseDeliverySlot:deliverySlot returningError:error];
}

+ (NSDate*)verifyOrder:(NSString**)error {
	return [apiRequestManager verifyOrder:error];
}

@end
