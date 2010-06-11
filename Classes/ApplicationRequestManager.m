//
//  ApplicationDataManager.m
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "ApplicationRequestManager.h"


@implementation ApplicationRequestManager

@synthesize recipeBasket,productBasket;

- (id)init{
	if (self = [super init]) {
		[self setRecipeBasket:[NSMutableArray array]];
		[self setProductBasket:[NSMutableArray array]];
	}
	return self;
}

- (void)addRecipeToBasket: (DBRecipe*)recipe{
	[recipeBasket addObject:recipe];
}

- (NSInteger)getRecipeBasketSize{
	return [recipeBasket count];
}
@end
