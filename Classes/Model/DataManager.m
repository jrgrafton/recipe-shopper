//
//  DataManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 21/09/2010.
//  Copyright (c) 2010 Assentec. All rights reserved.
//

#include <mach/mach_time.h>

#import "DataManager.h"
#import "Reachability.h"
#import "LogManager.h"

// Timeout in seconds for network connectivity
#define CONNECTIVITY_CHECK_TIMEOUT 2.0
#define CONNECTIVITY_CHECK_SUCCESS 1
#define CONNECTIVITY_CHECK_FAILURE 0

@interface DataManager()
- (void)updateOnlineBasket:(NSArray *)productDetails;
- (void)updateProduct:(Product *)product;
@end

static DataManager *sharedInstance = nil;

@implementation DataManager

@synthesize offlineMode;
@synthesize updatingProductBasket;
@synthesize updatingOnlineBasket;
@synthesize loadingDepartmentList;
@synthesize departmentListHasLoaded;
@synthesize replaceMode;
@synthesize lastNetworkCheckResult;
@synthesize replaceString;
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
		
		networkAvailabilityLock = [[NSConditionLock alloc] initWithCondition:CONNECTIVITY_CHECK_FAILURE];
		onlineUpdateLock = [[NSLock alloc] init];
		
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
		[self setReplaceMode:NO];
		[self setLastNetworkCheckResult:NO];
		[self setReplaceString:@""];
		[self setProductBasketUpdates:0];
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
		return [self phoneHasNetworkConnection];
	}
}

- (BOOL)phoneHasNetworkConnection {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* Initialise with as yet unmet condition */
	if ([networkAvailabilityLock condition] == CONNECTIVITY_CHECK_SUCCESS) {
		/* Restet lock if its been used before */
		[networkAvailabilityLock release];
		NSLog(@"REALLOCATING LOCK");
		networkAvailabilityLock = [[NSConditionLock alloc] initWithCondition:CONNECTIVITY_CHECK_FAILURE];
	}
	
	/* Dispatch Thread to check network connection */	
	NSLog(@"CREATING THREAD");
	[NSThread detachNewThreadSelector:@selector(checkNetworkConnection) toTarget:self withObject:nil];
	
	NSLog(@"BLOCKING ON THREAD");
	/* Now block until we get connectivity success */
	if ([networkAvailabilityLock lockWhenCondition:CONNECTIVITY_CHECK_SUCCESS beforeDate:[NSDate dateWithTimeIntervalSinceNow:CONNECTIVITY_CHECK_TIMEOUT]]) {
		/* We gained the lock - checkNetworkConnection must have responded in a timely mannor */
		NSLog(@"TIMELY RESPONSE");
		[networkAvailabilityLock unlock];
	}
	/* Lock timed out before we could verify network connectivity */
	else {
		NSLog(@"RESPONSE TIMED OUT");
		/* We never gained the lock, assume phone is offline */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"PhoneHasNoNetworkConnection" object:self];
		lastNetworkCheckResult = NO;
	}

	[pool release];
	
	return lastNetworkCheckResult;
}

- (void)checkNetworkConnection {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"THREAD: STARTED");
	/* Double locking to ensure that child thread acquires main lock first */ 
	[networkAvailabilityLock lock];
	
	NSLog(@"THREAD: ACQUIRED LOCK");
	
	uint64_t startTime = mach_absolute_time();
	NetworkStatus internetStatus = [[Reachability reachabilityWithHostName:@"google.com"] currentReachabilityStatus];
	uint64_t endTime = mach_absolute_time();
	
	double timeTaken = (double) ((endTime - startTime) / 1000000000.0);
	
	[LogManager log:[NSString stringWithFormat:@"Network connection took %f seconds to check", timeTaken] withLevel:LOG_INFO fromClass:[[self class] description]];
	
	/* Only care about results if we have fetched them fast enough */
	if (timeTaken < CONNECTIVITY_CHECK_TIMEOUT) {
		NSLog(@"THREAD: CHECKED NETWORK WITHIN TIME");
		/* Set success condition for lock so parent thread knows we are OK */
		[networkAvailabilityLock unlockWithCondition:CONNECTIVITY_CHECK_SUCCESS];
		
		if ((internetStatus == ReachableViaWiFi) || (internetStatus == ReachableViaWWAN)) {
			lastNetworkCheckResult = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PhoneHasNetworkConnection" object:self];
		}else {
			lastNetworkCheckResult = NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"PhoneHasNoNetworkConnection" object:self];
		}
	}else {
		NSLog(@"THREAD: TIMED OUT CHECKING NETWORK WITHIN TIME");
		/* Simply unlock since calling thread will have already assumed no network connection */
		[networkAvailabilityLock unlockWithCondition:CONNECTIVITY_CHECK_FAILURE];
	}
	
	[pool release];
}

- (void)updateBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity {
	
	if (product != nil) {
		/* update this product in the product basket */
		[productBasketManager updateProductBasketQuantity:product byQuantity:quantity];
		
		/* if we're logged in, update this product in the online basket too (but in a separate thread so we don't hold up processing */
		if ([apiRequestManager loggedIn] == YES) {
			NSMutableArray *productDetails = [[NSMutableArray alloc] initWithCapacity:2];
			[productDetails addObject:[product productID]];
			[productDetails addObject:quantity];
			[self setUpdatingOnlineBasket:YES];
			[NSThread detachNewThreadSelector:@selector(updateOnlineBasket:) toTarget:self withObject:productDetails];
		}
	}

	if ([overlayViewController isShowing]) {
		[self setOverlayLoadingLabelText: [NSString stringWithFormat:@"%d basket update(s) remaining",productBasketUpdates]];
	}
	
	[LogManager log:[NSString stringWithFormat:@"Number of product basket thread(s) remaining is %d", productBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];

	if (productBasketUpdates == 0) {
		[self setOverlayLoadingLabelText: @""];
		
		/* we've finished updating the product basket now */
		[self setUpdatingProductBasket:NO];

		/* so notify the shopping list controller so that it can remove the overlay view */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"ProductBasketUpdateComplete" object:self];
	}
}

- (BOOL) synchronizeOnlineOfflineBasket {
	[LogManager log:@"Synching online/offline basket" withLevel:LOG_INFO fromClass:[[self class] description]];
	
	NSDictionary *onlineBasket = [apiRequestManager getOnlineBasket];
	NSDictionary *offlineBasket = [productBasketManager productBasket];
	BOOL madeChanges = NO;
	
	/* This first nested loop ensures that offline basket doesn't have anything it shouldn't have */
	for (NSString *onlineProductID in [onlineBasket allKeys]) {
		BOOL foundMatch = NO;
		for (Product *offlineProduct in [offlineBasket allKeys]) {
			NSString *offlineProductID = [NSString stringWithFormat:@"%@",[offlineProduct productID]]; 
			if ([onlineProductID isEqualToString:offlineProductID]) {
				foundMatch = YES;
				
				/*Found match for ID now match quantity*/
				NSInteger onlineCount = [[onlineBasket objectForKey:onlineProductID] intValue];
				NSInteger offlineCount = [[offlineBasket objectForKey:offlineProduct] intValue];
				NSNumber *difference = [NSNumber numberWithInt:(offlineCount - onlineCount)];
				
				if ([difference intValue] != 0) {
					madeChanges = YES;
					if (offlineCount > [offlineProduct maxAmount] || [offlineProduct quantityUpdateAttempted]) {
						if([offlineProduct quantityUpdateAttempted]){
							/* We have exceeded max allowed so change local basket to cap */
							[productBasketManager updateProductBasketQuantity:offlineProduct byQuantity: [NSNumber numberWithInt:(onlineCount - offlineCount)]];
							[LogManager log:[NSString stringWithFormat:@"Max number of product ID %@ exceeded, removing %@ from local basket", onlineProductID,[NSNumber numberWithInt:(onlineCount - offlineCount)]] withLevel:LOG_INFO fromClass:[[self class] description]];
							break;
						}
					}else {
						/* This is first attempt at update, and we don't think that the quantity cap has been reached */
						NSMutableArray *productDetails = [[NSMutableArray alloc] initWithCapacity:2];
						[productDetails addObject:onlineProductID];
						[productDetails addObject:difference];
						[self setUpdatingOnlineBasket:YES];
						[LogManager log:[NSString stringWithFormat:@"Incorrect number of online product ID %@ found, needs adjusting by %@", [productDetails objectAtIndex:0],[productDetails objectAtIndex:1]] withLevel:LOG_INFO fromClass:[[self class] description]];
						[NSThread detachNewThreadSelector:@selector(updateOnlineBasket:) toTarget:self withObject:productDetails];
						[offlineProduct setQuantityUpdateAttempted:YES];
						break;
					}
				}
			}
		}
		
		/* There is a product in our online basket that doesn't appear in our offline basket */
		if (!foundMatch) {
			/* Occasionally we find items in online that exist but have 0 quantity */
			if ([[onlineBasket objectForKey:onlineProductID] intValue] != 0) {
				/* Remove erranous product completely */
				NSMutableArray *productDetails = [[NSMutableArray alloc] initWithCapacity:2];
				[productDetails addObject:onlineProductID];
				[productDetails addObject: [NSNumber numberWithInt:(0 - [[onlineBasket objectForKey:onlineProductID] intValue])]];
				[self setUpdatingOnlineBasket:YES];
				[LogManager log:[NSString stringWithFormat:@"Online product ID %@ not found in local basket, needs adjusting by %@", [productDetails objectAtIndex:0],[productDetails objectAtIndex:1]] withLevel:LOG_INFO fromClass:[[self class] description]];
				[NSThread detachNewThreadSelector:@selector(updateOnlineBasket:) toTarget:self withObject:productDetails];
				
				madeChanges = YES;
			}
		}
	}
	
	/* It still however may be the case that the product basket might have items the online basket doesn't even know of... */
	for (Product *offlineProduct in [offlineBasket allKeys]) {
		/* If so we assume that its just not available online and needs replacement */
		NSString *offlineProductID = [NSString stringWithFormat:@"%@",[offlineProduct productID]];
		BOOL foundMatch = NO;
		for (NSString *onlineProductID in [onlineBasket allKeys]) {
			if ([onlineProductID isEqualToString:offlineProductID]) {
				foundMatch = YES;
				break;
			}
		}
		
		if (!foundMatch) {
			[LogManager log:[NSString stringWithFormat:@"Local product ID %@ not found in online basket, adding to unavailable online collection", [offlineProduct productID]] withLevel:LOG_INFO fromClass:[[self class] description]];
			[productBasketManager markProductUnavailableOnline:offlineProduct];
		}
	}
	
	if (!madeChanges) {
		[LogManager log:@"Online basket quantities match" withLevel:LOG_INFO fromClass:[[self class] description]];
	}
	
	/* True if we have had to make changes to ONLINE basket */
	return madeChanges;
}

- (void)mergeOnlineOfflineBaskets {
	NSDictionary *onlineBasket = [apiRequestManager getOnlineBasket];
	
	/* Before we start adding online to offline upload local basket */
	[self addProductBasketToOnlineBasket];
	
	for (NSString *onlineProductID in [onlineBasket allKeys]) {
		NSMutableArray *productDetails = [[NSMutableArray alloc] initWithCapacity:2];
		[productDetails addObject: onlineProductID];
		[productDetails addObject: [NSNumber numberWithInt:[[onlineBasket objectForKey:onlineProductID] intValue]]];
		[NSThread detachNewThreadSelector:@selector(downloadProductToLocalBasket:) toTarget:self withObject:productDetails];
	}
}

- (void)downloadProductToLocalBasket:(NSArray*)productInfo {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	
	[onlineUpdateLock lock];
	[self setOnlineBasketUpdates: ++onlineBasketUpdates];
	[LogManager log:[NSString stringWithFormat:@"Number of online basket updates remaining is %d", onlineBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];
	[self setOverlayLoadingLabelText: [NSString stringWithFormat:@"%d updates(s) left",onlineBasketUpdates]];
	[onlineUpdateLock unlock];
	
	Product *product = [apiRequestManager createProductFromProductBaseID:[productInfo objectAtIndex:0] fetchImages:YES];
	[productBasketManager updateProductBasketQuantity:product byQuantity:[productInfo objectAtIndex:1]];
	
	[onlineUpdateLock lock];
	[self setOnlineBasketUpdates: --onlineBasketUpdates];
	[LogManager log:[NSString stringWithFormat:@"Number of online basket updates remaining is %d", onlineBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];
	[self setOverlayLoadingLabelText: [NSString stringWithFormat:@"%d updates(s) left",onlineBasketUpdates]];
	[onlineUpdateLock unlock];
	
	if (onlineBasketUpdates == 0) {
		[self setOverlayLoadingLabelText:@""];
		
		/* send out notification */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OnlineBasketDownloadComplete" object:self];
	}
	
	[productInfo release];
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

- (void)createAnonymousSessionKey {
	[apiRequestManager createAnonymousSessionKey];
}

- (BOOL)loggedIn {
	return [apiRequestManager loggedIn];
}

- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password {
	return [apiRequestManager loginToStore:email withPassword:password];
}

- (void)logoutOfStore {
	[apiRequestManager logoutOfStore];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"LogoutComplete" object:self userInfo:nil];
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
		return;
	}
	
	[self setUpdatingOnlineBasket:YES];
	
	NSDictionary *productBasket = [self getProductBasket];
	
	for (Product *product in productBasket) {
		/* anything that is in the product basket at this point may have been put there in offline mode
		 so we need to do a product search on it in case there is a product offer for it now */
		if ([product productFetchedOffline] == YES) {
			[NSThread detachNewThreadSelector:@selector(updateProduct:) toTarget:self withObject:product];
		}
		
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
    
	@synchronized(self) {
		++productBasketUpdates;
	}
	
    if ([self phoneIsOnline] == YES) {
		/* phone is online so create the products for this recipe using the online store */
        product = [apiRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0] fetchImages:YES];
		
		/* product not found online, fetch from DB, user will be prompted to replace before checkout */
		if (product == nil) {
			product = [databaseRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0]];
		}
	} else {
		/* we're using offline mode so create the products for this recipe using the database */
		product = [databaseRequestManager createProductFromProductBaseID:[recipeProduct objectAtIndex:0]];
	}
	
	@synchronized(self) {
		--productBasketUpdates;
	}
	
	//Can now update with nil product (ensures we always remove loading view no matter what happens)
	[self updateBasketQuantity:product byQuantity:[recipeProduct objectAtIndex:1]];
	
	[recipeProduct release]; //Since it is alloc'd by parent thread passing in Array
    [pool release];
}

- (void)removeRecipeFromBasket:(Recipe *)recipe {
	[self setUpdatingProductBasket:YES];
	
    [recipeBasketManager removeRecipeFromBasket:recipe];
	
    for (NSString *recipeProductBaseID in [[recipe recipeProducts] allKeys]) {
        NSMutableArray *recipeProduct = [[NSMutableArray alloc] initWithCapacity:2]; //Will get released by child thread;
        [recipeProduct addObject:recipeProductBaseID];
        [recipeProduct addObject:[[recipe recipeProducts] objectForKey:recipeProductBaseID]];
        [NSThread detachNewThreadSelector:@selector(removeRecipeProductFromBasket:) toTarget:self withObject:recipeProduct];
    }
}

- (void)removeRecipeProductFromBasket:(NSArray *)recipeProduct {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	@synchronized(self) {
		//Need to ensure correct value ends up being assigned
		++productBasketUpdates;
	}
	
	//No need to go online to remove product we already have in basket - and if its already been taken
	//out of basket we dont care about it anyways!!
	Product *product = [productBasketManager getProductByBaseID:[recipeProduct objectAtIndex:0]];
    
	@synchronized(self) {
		//Need to ensure correct value ends up being assigned
		--productBasketUpdates;
	}
	
	//Can now update with nil product (ensures we always remove loading view no matter what happens)
	[self updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:(0 - [[recipeProduct objectAtIndex:1] intValue])]];
	
	[recipeProduct release];
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
	return [productBasketManager getProductBasketSync];
}

- (NSString *)getProductBasketPrice {
	return [productBasketManager productBasketPrice];
}

- (NSInteger)getDistinctProductCount {
	return [productBasketManager getDistinctProductCount];
}

- (NSInteger)getTotalProductCount {
	return [productBasketManager getTotalProductCount];
}

- (Product *)getProductFromBasket:(NSUInteger)productIndex {
	return [productBasketManager getProductFromBasket:productIndex];
}
- (Product*)getProductByBaseID:(NSString*)productBaseID {
	return [productBasketManager getProductByBaseID:productBaseID];
}

- (NSNumber *)getProductQuantityFromBasket:(Product *)product {
	return [productBasketManager getProductQuantityFromBasket:product];
}

- (NSInteger)getDistinctUnavailableOnlineCount {
	return [productBasketManager getDistinctUnavailableOnlineCount];
}

- (Product *)getUnavailableOnlineProduct:(NSUInteger)productIndex {
	return [productBasketManager getUnavailableOnlineProduct:productIndex];
}

- (NSInteger)getDistinctAvailableOnlineCount {
	return [productBasketManager getDistinctAvailableOnlineCount];
}

- (Product *)getAvailableOnlineProduct:(NSUInteger)productIndex {
	return [productBasketManager getAvailableOnlineProduct:productIndex];
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
	[overlayViewController performSelectorOnMainThread:@selector(showOverlayView:) withObject:superView waitUntilDone:YES];
}

- (void)hideOverlayView {
	[overlayViewController performSelectorOnMainThread:@selector(hideOverlayView) withObject:nil waitUntilDone:YES];
}

- (void)setOverlayViewOffset:(CGPoint)contentOffset {
	[overlayViewController setOverlayViewOffset: contentOffset];
}

- (void)showActivityIndicator {
	[overlayViewController performSelectorOnMainThread:@selector(showActivityIndicator) withObject:nil waitUntilDone:YES];
}

- (void)hideActivityIndicator {
	[overlayViewController performSelectorOnMainThread:@selector(hideActivityIndicator) withObject:nil waitUntilDone:YES];
}

- (void)setOverlayLabelText:(NSString *)text {
	[overlayViewController performSelectorOnMainThread:@selector(setOverlayLabelText:) withObject:text waitUntilDone:YES];
}

- (void)setOverlayLoadingLabelText:(NSString *)text {
	[overlayViewController performSelectorOnMainThread:@selector(setOverlayLoadingLabelText:) withObject:text waitUntilDone:YES];
}

#pragma mark -
#pragma mark Private methods

- (void)updateOnlineBasket:(NSArray *)productDetails {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[self setUpdatingOnlineBasket:YES];
	
	NSString *productID = [productDetails objectAtIndex:0];
	NSNumber *quantity = [productDetails objectAtIndex:1];
	
	[onlineUpdateLock lock];
	//Need to ensure correct value ends up being assigned
	[self setOnlineBasketUpdates: ++onlineBasketUpdates];
	[LogManager log:[NSString stringWithFormat:@"Number of online basket updates remaining is %d", onlineBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];
	[self setOverlayLoadingLabelText: [NSString stringWithFormat:@"%d update(s) left",onlineBasketUpdates]];
	[onlineUpdateLock unlock];
	
	
	[apiRequestManager updateBasketQuantity:productID byQuantity:quantity];
	
	[onlineUpdateLock lock];
	//Need to ensure correct value ends up being assigned
	[self setOnlineBasketUpdates: --onlineBasketUpdates];
	
	[LogManager log:[NSString stringWithFormat:@"Number of online basket updates remaining is %d", onlineBasketUpdates] withLevel:LOG_INFO fromClass:[[self class] description]];
	[self setOverlayLoadingLabelText: [NSString stringWithFormat:@"%d update(s) left",onlineBasketUpdates]];
	[onlineUpdateLock unlock];
	
	if (onlineBasketUpdates == 0) {
		[self setOverlayLoadingLabelText:@""];
		
		/* If synch is gonna cause more updates return (since were gonna end up here again!) */
		if ([self synchronizeOnlineOfflineBasket]) {
			return;
		}
		
		[LogManager log:@"Online basket update complete, with no additional requests generated after synch" withLevel:LOG_INFO fromClass:[[self class] description]];
		
		/* Only when baskets match can we send out notification */
		[self setUpdatingOnlineBasket:NO];
		
		/* send out notification */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"OnlineBasketUpdateComplete" object:self];
	}
	
	[pool release];
}

- (void)updateProduct:(Product *)product {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	Product *updatedProduct = [apiRequestManager createProductFromProductBaseID:[NSString stringWithFormat:@"%d", [[product productID] intValue]] fetchImages:YES];
	[product setProductOffer:[updatedProduct productOffer]];
	[product setProductOfferImage:[updatedProduct productOfferImage]];
	[product setProductOfferValidity:[updatedProduct productOfferValidity]];
	[product setMaxAmount:[updatedProduct maxAmount]];
	
	[pool release];
}

@end