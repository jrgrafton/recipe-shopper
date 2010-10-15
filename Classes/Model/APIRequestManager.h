//
//  APIRequestManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 10/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIRequestManager : NSObject {
	volatile NSInteger currentAsyncRequestCount;
	volatile NSMutableDictionary *requestResults;
@private NSString *sessionKey;
@private NSMutableDictionary *departments;
@private NSMutableDictionary *aisles;
@private NSMutableDictionary *shelves;
}

@property (nonatomic) BOOL offlineMode;
@property (nonatomic) BOOL loggedIn;
@property (nonatomic, retain) NSString *customerName;

- (id)init;
- (NSArray *)createProductsFromProductBaseIDs:(NSDictionary *)productBaseIdList;
- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password;
- (NSArray *)getDepartments;
- (NSArray *)getAislesForDepartment:(NSString *)department;
- (NSArray *)getShelvesForAisle:(NSString *)aisle;
- (NSArray *)getProductsForShelf:(NSString *)shelf;
- (BOOL)addProductBasketToBasket;
- (NSDictionary *)getBasketDetails;
- (BOOL)updateBasketQuantity:(NSString *)productID byQuantity:(NSNumber *)quantity;
- (NSDictionary *)getDeliveryDates;
- (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
- (void)chooseDeliverySlot:(NSString *)deliverySlotID;

@end
