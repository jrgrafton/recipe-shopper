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
@synthesize productsUnavailableOnline;
@synthesize productBasketPrice;
@synthesize shoppingListProducts;

- (id)init {
	if (self = [super init]) {
		productBasket = [[NSMutableDictionary alloc] init];
		productsUnavailableOnline = [[NSMutableDictionary alloc] init];
		dataManager = [DataManager getInstance]; 
		updateLock = [[NSLock alloc] init];
		[self setProductBasketPrice:@"£0.00"];
		[self setShoppingListProducts:[NSNumber numberWithInt:0]];
	}
	
	return self;
}

- (void)emptyProductBasket {
	/* remove any objects currently in the product basket */
	[productBasket removeAllObjects];
}
					   
- (NSDictionary*) getProductBasketSync {
	[updateLock lock]; /* Ensure we can not get the product basket as its being updated */
	[updateLock unlock];
	return productBasket;
}

- (void)updateProductBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity {
	[product retain]; /* Temporary fix!!! */	
	
	/* Need to ensure only one thread at a time can access, so we don't simultaneous read/write*/
	[updateLock lock];
	
	int newQuantity = [[productBasket objectForKey:product] intValue] + [quantity intValue];
	
	if ((newQuantity > 0) && (newQuantity <= 99)) {
		/* just change the quantity for this product to the new value */
		[productBasket setObject:[NSNumber numberWithInt:newQuantity] forKey:product];
	} else if (newQuantity > 99) {
		/* can't have more than 99 so just set it to 99 */
		[productBasket setObject:[NSNumber numberWithInt:99] forKey:product];
	} else {
		/* must have removed all of this product so remove the product altogether */
		[productBasket removeObjectForKey:product];
		/* Remove it from unavailable online as well (will do nothing if it doesn't exist there) */
		[productsUnavailableOnline removeObjectForKey:product];
	}
	
	[self recalculateBasketPrice];
	[self setShoppingListProducts:[NSNumber numberWithInt:[dataManager getTotalProductCount]]];
	
	[updateLock unlock];
}

- (void)markProductUnavailableOnline:(Product *)product {
	@synchronized(self) {	
		if ([productsUnavailableOnline objectForKey:[product productID]] == nil) {
			[product removeProductOffer]; /* Don't care about product offer if it doesn't exist online */
			[productsUnavailableOnline setObject:[product productID] forKey:product];
		}
	}
}

#pragma mark -
#pragma mark Private methods

- (void)recalculateBasketPrice {
	NSEnumerator *productsEnumerator = [productBasket keyEnumerator];
	Product *product;
	CGFloat basketPrice = 0;
	
	while ((product = [productsEnumerator nextObject])) {
		basketPrice += [[productBasket objectForKey:product] intValue] * [[product productPrice] floatValue];
	}
	
	[self setProductBasketPrice:[NSString stringWithFormat:@"£%.2f", basketPrice]];
}

- (void)dealloc {
	[productsUnavailableOnline release];
	[productBasket release];
	[super dealloc];
}

@end