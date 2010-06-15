//
//  ApplicationDataManager.h
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBRecipe.h"
#import "DBProduct.h"


@interface ApplicationRequestManager : NSObject {
	NSMutableArray *recipeBasket;
	NSMutableDictionary *productBasket;
}

@property (nonatomic,retain) NSMutableArray *recipeBasket;
@property (nonatomic,retain) NSMutableDictionary *productBasket;

- (id)init;
- (void)addRecipeToBasket: (DBRecipe*)recipe;
- (void)addProductToBasket: (DBProduct*)product;
- (NSInteger)getRecipeBasketSize;

@end
