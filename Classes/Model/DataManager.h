//
//  DataManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 21/09/2010.
//  Copyright (c) 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatabaseRequestManager.h"
#import "RecipeBasketManager.h"
#import "ProductBasketManager.h"
#import "APIRequestManager.h"
#import "LoginManager.h"
#import "OverlayViewController.h"
#import "Recipe.h"
#import "Product.h"

@interface DataManager : NSObject {
	
@private 
	DatabaseRequestManager *databaseRequestManager;
	RecipeBasketManager *recipeBasketManager;
	ProductBasketManager *productBasketManager;
	APIRequestManager *apiRequestManager;
	LoginManager *loginManager;
	OverlayViewController *overlayViewController;
}

/* Not explicitly stating non-atomic means we get atomic vars */
@property (assign) BOOL offlineMode;
@property (assign) BOOL updatingProductBasket;
@property (assign) BOOL updatingOnlineBasket;
@property (assign) BOOL loadingDepartmentList;
@property (assign) BOOL departmentListHasLoaded;
@property (assign) NSInteger productBasketUpdates;
@property (assign) NSInteger onlineBasketUpdates;
@property (assign) NSInteger productImageFetchThreads;
@property (assign) NSInteger productImageFetchLastBatchSize;
@property (assign) NSInteger productImageFetchSuccessCount;

+ (DataManager *)getInstance;

/* Combined manager calls */
- (id)init;
- (void)uninitialiseAll;
- (BOOL)phoneIsOnline;
- (void)updateBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity;
- (BOOL)synchronizeOnlineOfflineBasket;

/* database manager calls */
- (NSArray *)getAllRecipesInCategory:(NSString *)categoryName;
- (void)fetchExtendedDataForRecipe:(Recipe *)recipe;
- (void)setUserPreference:(NSString *)prefName prefValue:(NSString *)prefValue;
- (NSString *)getUserPreference:(NSString *)prefName;
- (NSArray *)getRecipeHistory;
- (void)clearRecipeHistory;

/* api manager calls */
- (BOOL)loggedIn;
- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password;
- (void)logoutOfStore;
- (void)emptyOnlineBasket;
- (void)addProductBasketToOnlineBasket;
- (NSDictionary *)getBasketDetails;
- (void)getDepartments;	/* Results sent out with notification */
- (NSArray *)getAislesForDepartment:(NSString *)department;
- (NSArray *)getShelvesForAisle:(NSString *)aisle;
- (NSArray *)getProductsForShelf:(NSString *)shelf onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
- (NSDictionary *)getDeliveryDates;
- (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
- (BOOL)chooseDeliverySlot:(NSString *)deliverySlotID returningError:(NSString **)error;
- (NSString *)getCustomerName;
- (void)fetchImagesForProductBatch:(NSArray*) productBatch;
- (void)productImageFetchStatusNotification: (NSNotification *)notification;

/* recipe basket manager calls */
- (NSArray *)getRecipeBasket;
- (NSInteger)getRecipeBasketCount;
- (Recipe *)getRecipeFromBasket:(NSUInteger)recipeIndex;
- (void)addRecipeToBasket:(Recipe *)recipe;
- (void)addRecipeProductToBasket:(NSArray *)recipeProduct;
- (void)removeRecipeFromBasket:(Recipe *)recipe;
- (void)removeRecipeProductFromBasket:(NSArray *)recipeProduct;
- (void)emptyRecipeBasket;

/* product basket manager calls */
- (void)addShoppingListProductsObserver:(id)observer;
- (void)addBasketProductsObserver:(id)observer;
- (NSDictionary *)getProductBasket;
- (NSString *)getProductBasketPrice;
- (NSInteger)getDistinctProductCount;
- (NSInteger)getTotalProductCount;
- (Product *)getProductFromBasket:(NSUInteger)productIndex;
- (NSNumber *)getProductQuantityFromBasket:(Product *)product;
- (NSInteger)getDistinctUnavailableOnlineCount;
- (Product *)getUnavailableOnlineProduct:(NSUInteger)productIndex;
- (NSInteger)getDistinctAvailableOnlineCount;
- (Product *)getAvailableOnlineProduct:(NSUInteger)productIndex;
- (void)emptyProductBasket;

/* login manager calls */
- (void)requestLoginToStore;

/* overlay view calls */
- (void)showOverlayView:(UIView *)superView;
- (void)hideOverlayView;
- (void)setOverlayViewOffset:(CGPoint)contentOffset;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;
- (void)setOverlayLabelText:(NSString *)text;
- (void)setOverlayLoadingLabelText:(NSString *)text;

@end