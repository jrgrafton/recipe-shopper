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
		NSRecursiveLock *updateLock;
		NSMutableArray *backingProductArray;
		NSMutableArray *productsUnavailableOnline;
}

@property (retain) NSMutableDictionary *productBasket;
@property (retain) NSString *productBasketPrice;
@property (retain) NSNumber *shoppingListProducts;

- (id)init;
- (void)emptyProductBasket;
- (NSInteger)getTotalProductCount;
- (NSInteger)getDistinctProductCount;
- (Product *)getProductFromBasket:(NSUInteger)productIndex;
- (NSNumber *)getProductQuantityFromBasket:(Product *)product;
- (NSInteger)getDistinctUnavailableOnlineCount;
- (Product *)getUnavailableOnlineProduct:(NSUInteger)productIndex;
- (NSInteger)getDistinctAvailableOnlineCount;
- (Product *)getAvailableOnlineProduct:(NSUInteger)productIndex;
- (NSDictionary*)getProductBasketSync;
- (Product*)getProductByBaseID:(NSString*)productBaseID;
- (void)updateProductBasketQuantity:(Product *)product byQuantity:(NSNumber *)quantity;
- (void)markProductUnavailableOnline:(Product *)product;

@end