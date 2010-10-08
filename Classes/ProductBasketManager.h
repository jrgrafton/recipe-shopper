//
//  ProductBasketManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 09/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"
#import "Recipe.h"

@interface ProductBasketManager : NSObject {
}

@property (nonatomic, retain) NSMutableDictionary *productBasket;
@property (nonatomic, retain) NSMutableDictionary *recipesInProductBasket;

- (id)init;
- (void)emptyProductBasket;
- (void)addedRecipeToProductBasket:(Recipe *)recipe withQuantity:(NSNumber *)quantity;
- (void)removedRecipeFromProductBasket:(Recipe *)recipe;
- (void)updateProductBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity;

@end