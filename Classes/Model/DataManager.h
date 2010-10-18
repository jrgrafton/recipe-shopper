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

@interface DataManager : NSObject

+ (void)initialiseAll;
+ (void)uninitialiseAll;

+ (BOOL)phoneIsOnline;

+ (void)updateBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity;

/* database manager calls */
+ (NSArray *)getAllRecipesInCategory:(NSString *)categoryName;
+ (void)fetchExtendedDataForRecipe:(Recipe *)recipe;
+ (void)setUserPreference:(NSString *)prefName prefValue:(NSString *)prefValue;
+ (NSString *)getUserPreference:(NSString *)prefName;
+ (NSArray *)getRecentRecipes;

/* api manager calls */
+ (BOOL)offlineMode;
+ (void)setOfflineMode:(BOOL)offlineMode;
+ (BOOL)loggedIn;
+ (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password;
+ (void)addProductBasketToBasket;
+ (NSDictionary *)getBasketDetails;
+ (NSArray *)getDepartments;
+ (NSArray *)getAislesForDepartment:(NSString *)department;
+ (NSArray *)getShelvesForAisle:(NSString *)aisle;
+ (NSArray *)getProductsForShelf:(NSString *)shelf;
+ (NSDictionary *)getDeliveryDates;
+ (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
+ (void)chooseDeliverySlot:(NSString *)deliverySlotID returningError:(NSString **)error;
+ (NSString *)getCustomerName;

/* recipe basket manager calls */
+ (NSArray *)getRecipeBasket;
+ (NSInteger)getRecipeBasketCount;
+ (Recipe *)getRecipeFromBasket:(NSUInteger)recipeIndex;
+ (void)addRecipeToBasket:(Recipe *)recipe;
+ (void)removeRecipeFromBasket:(Recipe *)recipe;
+ (void)emptyRecipeBasket;

/* product basket manager calls */
+ (void)addShoppingListProductsObserver:(id)observer;
+ (void)addBasketProductsObserver:(id)observer;
+ (NSDictionary *)getProductBasket;
+ (NSString *)getProductBasketPrice;
+ (NSInteger)getDistinctProductCount;
+ (NSInteger)getTotalProductCount;
+ (Product *)getProductFromBasket:(NSUInteger)productIndex;
+ (NSNumber *)getProductQuantityFromBasket:(Product *)product;
+ (void)emptyProductBasket;

/* login manager calls */
+ (void)requestLoginToStore;

/* overlay view calls */
+ (void)showOverlayView:(UIView *)superView;
+ (void)hideOverlayView;
+ (void)setOverlayViewOffset:(CGPoint)contentOffset;
+ (void)showActivityIndicator;
+ (void)hideActivityIndicator;
+ (void)setOverlayLabelText:(NSString *)text;

@end
