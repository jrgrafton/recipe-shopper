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

@class DataManager;

@interface ProductBasketManager : NSObject {
	@private
		DataManager *dataManager;
		NSLock *updateLock;
}

@property (retain) NSMutableDictionary *productBasket;
@property (retain) NSString *productBasketPrice;
@property (retain) NSNumber *shoppingListProducts;

- (id)init;
- (void)emptyProductBasket;
- (void)updateProductBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity;

@end