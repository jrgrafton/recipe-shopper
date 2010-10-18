//
//  DataManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 21/09/2010.
//  Copyright (c) 2010 Assentec. All rights reserved.
//

#import "DataManager.h"
#import "DatabaseRequestManager.h"
#import "RecipeBasketManager.h"
#import "ProductBasketManager.h"
#import "APIRequestManager.h"
#import "LoginManager.h"
#import "Reachability.h"
#import "OverlayViewController.h"

@interface DataManager()

+ (void)updateBasket:(NSArray *)productDetails;

@end

static DatabaseRequestManager *databaseRequestManager;
static RecipeBasketManager *recipeBasketManager;
static ProductBasketManager *productBasketManager;
static APIRequestManager *apiRequestManager;
static LoginManager *loginManager;
static OverlayViewController *overlayViewController;

@implementation DataManager

+ (void)initialiseAll {
    /* initialise the database */
	databaseRequestManager = [[DatabaseRequestManager alloc] init];
	
	/* initialise the recipe basket */
	recipeBasketManager = [[RecipeBasketManager alloc] init];
	
	/* initialise the product basket */
	productBasketManager = [[ProductBasketManager alloc] init];
	
	/* initialise the Tesco API */
	apiRequestManager = [[APIRequestManager alloc] init];
	
	/* initialise the login manager */
	loginManager = [[LoginManager alloc] init];
	
	/* initialise the overlay view */
	overlayViewController = [[OverlayViewController alloc] initWithNibName:@"OverlayView" bundle:[NSBundle mainBundle]];
}

+ (void)uninitialiseAll {
	[databaseRequestManager release];
	[recipeBasketManager release];
	[productBasketManager release];
    [apiRequestManager release];
	[loginManager release];
	[overlayViewController release];
}

+ (BOOL)phoneIsOnline {
	if ([self offlineMode] == YES) {
		return NO;
	} else {
		NetworkStatus internetStatus = [[Reachability reachabilityWithHostName:@"google.com"] currentReachabilityStatus];
		return ((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN));
	}
}

+ (void)updateBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity {
	/* update this product in the product basket */
	[productBasketManager updateProductBasketQuantity:product byQuantity:quantity];
	
	/* if we're logged in, update this product in the online basket too (but in a separate thread so we don't hold up processing */
	if ([apiRequestManager loggedIn] == YES) {
		NSMutableArray *productDetails = [NSMutableArray arrayWithCapacity:2];
		[productDetails addObject:[product productID]];
		[productDetails addObject:quantity];
		[NSThread detachNewThreadSelector:@selector(updateBasket:) toTarget:self withObject:productDetails];
	}
}

+ (void)updateBasket:(NSArray *)productDetails {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *productID = [productDetails objectAtIndex:0];
	NSNumber *quantity = [productDetails objectAtIndex:1];
	[apiRequestManager updateBasketQuantity:productID byQuantity:quantity];
	
	[pool release];
}

#pragma mark -
#pragma mark Database Manager calls

+ (NSArray *)getAllRecipesInCategory:(NSString *)categoryName {
    return [databaseRequestManager getAllRecipesInCategory:categoryName];
}

+ (void)fetchExtendedDataForRecipe:(Recipe *)recipe {
	[databaseRequestManager fetchExtendedDataForRecipe:recipe];
}

+ (void)setUserPreference:(NSString *)prefName prefValue:(NSString *)prefValue {
	[databaseRequestManager setUserPreference:prefName andValue:prefValue];
}

+ (NSString *)getUserPreference:(NSString *)prefName {
	return [databaseRequestManager getUserPreference:prefName];
}

+ (NSArray *)getRecentRecipes {
	return [databaseRequestManager getRecentRecipes];
}

#pragma mark -
#pragma mark API Manager calls

+ (BOOL)offlineMode {
	return [apiRequestManager offlineMode];
}

+ (void)setOfflineMode:(BOOL)offlineMode {
	[apiRequestManager setOfflineMode:offlineMode];
}

+ (BOOL)loggedIn {
	return [apiRequestManager loggedIn];
}

+ (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password {
	return [apiRequestManager loginToStore:email withPassword:password];
}

+ (void)addProductBasketToBasket {
	[apiRequestManager addProductBasketToBasket];
}

+ (NSDictionary *)getBasketDetails {
	return [apiRequestManager getBasketDetails];
}

+ (NSArray *)getDepartments {
	return [apiRequestManager getDepartments];
}

+ (NSArray *)getAislesForDepartment:(NSString *)department {
	return [apiRequestManager getAislesForDepartment:department];
}

+ (NSArray *)getShelvesForAisle:(NSString *)aisle {
	return [apiRequestManager getShelvesForAisle:aisle];
}

+ (NSArray *)getProductsForShelf:(NSString *)shelf {
	return [apiRequestManager getProductsForShelf:shelf];
}

+ (NSDictionary *)getDeliveryDates {
	return [apiRequestManager getDeliveryDates];
}

+ (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder {
	return [apiRequestManager searchForProducts:searchTerm onPage:page totalPageCountHolder:totalPageCountHolder];
}

+ (void)chooseDeliverySlot:(NSString *)deliverySlotID returningError:(NSString **)error {
	[apiRequestManager chooseDeliverySlot:deliverySlotID returningError:error];
}

+ (NSString *)getCustomerName {
	return [apiRequestManager customerName];
}

#pragma mark -
#pragma mark Recipe Basket calls

+ (NSArray *)getRecipeBasket {
	return [recipeBasketManager recipeBasket];
}

+ (NSInteger)getRecipeBasketCount {
    return [[recipeBasketManager recipeBasket] count];
}

+ (Recipe *)getRecipeFromBasket:(NSUInteger)recipeIndex {
    return [[recipeBasketManager recipeBasket] objectAtIndex:recipeIndex];
}

+ (void)addRecipeToBasket:(Recipe *)recipe {
	[recipeBasketManager addRecipeToBasket:recipe];
	[databaseRequestManager addRecipeToHistory:[recipe recipeID]];
	
	NSArray *products;
	
	if ([DataManager phoneIsOnline]) {
		/* phone is online and we have recipes in the basket so create the products using the online store */
		products = [apiRequestManager createProductsFromProductBaseIDs:[recipe recipeProducts]];
	} else {
		/* phone is offline but we have recipes in basket, so create the products using the database */
		products = [databaseRequestManager createProductsFromProductBaseIDs:[recipe recipeProducts]];
	}
	
	for (Product *product in products) {
		NSNumber *quantity = [[recipe recipeProducts] objectForKey:[NSString stringWithFormat:@"%@", [product productBaseID]]];
		[DataManager updateBasketQuantity:product byQuantity:quantity];
	}
}

+ (void)removeRecipeFromBasket:(Recipe *)recipe {
    [recipeBasketManager removeRecipeFromBasket:recipe];
		
	NSArray *products;
	
	if ([DataManager phoneIsOnline]) {
		/* phone is online and we have recipes in the basket so create the products using the online store */
		products = [apiRequestManager createProductsFromProductBaseIDs:[recipe recipeProducts]];
	} else {
		/* phone is offline but we have recipes in basket, so create the products using the database */
		products = [databaseRequestManager createProductsFromProductBaseIDs:[recipe recipeProducts]];
	}
	
	for (Product *product in products) {
		NSNumber *quantity = [[recipe recipeProducts] objectForKey:[NSString stringWithFormat:@"%@", [product productBaseID]]];
		[DataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:(0 - [quantity intValue])]];
	}	
}

+ (void)emptyRecipeBasket {
	[recipeBasketManager emptyRecipeBasket];
}

#pragma mark -
#pragma mark Product Basket calls

+ (void)addShoppingListProductsObserver:(id)observer {
	[productBasketManager addObserver:observer forKeyPath:@"shoppingListProducts" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

+ (void)addBasketProductsObserver:(id)observer {
	[productBasketManager addObserver:observer forKeyPath:@"basketProducts" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

+ (NSDictionary *)getProductBasket {
	return [productBasketManager productBasket];
}

+ (NSString *)getProductBasketPrice {
	return [productBasketManager productBasketPrice];
}

+ (NSInteger)getDistinctProductCount {
	return [[[productBasketManager productBasket] allKeys] count];
}

+ (NSInteger)getTotalProductCount {
	int totalProductCount = 0;
	
	for (NSNumber *quantity in [[productBasketManager productBasket] allValues]) {
		totalProductCount += [quantity intValue];
	}
    
	return totalProductCount;
}

+ (Product *)getProductFromBasket:(NSUInteger)productIndex {
	return [[[productBasketManager productBasket] allKeys] objectAtIndex:productIndex];
}

+ (NSNumber *)getProductQuantityFromBasket:(Product *)product {
	return [[productBasketManager productBasket] objectForKey:product];
}

+ (void)emptyProductBasket {
	[productBasketManager emptyProductBasket];
}

#pragma mark -
#pragma mark Login manager calls

+ (void)requestLoginToStore {
	[loginManager requestLoginToStore];
}

#pragma mark -
#pragma mark Overlay View calls

+ (void)showOverlayView:(UIView *)superView {
	[overlayViewController showOverlayView:superView];
}

+ (void)hideOverlayView {
	[overlayViewController hideOverlayView];
}

+ (void)setOverlayViewOffset:(CGPoint)contentOffset {
	[overlayViewController setOverlayViewOffset:contentOffset];
}

+ (void)showActivityIndicator {
	[overlayViewController showActivityIndicator];
}

+ (void)hideActivityIndicator {
	[overlayViewController hideActivityIndicator];
}

+ (void)setOverlayLabelText:(NSString *)text {
	[overlayViewController performSelectorOnMainThread:@selector(setOverlayLabelText:) withObject:text waitUntilDone:YES];
}

@end
