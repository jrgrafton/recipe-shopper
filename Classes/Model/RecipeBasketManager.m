//
//  RecipeBasketManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 08/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "RecipeBasketManager.h"

@implementation RecipeBasketManager

@synthesize recipeBasket;

- (id)init {
	if (self = [super init]) {
		[self setRecipeBasket:[NSMutableArray array]];
	}
	
	return self;
}

- (void)emptyRecipeBasket {
	/* remove any recipes from the recipe basket */
	[recipeBasket removeAllObjects];
}

- (void)addRecipeToBasket:(Recipe *)recipe {
	[[self recipeBasket] addObject:[recipe retain]];
}

- (void)removeRecipeFromBasket:(Recipe *)recipe {
	[[self recipeBasket] removeObjectAtIndex:[[self recipeBasket] indexOfObject:recipe]];
}

@end
