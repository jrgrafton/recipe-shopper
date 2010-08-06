//
//  DataManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DBRecipe.h"
#import "DBProduct.h"
#import "APIDeliverySlot.h"
#import "LoadingView.h"

@interface DataManager : NSObject <CLLocationManagerDelegate>{
	
}

//Publicly available data aquisition

//DB data
+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger) count;
+ (NSString*)fetchUserPreference: (NSString*) key;
+ (NSArray*)fetchProductsFromIDs: (NSArray*) productIDs;
+ (void)putUserPreference: (NSString*)key andValue:(NSString*) value;
+ (void)putRecipeHistory: (NSNumber*)recipeID;
+ (NSArray*)fetchAllRecipesInCategory: (NSString*) category; //Will get enough data to display in tableview
+ (void)fetchExtendedDataForRecipe: (DBRecipe*) recipe;	//Will populate recipe for all info needed for HTML view

//iPhone SDK data
+ (BOOL)fileExistsInUserDocuments: (NSString*) fileName;
+ (BOOL)phoneIsOnline;
+ (NSArray*)getCurrentLatitudeLongitude;
+ (NSString*)fetchUserDocumentsPath;

//HTTP data
+ (NSArray*)fetchGeolocationFromAddress: (NSString*)address;
+ (NSArray*)fetchClosestStoresToGeolocation: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) count;

//Tesco API data
+ (NSArray*)fetchProductsMatchingSearchTerm: (NSString*)searchTerm onThisPage:(NSInteger) pageNumber andGiveMePageCount:(NSInteger*) pageCountHolder;
+ (NSArray*)fetchAvailableDeliverySlots;
+ (BOOL)loginToStore:(NSString*) username withPassword:(NSString*) password;
+ (BOOL)addProductBasketToStoreBasket;
+ (BOOL)chooseDeliverySlot:(APIDeliverySlot*)deliverySlot returningError:(NSString**)error;
+ (NSDate*)verifyOrder:(NSString**)error;

//Application data
+ (void)addRecipeToBasket: (DBRecipe*)recipe;
+ (void)addProductToBasket: (DBProduct*)product;
+ (void)removeProductFromBasket: (DBProduct*)product;
+ (NSMutableArray*)getRecipeBasket;
+ (NSArray*)getProductBasket;
+ (void)decreaseCountForProduct: (DBProduct*)product;
+ (void)increaseCountForProduct: (DBProduct*)product;
+ (NSInteger)getCountForProduct: (DBProduct*)product;
+ (NSInteger)getTotalProductCount;
+ (CGFloat)getTotalProductBasketCost;
+ (void)createProductListFromRecipeBasket;

//Initialisation and deinitialisation procedures
+ (void)initialiseAll;
+ (void)deinitialiseAll;

@end
