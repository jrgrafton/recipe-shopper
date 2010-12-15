//
//  ProductBasketManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 09/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ProductBasketManager.h"
#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"

@interface ProductBasketManager()
- (void)recalculateBasketPrice;
@end

@implementation ProductBasketManager

@synthesize productBasket;
@synthesize productBasketPrice;
@synthesize shoppingListProducts;

- (id)init {
	if (self = [super init]) {
		updateLock = [[NSRecursiveLock alloc] init];
		backingProductArray = [[NSMutableArray alloc] init];
		productBasket = [[NSMutableDictionary alloc] init];
		productsUnavailableOnline = [[NSMutableArray alloc] init];
		dataManager = [DataManager getInstance]; 

		[self setProductBasketPrice:@"£0.00"];
		[self setShoppingListProducts:[NSNumber numberWithInt:0]];
	}
	
	return self;
}

- (void)emptyProductBasket {
	/* remove any objects currently in the product basket */
	[productBasket removeAllObjects];
	[backingProductArray removeAllObjects];
	[productsUnavailableOnline removeAllObjects];
}
					   
- (NSDictionary*) getProductBasketSync {
	[updateLock lock]; /* Ensure we can not get the product basket as its being updated */
	[updateLock unlock];
	return productBasket;
}

- (NSInteger)getTotalProductCount {
	[updateLock lock];
	NSInteger totalProductCount = 0;
	
	for (NSNumber *quantity in [productBasket allValues]) {
		totalProductCount += [quantity intValue];
	}
    [updateLock unlock];
	return totalProductCount;
}

- (NSInteger)getDistinctProductCount {
	[updateLock lock];
	[updateLock unlock];
	return [backingProductArray count];
}

- (Product *)getProductFromBasket:(NSUInteger)productIndex {
	[updateLock lock];
	[updateLock unlock];
	
	return ([backingProductArray count] > productIndex)? 
	[backingProductArray objectAtIndex:productIndex] : nil;
	
}

- (NSNumber *)getProductQuantityFromBasket:(Product *)product {
	[updateLock lock];
	[updateLock unlock];
	return [productBasket objectForKey:product];
}

- (NSInteger)getDistinctUnavailableOnlineCount {
	[updateLock lock];
	[updateLock unlock];
	
	return [productsUnavailableOnline count];
}

- (Product *)getUnavailableOnlineProduct:(NSUInteger)productIndex {
	[updateLock lock];
	[updateLock unlock];
	
	return ([productsUnavailableOnline count] > productIndex)? 
	[productsUnavailableOnline objectAtIndex:productIndex] : nil;
}

- (NSInteger)getDistinctAvailableOnlineCount {
	return [self getDistinctProductCount] - [self getDistinctUnavailableOnlineCount];
}

- (Product *)getAvailableOnlineProduct:(NSUInteger)productIndex {
	[updateLock lock];
	
	NSMutableArray* availableOnlineProducts = [[[NSMutableArray alloc] initWithArray: backingProductArray copyItems:YES] autorelease];
	[availableOnlineProducts removeObjectsInArray: productsUnavailableOnline];
	
	[updateLock unlock];
	
	return ([availableOnlineProducts count] > productIndex)? [availableOnlineProducts objectAtIndex:productIndex] : nil;
}

- (Product*)getProductByBaseID:(NSString*)productBaseID {
	[updateLock lock];
	
	for (Product *product in backingProductArray) {
		if ([productBaseID intValue] == [[product productBaseID] intValue]) {
			[updateLock unlock];
			return product;
		}
	}
	
	[updateLock unlock];
	return nil;
}

- (void)updateProductBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity {
	[product retain];	
	
	/* Need to ensure only one thread at a time can access, so we don't simultaneous read/write*/
	[updateLock lock];
	
	int currentValue = [[productBasket objectForKey:product] intValue];
	
	if (currentValue == 0) {
		/* If we have new product add it to backing productArray */
		[backingProductArray addObject:product];
	}
	
	int newQuantity = currentValue + [quantity intValue];
	
	if ((newQuantity > 0) && (newQuantity <= [product maxAmount])) {
		/* just change the quantity for this product to the new value */
		[productBasket setObject:[NSNumber numberWithInt:newQuantity] forKey:product];
	} else if (newQuantity > [product maxAmount]) {
		/* ensure we cap quantities at maxAmount */
		[productBasket setObject: [NSNumber numberWithInt:[product maxAmount]] forKey:product];
	} else {
		/* must have removed all of this product so remove the product altogether */
		[productBasket removeObjectForKey:product];
		/* Remove it from unavailable online as well (will do nothing if it doesn't exist there) */
		[productsUnavailableOnline removeObject:product];
		/* Remove it from backing array as well*/
		[backingProductArray removeObject:product];
	}
	
	[self recalculateBasketPrice];
	[self setShoppingListProducts:[NSNumber numberWithInt:[dataManager getTotalProductCount]]];
	
	[updateLock unlock];
}

- (void)markProductUnavailableOnline:(Product *)product {
	[updateLock lock];	
	
	if (![productsUnavailableOnline containsObject:product]) {
		[product removeProductOffer];
		[productsUnavailableOnline addObject:product];
	}

	[updateLock unlock];
}

#pragma mark -
#pragma mark Private methods

- (void)recalculateBasketPrice {
	[updateLock lock];
	
	NSEnumerator *productsEnumerator = [productBasket keyEnumerator];
	Product *product;
	CGFloat basketPrice = 0;
	
	while ((product = [productsEnumerator nextObject])) {
		basketPrice += [[productBasket objectForKey:product] intValue] * [[product productPrice] floatValue];
	}
	
	[self setProductBasketPrice:[NSString stringWithFormat:@"£%.2f", basketPrice]];

	[updateLock unlock];
}

- (void)dealloc {
	[productsUnavailableOnline release];
	[productBasket release];
	[backingProductArray release];
	[super dealloc];
}

@end