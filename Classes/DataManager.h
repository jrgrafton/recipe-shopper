//
//  DataManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 21/09/2010.
//  Copyright (c) 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"
#import "Product.h"

@interface DataManager : NSObject <UIAlertViewDelegate>

+ (void)initialiseAll;
+ (void)uninitialiseAll;

+ (BOOL)phoneIsOnline;

+ (void)addNumRecipesObserver:(id)observer;

+ (void)updateBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity;

/* database manager calls */
+ (NSArray *)getAllRecipesInCategory:(NSString *)categoryName;
+ (void)fetchExtendedDataForRecipe:(Recipe *)recipe;
+ (void)setUserPreference:(NSString *)prefName prefValue:(NSString *)prefValue;
+ (NSString *)getUserPreference:(NSString *)prefName;

/* api manager calls */
+ (BOOL)loggedIn;
+ (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password;
+ (void)addProductBasketToOnlineBasket;
+ (NSDictionary *)getOnlineBasketDetails;
+ (NSArray *)getDepartments;
+ (NSArray *)getAislesForDepartment:(NSString *)department;
+ (NSArray *)getShelvesForAisle:(NSString *)aisle;
+ (NSArray *)getProductsForShelf:(NSString *)shelf;
+ (NSDictionary *)getDeliveryDates;
+ (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
+ (void)chooseDeliverySlot:(NSString *)deliverySlotID;

/* recipe basket manager calls */
+ (NSArray *)getRecipeBasket;
+ (NSInteger)getRecipeBasketCount;
+ (Recipe *)getRecipeFromBasket:(NSUInteger)recipeIndex;
+ (void)addRecipeToBasket:(Recipe *)recipe;
+ (void)removeRecipeFromBasket:(Recipe *)recipe;
+ (void)emptyRecipeBasket;

/* product basket manager calls */
+ (NSDictionary *)getProductBasket;
+ (NSInteger)getDistinctProductCount;
+ (NSInteger)getTotalProductCount;
+ (Product *)getProductFromBasket:(NSUInteger)productIndex;
+ (NSNumber *)getProductQuantityFromBasket:(Product *)product;
+ (NSDictionary *)getRecipesInProductBasket;
+ (void)emptyProductBasket;

/* login manager calls */
+ (void)requestLoginToStore;

/* overlay view calls */
+ (void)showOverlayView;
+ (void)hideOverlayView;
+ (void)hideActivityIndicator;
+ (void)setOverlayLabelText:(NSString *)text;

@end
