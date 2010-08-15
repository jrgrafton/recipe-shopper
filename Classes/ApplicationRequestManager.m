//
//  ApplicationDataManager.m
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "ApplicationRequestManager.h"
#import "DataManager.h"
#import "LogManager.h"

@implementation ApplicationRequestManager

@synthesize recipeBasket;

- (id)init{
	if (self = [super init]) {
		[self setRecipeBasket:[NSMutableArray array]];
		productBasket = [[NSMutableDictionary alloc]init];
	}
	return self;
}

- (void)addRecipeToBasket: (DBRecipe*)recipe{
	[recipeBasket addObject:recipe];
}

- (void)addProductToBasket: (DBProduct*)product{
	NSNumber* count = [productBasket objectForKey:product];
	
	if (count == nil) {
		count = [NSNumber numberWithInt:1];
	}else{
		count = [NSNumber numberWithInt:[count intValue] + 1];
	}
	[productBasket setObject:count forKey:product];
}

- (void)removeProductFromBasket: (DBProduct*)product{
	[productBasket removeObjectForKey:product];
}

//Override getter for productBasket to return keyset
- (NSArray*)getProductBasket {
	return [productBasket allKeys];
}
- (NSInteger)getCountForProduct: (DBProduct*)product{
	//Always assumes that product exists
	return [[productBasket objectForKey:product] intValue];
}

- (void)decreaseCountForProduct: (DBProduct*)product{
	NSNumber* count = [productBasket objectForKey:product];
	
	if ([count intValue] > 0) {
		count = [NSNumber numberWithInt:[count intValue] - 1];
		
		if ([count intValue] == 0) {
			[productBasket removeObjectForKey:product];
		} else {
			[productBasket setObject:count forKey:product];
		}
	}
}

- (void)increaseCountForProduct: (DBProduct*)product{
	NSNumber* count = [productBasket objectForKey:product];
	
	if ([count intValue] < 99) {
		count = [NSNumber numberWithInt:[count intValue] + 1];
	}
	
	[productBasket setObject:count forKey:product];
}

- (NSInteger)getTotalProductCount {
	NSArray *valueSet = [productBasket allValues];
	NSInteger totalCount = 0;
	
	for (NSNumber* value in valueSet) {
		totalCount += [value intValue];
	}
	
	return totalCount;
}

- (CGFloat)getTotalProductBasketCost {
	NSArray *keySet = [productBasket allKeys];
	CGFloat totalPrice = 0;
	
	for (DBProduct* product in keySet) {
		totalPrice += ([[product productPrice] floatValue] * [[productBasket objectForKey:product] floatValue]);
	}
	
	return totalPrice;
}


- (void)createProductListFromRecipeBasket {
	[LogManager log:@"Creating product list from recipe basket" withLevel:LOG_INFO fromClass:@"ApplicationRequestManager"];
	
	//Ensure we first remove all non user added products from basket
	if ([productBasket count] > 0) {
		
		NSMutableArray *toRemove = [NSMutableArray array];
		NSArray *productKeys = [productBasket allKeys];
		
		for (DBProduct* product in productKeys) {
				[toRemove addObject:product];
		}
		
		[productBasket removeObjectsForKeys:toRemove];
	}
	
	NSMutableDictionary *productIDToCountMap = [NSMutableDictionary dictionary];
	
	//First figure out total for all products we need and fetch them from the DB
	for (DBRecipe *recipe in recipeBasket) {
		
		NSArray *productIDs = [recipe idProducts];
		
		NSUInteger productIndex = 0;
		
		for (NSNumber *productID in productIDs) {
			
			NSNumber *productCount = [[recipe idProductsQuantity] objectAtIndex:productIndex];
			
			for (int i=0; i<[productCount intValue]; i++) {
				NSNumber *productTotalCount = [productIDToCountMap objectForKey:productID];
				
				if (productTotalCount == nil) {
					[productIDToCountMap setObject:[NSNumber numberWithInt:1] forKey:productID];
				} else {
					productTotalCount = [NSNumber numberWithInt:[productTotalCount intValue] + 1];
					[productIDToCountMap setObject:productTotalCount forKey:productID];
				}
			}
			
			productIndex++;
		}
	}
	
	//Now add all the DBProduct objects to the product basket
	NSArray *individualProducts = [DataManager fetchProductsFromIDs:[productIDToCountMap allKeys]];
	
	for (DBProduct *product in individualProducts) {
		//Keys always seem to be converted to NSString objects
		NSNumber *productCount = [productIDToCountMap objectForKey:[NSString stringWithFormat:@"%@",[product productID]]];
				
	    for (int i=0; i<[productCount intValue]; i++) {
			[self addProductToBasket:product];
		}
	}
	
	[LogManager log:@"Successfully created list from recipe basket" withLevel:LOG_INFO fromClass:@"ApplicationRequestManager"];
}
@end
