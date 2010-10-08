//
//  ProductBasketManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 09/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ProductBasketManager.h"

@implementation ProductBasketManager

@synthesize productBasket;
@synthesize recipesInProductBasket;

- (id)init {
	if (self = [super init]) {
		productBasket = [[NSMutableDictionary alloc] init];
		recipesInProductBasket = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

- (void)emptyProductBasket {
	/* remove any objects currently in the product basket */
	[productBasket removeAllObjects];
}

- (void)addedRecipeToProductBasket:(Recipe *)recipe withQuantity:(NSNumber *)quantity {
	NSNumber *recipeCount = [NSNumber numberWithInt:[[recipesInProductBasket objectForKey:recipe] intValue] + [quantity intValue]];
	[recipesInProductBasket setObject:recipeCount forKey:recipe];
}

- (void)removedRecipeFromProductBasket:(Recipe *)recipe {
	[recipesInProductBasket removeObjectForKey:recipe];
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
}

@end