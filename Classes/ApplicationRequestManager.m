//
//  ApplicationDataManager.m
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "ApplicationRequestManager.h"


@implementation ApplicationRequestManager

@synthesize shoppingBasket;

- (id)init{
	if (self = [super init]) {
		[self setShoppingBasket:[NSMutableArray array]];
	}
	return self;
}

- (void)addRecipeToBasket: (DBRecipe*)recipe{
	[shoppingBasket addObject:recipe];
}

- (NSInteger)getBasketSize{
	return [shoppingBasket count];
}
@end
