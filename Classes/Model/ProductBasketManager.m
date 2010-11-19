//
//  ProductBasketManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 09/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ProductBasketManager.h"
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
		productBasket = [[NSMutableDictionary alloc] init];
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

- (void)updateProductBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity {
	int newQuantity = [[productBasket objectForKey:product] intValue] + [quantity intValue];
	
	if ((newQuantity > 0) && (newQuantity <= 99)) {
		/* just change the quantity for this product to the new value */
		[productBasket setObject:[NSNumber numberWithInt:newQuantity] forKey:[product retain]];
	} else if (newQuantity > 99) {
		/* can't have more than 99 so just set it to 99 */
		[productBasket setObject:[NSNumber numberWithInt:99] forKey:[product retain]];
	} else {
		/* must have removed all of this product so remove the product altogether */
		[productBasket removeObjectForKey:[product retain]];
	}
	
	/* Need to ensure only one thread at a time can re-calculate totals - don't wan't context switch here!!*/
	[updateLock lock];
	[self recalculateBasketPrice];
	[self setShoppingListProducts:[NSNumber numberWithInt:[dataManager getTotalProductCount]]];
	[updateLock unlock];
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
	[updateLock release];
}

@end