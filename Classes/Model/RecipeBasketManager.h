//
//  RecipeBasketManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 08/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Recipe.h"

@interface RecipeBasketManager : NSObject {
	NSMutableArray *recipeBasket;
}

@property (nonatomic, retain) NSMutableArray *recipeBasket;

- (void)emptyRecipeBasket;
- (void)addRecipeToBasket:(Recipe *)recipe;
- (void)removeRecipeFromBasket:(Recipe *)recipe;

@end
