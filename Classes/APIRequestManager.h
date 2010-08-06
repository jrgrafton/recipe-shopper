//
//  RequestManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIDeliverySlot.h"
#import "LoadingView.h"

@interface APIRequestManager : NSObject {

	@private
	NSString *authenticatedSessionKey;
	NSDate *authenticatedTime;
	volatile NSInteger currentAsyncRequestCount;
	volatile NSMutableDictionary *JSONRequestResults;
	volatile NSMutableArray *JSONRequestQueue;
}

//Currently only called locally (so we can clear basket before adding items to it)
- (NSArray*)fetchBasketSummary;
- (void)clearProductBasket;

- (NSArray*)fetchProductsMatchingSearchTerm: (NSString*)searchTerm onThisPage:(NSInteger) pageNumber andGiveMePageCount:(NSInteger*) pageCountHolder;
- (NSArray*)fetchAvailableDeliverySlots;
- (BOOL)loginToStore:(NSString*) email withPassword:(NSString*) password;
- (NSArray*)getFilteredProductList:(NSArray*)productIdList;
- (BOOL)addProductBasketToStoreBasket;
- (BOOL)chooseDeliverySlot:(APIDeliverySlot*)deliverySlot returningError:(NSString**)error;
- (NSDate*)verifyOrder:(NSString**)error;

- (id)init;

@end
