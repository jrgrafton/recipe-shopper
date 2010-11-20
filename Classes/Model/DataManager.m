//
//  DataManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 21/09/2010.
//  Copyright (c) 2010 Assentec. All rights reserved.
//

#import "DataManager.h"
#import "Reachability.h"
#import "LogManager.h"

@interface DataManager()

- (void)updateOnlineBasket:(NSArray *)productDetails;

@end

static DataManager *sharedInstance = nil;

@implementation DataManager

@synthesize offlineMode;
@synthesize updatingProductBasket;
@synthesize updatingOnlineBasket;
@synthesize loadingDepartmentList;
@synthesize departmentListHasLoaded;
@synthesize productBasketUpdates;
@synthesize onlineBasketUpdates;
@synthesize productImageFetchThreads;
@synthesize productImageFetchLastBatchSize;
@synthesize productImageFetchSuccessCount;

+ (DataManager *)getInstance {
	@synchronized(self){
		if (sharedInstance == nil) {
			sharedInstance = [[DataManager alloc] init];
		}
	}
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

- (id)init {
	@synchronized(self) {
		[super init];
		
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
		
		[self setUpdatingProductBasket:NO];
		[self setUpdatingOnlineBasket:NO];
		[self setLoadingDepartmentList:NO];
		[self setDepartmentListHasLoaded:NO];
		[self setProductBasketUpdates:0];
		[self setOnlineBasketUpdates:0];
		[self setProductImageFetchThreads:0];
		[self setProductImageFetchLastBatchSize:0];
		[self setProductImageFetchSuccessCount:0];
	}
	
	return self;
}

- (void)uninitialiseAll {
	[databaseRequestManager release];
	[recipeBasketManager release];
	[productBasketManager release];
    [apiRequestManager release];
	[loginManager release];
	[overlayViewController release];
}

- (BOOL)phoneIsOnline {
	if (offlineMode == YES) {
		return NO;
	} else {
		NetworkStatus internetStatus = [[Reachability reachabilityWithHostName:@"google.com"] currentReachabilityStatus];
		return ((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN));
	}
}

- (void)updateBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity {
	/* update this product in the product basket */
	[productBasketManager updateProductBasketQuantity:product byQuantity:quantity];
	
	if ([overlayViewController isShowing]) {
		[self performSelectorOnMainThread:@selector(setOverlayLoadingLabelText:) withObject:[NSString stringWithFormat:@"%d basket update(s) remaining",productBasketUpdates] waitUntilDone:YES];
	}
	
	[LogManager log:[NSString stringWithFormat:@"Number of product basket thread(s) remaining is %d", productBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];

	if (productBasketUpdates == 0) {
		/* we've finished updating the product basket now */
		[self setUpdatingProductBasket:NO];

		/* so notify the shopping list controller so that it can remove the overlay view */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ProductBasketUpdateComplete" object:self];
	}
	
	/* if we're logged in, update this product in the online basket too (but in a separate thread so we don't hold up processing */
	if ([apiRequestManager loggedIn] == YES) {
		NSMutableArray *productDetails = [[NSMutableArray alloc] initWithCapacity:2];
		[productDetails addObject:[product productID]];
		[productDetails addObject:quantity];
		[self setUpdatingOnlineBasket:YES];
		[NSThread detachNewThreadSelector:@selector(updateOnlineBasket:) toTarget:self withObject:productDetails];
	}
}

- (void)updateOnlineBasket:(NSArray *)productDetails {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *productID = [productDetails objectAtIndex:0];
	NSNumber *quantity = [productDetails objectAtIndex:1];
	onlineBasketUpdates++;
	[apiRequestManager updateBasketQuantity:productID byQuantity:quantity];
	onlineBasketUpdates--;
	
	[LogManager log:[NSString stringWithFormat:@"Number of online basket updates remaining is %d", onlineBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];
	
	if (onlineBasketUpdates == 0) {
		/* we've finished updating the online basket now */
		[self setUpdatingOnlineBasket:NO];
		
		/* so notify the checkout controller so that it can remove the overlay view */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OnlineBasketUpdateComplete" object:self];
	}
	
	//[productDetails release];
	[pool release];
}

#pragma mark -
#pragma mark Database Manager calls

- (NSArray *)getAllRecipesInCategory:(NSString *)categoryName {
    return [databaseRequestManager getAllRecipesInCategory:categoryName];
}

- (void)fetchExtendedDataForRecipe:(Recipe *)recipe {
	[databaseRequestManager fetchExtendedDataForRecipe:recipe];
}

- (void)setUserPreference:(NSString *)prefName prefValue:(NSString *)prefValue {
	[databaseRequestManager setUserPreference:prefName andValue:prefValue];
}

- (NSString *)getUserPreference:(NSString *)prefName {
	return [databaseRequestManager getUserPreference:prefName];
}

- (NSArray *)getRecipeHistory {
	return [databaseRequestManager getRecipeHistory];
}

- (void)clearRecipeHistory {
	[databaseRequestManager clearRecipeHistory];
}

#pragma mark -
#pragma mark API Manager calls

- (BOOL)loggedIn {
	return [apiRequestManager loggedIn];
}

- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password {
	return [apiRequestManager loginToStore:email withPassword:password];
}

- (void)logoutOfStore {
	[apiRequestManager logoutOfStore];
}

- (void)emptyOnlineBasket {
	[self setUpdatingOnlineBasket:YES];
	
	NSDictionary *onlineBasket = [apiRequestManager getOnlineBasket];
	
	for (NSString *productID in [onlineBasket allKeys]) {
		NSMutableArray *productDetails = [NSMutableArray arrayWithCapacity:2];
		[productDetails addObject:productID];
		[productDetails addObject:[NSNumber numberWithInt:(0 - [[onlineBasket objectForKey:productID] intValue])]];
		[NSThread detachNewThreadSelector:@selector(updateOnlineBasket:) toTarget:self withObject:productDetails];
	}
}

- (void)addProductBasketToOnlineBasket {
	if ([self getTotalProductCount] == 0) {
		[self setUpdatingOnlineBasket:NO];
		return;
	}
	
	[self setUpdatingOnlineBasket:YES];
	
	NSDictionary *productBasket = [self getProductBasket];
	
	for (Product *product in productBasket) {
		NSMutableArray *productDetails = [NSMutableArray arrayWithCapacity:2];
		[productDetails addObject:[product productID]];
		[productDetails addObject:[productBasket objectForKey:product]];
		[NSThread detachNewThreadSelector:@selector(updateOnlineBasket:) toTarget:self withObject:productDetails];
	}	
}

- (NSDictionary *)getBasketDetails {
	return [apiRequestManager getBasketDetails];
}

- (void)getDepartments {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setLoadingDepartmentList:YES];
	NSArray *departmentList = [apiRequestManager getDepartments];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:departmentList,@"departmentList",nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"departmentListFinishedLoading" object:self userInfo:userInfo];
	[self setLoadingDepartmentList:NO];
	[self setDepartmentListHasLoaded:YES];
	
	[pool release];
}

- (NSArray *)getAislesForDepartment:(NSString *)department {
	return [apiRequestManager getAislesForDepartment:department];
}

- (NSArray *)getShelvesForAisle:(NSString *)aisle {
	return [apiRequestManager getShelvesForAisle:aisle];
}

- (NSArray *)getProductsForShelf:(NSString *)shelf onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder {
	return [apiRequestManager getProductsForShelf:shelf onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder];
}

- (NSDictionary *)getDeliveryDates {
	return [apiRequestManager getDeliveryDates];
}

- (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder {
	return [apiRequestManager searchForProducts:searchTerm onPage:page totalPageCountHolder:totalPageCountHolder];
}

- (BOOL)chooseDeliverySlot:(NSString *)deliverySlotID returningError:(NSString **)error {
	return [apiRequestManager chooseDeliverySlot:deliverySlotID returningError:error];
}

- (NSString *)getCustomerName {
	return [apiRequestManager customerName];
}

- (void)fetchImagesForProductBatch:(NSArray *)productBatch {
	[self setProductImageFetchLastBatchSize: [productBatch count]];
	productImageFetchSuccessCount = 0;
	
	if ([productBatch count] == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"productImageBatchFetchComplete" object:self userInfo:nil];
		return;
	}
	
	if ([self phoneIsOnline]) {
		/* need be notified so we can update internal product img fetch statuses*/
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productImageFetchStatusNotification:) name:@"productImageFetchComplete" object:nil];
		
		for (Product* product in productBatch) {
			productImageFetchThreads++;
			[NSThread detachNewThreadSelector:@selector(fetchImagesForProduct:) toTarget:apiRequestManager withObject:product];
			[LogManager log:[NSString stringWithFormat:@"Number of product image fetch requests is now %d", productImageFetchThreads] withLevel:LOG_INFO fromClass:[[self class] description]];
		}
	}
}

- (void)productImageFetchStatusNotification:(NSNotification *)notification {
	productImageFetchThreads--;
	productImageFetchSuccessCount++;
	
	NSInteger leftToFetch = productImageFetchLastBatchSize - productImageFetchSuccessCount;
	if (leftToFetch == 0) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"productImageBatchFetchComplete" object:nil userInfo:nil];
		[[NSNotificationCenter defaultCenter] removeObserver:self];
	}else {
		[LogManager log:[NSString stringWithFormat:@"%d product(s) left to fetch",leftToFetch] withLevel:LOG_INFO fromClass:[[self class] description]];
		[overlayViewController setOverlayLoadingLabelText:[NSString stringWithFormat:@"%d product(s) left to fetch",leftToFetch]];	
	}
}

#pragma mark -
#pragma mark Recipe Basket calls

- (NSArray *)getRecipeBasket {
	return [recipeBasketManager recipeBasket];
}

- (NSInteger)getRecipeBasketCount {
    return [[recipeBasketManager recipeBasket] count];
}

- (Recipe *)getRecipeFromBasket:(NSUInteger)recipeIndex {
    return [[recipeBasketManager recipeBasket] objectAtIndex:recipeIndex];
}

- (void)addRecipeToBasket:(Recipe *)recipe {
	[recipeBasketManager addRecipeToBasket:recipe];
	[databaseRequestManager addRecipeToHistory:[recipe recipeID]];
	
	[self setUpdatingProductBasket:YES];
	
	for (NSString *recipeProductBaseID in [[recipe recipeProducts] allKeys]) {
        NSMutableArray *recipeProduct = [[NSMutableArray alloc] initWithCapacity:2]; //Will get released by child thread
        [recipeProduct addObject:recipeProductBaseID];
        [recipeProduct addObject:[[recipe recipeProducts] objectForKey:recipeProductBaseID]];
        [NSThread detachNewThreadSelector:@selector(addRecipeProductToBasket:) toTarget:self withObject:recipeProduct];
    }
}

- (void)addRecipeProductToBasket:(NSArray *)recipeProduct {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
    Product *product;
    
	productBasketUpdates++;
	
    if ([self phoneIsOnline] == YES) {
		/* phone is online so create the products for this recipe using the online store */
        product = [apiRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0] fetchImages:YES];
	} else {
		/* we're using offline mode so create the products for this recipe using the database */
		product = [databaseRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0]];
	}
	
	productBasketUpdates--;
	
	//If we have found the product either in the DB or online update product basket
    if (product != nil) {
        [self updateBasketQuantity:product byQuantity:[recipeProduct objectAtIndex:1]];
    }
    
	[recipeProduct release]; //Since it is alloc'd by parent thread passing in Array
    [pool release];
}

- (void)removeRecipeFromBasket:(Recipe *)recipe {
    [recipeBasketManager removeRecipeFromBasket:recipe];
	
	[self setUpdatingProductBasket:YES];
	
    for (NSString *recipeProductBaseID in [[recipe recipeProducts] allKeys]) {
        NSMutableArray *recipeProduct = [NSMutableArray arrayWithCapacity:2];
        [recipeProduct addObject:recipeProductBaseID];
        [recipeProduct addObject:[[recipe recipeProducts] objectForKey:recipeProductBaseID]];
        [NSThread detachNewThreadSelector:@selector(removeRecipeProductFromBasket:) toTarget:self withObject:recipeProduct];
    }
}

- (void)removeRecipeProductFromBasket:(NSArray *)recipeProduct {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Product *product;
    
	productBasketUpdates++;
	
    if ([self phoneIsOnline] == YES) {
        /* phone is online so create the products for this recipe using the online store */
        product = [apiRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0] fetchImages:YES];
    } else {
		/* we're using offline mode so create the products for this recipe using the database */
        product = [databaseRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0]];
    }
    
	productBasketUpdates--;
	
    if (product != nil) {
        [self updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:(0 - [[recipeProduct objectAtIndex:1] intValue])]];
    }
    
    [pool release];
}

- (void)emptyRecipeBasket {
	[recipeBasketManager emptyRecipeBasket];
}

#pragma mark -
#pragma mark Product Basket calls

- (void)addShoppingListProductsObserver:(id)observer {
	[productBasketManager addObserver:observer forKeyPath:@"shoppingListProducts" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (void)addBasketProductsObserver:(id)observer {
	[productBasketManager addObserver:observer forKeyPath:@"basketProducts" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
}

- (NSDictionary *)getProductBasket {
	return [productBasketManager productBasket];
}

- (NSString *)getProductBasketPrice {
	return [productBasketManager productBasketPrice];
}

- (NSInteger)getDistinctProductCount {
	return [[[productBasketManager productBasket] allKeys] count];
}

- (NSInteger)getTotalProductCount {
	int totalProductCount = 0;
	
	for (NSNumber *quantity in [[productBasketManager productBasket] allValues]) {
		totalProductCount += [quantity intValue];
	}
    
	return totalProductCount;
}

- (Product *)getProductFromBasket:(NSUInteger)productIndex {
	return [[[productBasketManager productBasket] allKeys] objectAtIndex:productIndex];
}

- (NSNumber *)getProductQuantityFromBasket:(Product *)product {
	return [[productBasketManager productBasket] objectForKey:product];
}

- (void)emptyProductBasket {
	[productBasketManager emptyProductBasket];
}

#pragma mark -
#pragma mark Login manager calls

- (void)requestLoginToStore {
	[loginManager requestLoginToStore];
}

#pragma mark -
#pragma mark Overlay View calls

- (void)showOverlayView:(UIView *)superView {
	[overlayViewController showOverlayView:superView];
}

- (void)hideOverlayView {
	[overlayViewController hideOverlayView];
}

- (void)setOverlayViewOffset:(CGPoint)contentOffset {
	[overlayViewController setOverlayViewOffset:contentOffset];
}

- (void)showActivityIndicator {
	[overlayViewController showActivityIndicator];
}

- (void)hideActivityIndicator {
	[overlayViewController hideActivityIndicator];
}

- (void)setOverlayLabelText:(NSString *)text {
	[overlayViewController performSelectorOnMainThread:@selector(setOverlayLabelText:) withObject:text waitUntilDone:YES];
}

- (void)setOverlayLoadingLabelText:(NSString *)text {
	[overlayViewController performSelectorOnMainThread:@selector(setOverlayLoadingLabelText:) withObject:text waitUntilDone:YES];
}

@end