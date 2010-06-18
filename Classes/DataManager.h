//
//  DataManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DBRecipe.h"
#import "DBProduct.h"

@interface DataManager : NSObject <CLLocationManagerDelegate>{

}

//Publicly available data aquisition
//DB data
+ (NSArray*)fetchLastPurchasedRecipes: (NSInteger) count;
+ (NSArray*)fetchAllRecipesInCategory: (NSString*) category;
+ (NSString*)fetchUserPreference: (NSString*) key;
+ (NSArray*)fetchProductsFromIDs: (NSArray*) productIDs;
+ (void)putUserPreference: (NSString*)key andValue:(NSString*) value;
+ (void)putRecipeHistory: (NSNumber*)recipeID;

//iPhone SDK data
+ (BOOL)fileExistsInUserDocuments: (NSString*) fileName;
+ (BOOL)phoneIsOnline;
+ (NSArray*)getCurrentLatitudeLongitude;
+ (NSString*)fetchUserDocumentsPath;

//HTTP data
+ (NSArray*)fetchGeolocationFromAddress: (NSString*)address;
+ (NSArray*)fetchClosestStoresToGeolocation: (NSArray*)latitudeLongitude andReturnUpToThisMany:(NSInteger) count;

//Application data
+ (void)addRecipeToBasket: (DBRecipe*)recipe;
+ (void)addProductToBasket: (DBProduct*)product;
+ (void)removeProductFromBasket: (DBProduct*)product;
+ (NSMutableArray*)getRecipeBasket;
+ (NSArray*)getProductBasket;
+ (void)decreaseCountForProduct: (DBProduct*)product;
+ (void)increaseCountForProduct: (DBProduct*)product;
+ (NSUInteger)getCountForProduct: (DBProduct*)product;
+ (NSUInteger)getTotalProductCount;
+ (NSString*)getTotalProductBasketCost;


+ (void)createProductListFromRecipeBasket;

//Initialisation and deinitialisation procedures
+ (void)initialiseAll;
+ (void)deinitialiseAll;

@end
