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
	
	//Handled as DBProduct => Count for UI ease
	NSMutableDictionary *productBasket;
}

@property (nonatomic,retain) NSMutableArray *recipeBasket;

- (id)init;
- (void)addRecipeToBasket: (DBRecipe*)recipe;
- (void)addProductToBasket: (DBProduct*)product;
- (void)removeProductFromBasket: (DBProduct*)product;
- (NSArray*)getProductBasket;
- (NSUInteger)getCountForProduct: (DBProduct*)product;
- (void)decreaseCountForProduct: (DBProduct*)product;
- (void)increaseCountForProduct: (DBProduct*)product;
- (NSUInteger)getTotalProductCount;
- (NSString*)getTotalProductBasketCost;
- (void)createProductListFromRecipeBasket;

@end
