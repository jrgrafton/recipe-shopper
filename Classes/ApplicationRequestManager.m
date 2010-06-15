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
		[self setProductBasket:[NSMutableDictionary dictionary]];
	}
	return self;
}

- (void)addRecipeToBasket: (DBRecipe*)recipe{
	[recipeBasket addObject:recipe];
}

- (void)addProductToBasket: (DBProduct*)product{
	NSNumber* count = [productBasket objectForKey:product];
	
	if(count == nil){
		[productBasket setObject:[NSNumber numberWithInt:1] forKey:product];
	}else{
		count = [NSNumber numberWithInt:[count intValue] + 1];
		[productBasket setObject:count forKey:product];
	}
}

- (NSInteger)getRecipeBasketSize{
	return [recipeBasket count];
}
@end
