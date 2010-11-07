//
//  APIRequestManager.h
//  RecipeShopper
//
//  Created by Simon Barnett on 10/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface APIRequestManager : NSObject {
@private 
	NSString *sessionKey;
	NSMutableDictionary *departments;
	NSMutableDictionary *aisles;
	NSMutableDictionary *shelves;
	
	NSMutableArray *shelfProductCache; /* Shelf result cache so we can simulate pagination */
}

@property (nonatomic) BOOL offlineMode;
@property (nonatomic) BOOL loggedIn;
@property (nonatomic, retain) NSString *customerName;

- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password;
- (void)logoutOfStore;
- (NSDictionary *)getOnlineBasket;
- (Product *)createProductFromProductBaseID:(NSString *)productBaseID fetchImages:(BOOL)fetchImages;
- (NSArray *)getDepartments;
- (NSArray *)getAislesForDepartment:(NSString *)department;
- (NSArray *)getShelvesForAisle:(NSString *)aisle;
- (NSArray *)getProductsForShelf:(NSString *)shelf onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
- (NSDictionary *)getBasketDetails;
- (BOOL)updateBasketQuantity:(NSString *)productID byQuantity:(NSNumber *)quantity;
- (NSDictionary *)getDeliveryDates;
- (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder;
- (BOOL)chooseDeliverySlot:(NSString *)deliverySlotID returningError:(NSString **)error;
- (void)fetchImagesForProduct:(Product*) product;

@end
