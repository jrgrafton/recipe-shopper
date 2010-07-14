//
//  RequestManager.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APIRequestManager : NSObject {

	@private
	NSString *authenticatedSessionKey;
	NSDate *authenticatedTime;
}

- (NSArray*)fetchProductsMatchingSearchTerm: (NSString*)searchTerm onThisPage:(NSInteger) pageNumber andGiveMePageCount:(NSInteger*) pageCountHolder;
- (BOOL)loginToStore:(NSString*) email withPassword:(NSString*) password;
- (NSArray*)filterAvailableProducts:(NSArray*)productIdList;
- (BOOL)addProductBasketToStoreBasket;
- (id)init;

@end
