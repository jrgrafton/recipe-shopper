//
//  APIRequestManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 10/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "APIRequestManager.h"
#import "JSON.h"
#import "Product.h"
#import "LogManager.h"
#import "DeliverySlot.h"

#define DEVELOPER_KEY @"xIvRaeGkY6OavPL1XtX9"
#define APPLICATION_KEY @"CA1A9E0437CBE399E890"
#define REST_SERVICE_URL @"https://secure.techfortesco.com/groceryapi_b1/restservice.aspx"
#define SHELF_SIMULATED_PAGE_SIZE 15

@interface APIRequestManager()

- (BOOL)apiRequest:(NSString *)requestString returningApiResults:(NSDictionary **)apiResults returningError:(NSString **)error;
- (BOOL)login:(NSString *)email withPassword:(NSString *)password;
- (NSString *)urlEncodeValue:(NSString *)requestString;
- (Product *)createProductFromJSON:(NSDictionary *)productJSON fetchImages:(BOOL)fetchImages;

@end

@implementation APIRequestManager

@synthesize offlineMode;
@synthesize loggedIn;
@synthesize customerName;

- (id)init {
	if (self = [super init]) {
		departments = [[NSMutableDictionary alloc] init];
		aisles = [[NSMutableDictionary alloc] init];
		shelves = [[NSMutableDictionary alloc] init];
		shelfProductCache = [[NSMutableArray alloc] init];
		
		sessionKey = @"";
		
		if (sessionKey == @"") {
			/* create an anonymous session key */
			if ([self login:@"" withPassword:@""] == YES) {
				[LogManager log:[NSString stringWithFormat:@"Created anonymous login with session key: %@", sessionKey] withLevel:LOG_INFO fromClass:[[self class] description]];
			} else {
				[LogManager log:[NSString stringWithFormat:@"Failed to create anonymous login"] withLevel:LOG_ERROR fromClass:[[self class] description]];
			}
		}
		
		[self setLoggedIn:NO];
	}
	
	return self;
}

- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password {
	[self setLoggedIn:[self login:email withPassword:password]];
	return [self loggedIn];
}

- (void)logoutOfStore {
	/* go back to using an anonymous session key */
	if ([self login:@"" withPassword:@""] == YES) {
		[LogManager log:[NSString stringWithFormat:@"Created anonymous login with session key: %@", sessionKey] withLevel:LOG_INFO fromClass:[[self class] description]];
	} else {
		[LogManager log:[NSString stringWithFormat:@"Failed to create anonymous login"] withLevel:LOG_ERROR fromClass:[[self class] description]];
	}
	
	[self setLoggedIn:NO];
}

- (NSDictionary *)getOnlineBasket {
	NSMutableDictionary *onlineBasket = [[NSMutableDictionary alloc] init];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTBASKETSUMMARY&sessionkey=%@", REST_SERVICE_URL, sessionKey];
	
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error];
	
	if (apiRequestOK == YES) {
		for (NSDictionary *product in [apiResults objectForKey:@"BasketLines"]) {
			NSString *productID = [product objectForKey:@"ProductId"];
			NSString *quantity = [product objectForKey:@"BasketLineQuantity"];
			[onlineBasket setObject:quantity forKey:productID];
		}
	}
	
	return onlineBasket;
}

- (Product *)createProductFromProductBaseID:(NSString *)productBaseID fetchImages:(BOOL)fetchImages{
    NSString *requestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&sessionkey=%@", REST_SERVICE_URL, productBaseID, sessionKey];
    NSDictionary *apiResults;
    NSString *error;
    Product *product;
    
    if ([self apiRequest:requestString returningApiResults: &apiResults returningError:&error] == YES) {
        NSString *totalProducts = [apiResults objectForKey:@"TotalProductCount"];
        
        if ([totalProducts intValue] == 0) {
            /* couldn't find the product ID in the online store */
            return nil;
        } else {
            /* assume its a single product, so we want the first (and only) one */
            product = [self createProductFromJSON:[[apiResults objectForKey:@"Products"] objectAtIndex:0] fetchImages:fetchImages];
        }
    } else {
        /* API request for search has failed */
        return nil;
    }
    
    return product;
}

- (NSArray *)getDepartments {
	if ([[departments allKeys] count] != 0) {
		return [departments allKeys];
	}
	
	NSDictionary *apiResults;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTPRODUCTCATEGORIES&sessionkey=%@", REST_SERVICE_URL, sessionKey];
	NSString *error;
	
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error] == YES) {
		for (NSDictionary *department in [apiResults objectForKey:@"Departments"]) {
			[departments setObject:[department objectForKey:@"Aisles"] forKey:[department objectForKey:@"Name"]];
			
			for (NSDictionary *aisle in [department objectForKey:@"Aisles"]) {
				[aisles setObject:[aisle objectForKey:@"Shelves"] forKey:[aisle objectForKey:@"Name"]];
				
				for (NSDictionary *shelf in [aisle objectForKey:@"Shelves"]) {
					[shelves setObject:[shelf objectForKey:@"Id"] forKey:[shelf objectForKey:@"Name"]];
				}
			}
		}
	}
	
	return [departments allKeys];
}

- (NSArray *)getAislesForDepartment:(NSString *)department {
	NSMutableArray *aisleNames = [NSMutableArray array];
	
	for (NSDictionary *aisle in [departments objectForKey:department]) {
		[aisleNames addObject:[aisle objectForKey:@"Name"]];
	}
	
	return aisleNames;
}

- (NSArray *)getShelvesForAisle:(NSString *)aisle {
	NSMutableArray *shelfNames = [NSMutableArray array];
	
	for (NSDictionary *shelf in [aisles objectForKey:aisle]) {
		[shelfNames addObject:[shelf objectForKey:@"Name"]];
	}
	
	return shelfNames;
}

- (NSArray *)getProductsForShelf:(NSString *)shelf onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder {
	if (page == 1) {
		[shelfProductCache removeAllObjects];
		NSDictionary *apiResults;
		NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTPRODUCTSBYCATEGORY&category=%@&sessionkey=%@", REST_SERVICE_URL, [shelves objectForKey:shelf], sessionKey];
		NSString *error;
		
		//NSTimeInterval start = [[NSDate date]timeIntervalSince1970];
		
		if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error] == YES) {
			for (NSDictionary *productInfo in [apiResults objectForKey:@"Products"]) {
				[shelfProductCache addObject:[self createProductFromJSON:productInfo  fetchImages:NO]];
			}
		}
		//NSTimeInterval end = [[NSDate date] timeIntervalSince1970];
		//NSLog(@"Operation took: %f secs",end - start);
	}
	
	*totalPageCountHolder = ([shelfProductCache count] / SHELF_SIMULATED_PAGE_SIZE) + 1;
	
	NSInteger startPageProductIndex = (page - 1) * SHELF_SIMULATED_PAGE_SIZE;
	NSInteger indexCount = (startPageProductIndex + SHELF_SIMULATED_PAGE_SIZE < [shelfProductCache count])?
									SHELF_SIMULATED_PAGE_SIZE : [shelfProductCache count] - startPageProductIndex;
	
	return [shelfProductCache subarrayWithRange:NSMakeRange(startPageProductIndex, indexCount)];
}

- (NSDictionary *)getBasketDetails {
	NSMutableDictionary *basketDetails = [NSMutableDictionary dictionary];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTBASKET&sessionkey=%@", REST_SERVICE_URL, sessionKey];
	
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error] == YES) {
		[basketDetails setObject:[apiResults objectForKey:@"BasketGuidePrice"] forKey:@"BasketPrice"];
		[basketDetails setObject:[apiResults objectForKey:@"BasketGuideMultiBuySavings"] forKey:@"BasketSavings"];
		[basketDetails setObject:[apiResults objectForKey:@"BasketTotalClubcardPoints"] forKey:@"BasketPoints"];
	}
	
	return basketDetails;
}

- (BOOL)updateBasketQuantity:(NSString *)productID byQuantity:(NSNumber *)quantity {
	BOOL basketAlteredOK = NO;
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&productid=%@&changequantity=%@&sessionkey=%@", REST_SERVICE_URL, productID, quantity, sessionKey];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error];
	
	if (apiRequestOK == TRUE) {
		basketAlteredOK = YES;
	}
	
	return basketAlteredOK;
}

/*
 * Gets a list of available delivery slots and their price
 */
- (NSDictionary *)getDeliveryDates {
	NSMutableDictionary *deliveryDates = [[NSMutableDictionary alloc] init];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTDELIVERYSLOTS&sessionkey=%@", REST_SERVICE_URL, sessionKey];
		
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error] == YES) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		
		NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[timeFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[timeFormatter setDateFormat:@"HH:mm"];
		 
		NSEnumerator *deliverySlotEnumerator = [[apiResults objectForKey:@"DeliverySlots"] objectEnumerator];
		NSDictionary *deliverySlotInfo;
		
		while ((deliverySlotInfo = [deliverySlotEnumerator nextObject])) {
			NSString *deliverySlotID = [NSString stringWithFormat:@"%@", [deliverySlotInfo objectForKey:@"DeliverySlotId"]];
			NSString *deliverySlotBranchNumber = [NSString stringWithFormat:@"%@", [deliverySlotInfo objectForKey:@"BranchNumber"]];
			
			NSArray *deliverySlotStartDetails = [[deliverySlotInfo objectForKey:@"SlotDateTimeStart"] componentsSeparatedByString:@" "];
			NSDate *deliverySlotDate = [dateFormatter dateFromString:[deliverySlotStartDetails objectAtIndex:0]];
			NSDate *deliverySlotStartTime = [timeFormatter dateFromString:[deliverySlotStartDetails objectAtIndex:1]];
			
			NSArray *deliverySlotEndDetails = [[deliverySlotInfo objectForKey:@"SlotDateTimeEnd"] componentsSeparatedByString:@" "];
			NSDate *deliverySlotEndTime = [timeFormatter dateFromString:[deliverySlotEndDetails objectAtIndex:1]];			

			NSString *deliverySlotCost = [deliverySlotInfo objectForKey:@"ServiceCharge"];
			
			DeliverySlot *deliverySlot = [[[DeliverySlot alloc] initWithDeliverySlotID:deliverySlotID 
														   andDeliverySlotBranchNumber:deliverySlotBranchNumber 
															  andDeliverySlotDate:deliverySlotDate
															  andDeliverySlotStartTime:deliverySlotStartTime
																andDeliverySlotEndTime:deliverySlotEndTime 
																   andDeliverySlotCost:deliverySlotCost] autorelease];
			
			if ([deliveryDates objectForKey:deliverySlotDate] == nil) {
				/* create a dictionary of times and delivery slots and add the current combination */
				NSMutableDictionary *deliveryTimeToSlot = [[NSMutableDictionary alloc] init];
				[deliveryTimeToSlot setObject:deliverySlot forKey:deliverySlotStartTime];
				
				/* add this delivery date (and corresponding time/slot array) to the delivery dates */
				[deliveryDates setObject:deliveryTimeToSlot forKey:deliverySlotDate];
			} else {
				/* this delivery date is already in the list so just add this delivery time to its time/slots array */
				[[deliveryDates objectForKey:deliverySlotDate] setObject:deliverySlot forKey:deliverySlotStartTime];
			}
		}
		
		[dateFormatter release];
		[timeFormatter release];
	}
	
	return deliveryDates;
}

/*
 * Searches for a particular string in the online store
 */
- (NSArray *)searchForProducts:(NSString *)searchTerm onPage:(NSInteger)page totalPageCountHolder:(NSInteger *)totalPageCountHolder {
	NSMutableArray *products = [NSMutableArray array];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&page=%d&sessionkey=%@", REST_SERVICE_URL, searchTerm, page, sessionKey];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error];
	
	if (apiRequestOK == TRUE) {
		NSEnumerator *productsEnumerator = [[apiResults objectForKey:@"Products"] objectEnumerator];
		NSDictionary *productInfo;
		
		*totalPageCountHolder = [[apiResults objectForKey:@"TotalPageCount"] intValue];
		
		while ((productInfo = [productsEnumerator nextObject])) {
			[products addObject:[self createProductFromJSON:productInfo fetchImages:NO]];
		}
	}
	
	return products;
}

- (BOOL)chooseDeliverySlot:(NSString *)deliverySlotID returningError:(NSString **)error {
	NSDictionary *apiResults;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=CHOOSEDELIVERYSLOT&deliveryslotid=%@&sessionkey=%@", REST_SERVICE_URL, deliverySlotID, sessionKey];

	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:error] == YES) {
		requestString = [NSString stringWithFormat:@"%@?command=READYFORCHECKOUT&sessionkey=%@", REST_SERVICE_URL, sessionKey];
		return [self apiRequest:requestString returningApiResults:&apiResults returningError:error];
	} else {
		return NO;
	}
}

- (void)fetchImagesForProduct:(Product*) product {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	UIImage *productImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[product productImageURL]]] autorelease];
	 
	 if (productImage == nil) {
		productImage = [UIImage imageNamed:@"icon_product_default.jpg"];
	 }
	 
	 UIImage *productOfferImage;
	 
	 if ([product productOfferImageURL] != nil) {
		productOfferImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[product productOfferImageURL]]] autorelease];
	 } else {
		productOfferImage = nil;
	 }
	
	[product setProductImage:productImage];
	[product setProductOfferImage:productOfferImage];
	
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[product productID],@"productID",nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"productImageFetchComplete" object:self userInfo:userInfo];
	
	[pool release];
}

#pragma mark -
#pragma mark private functions

- (BOOL)apiRequest:(NSString *)requestString returningApiResults:(NSDictionary **)apiResults returningError:(NSString **)error {
	BOOL apiReqOK = YES;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:[self urlEncodeValue:requestString]]];
	[request setHTTPMethod:@"GET"];
	
	[LogManager log:[NSString stringWithFormat:@"Sending request: '%@'", requestString] withLevel:LOG_INFO fromClass:[[self class] description]];
	
	/* send the GET request */
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if (data == nil) {
		[LogManager log:@"Request fetched no/invalid results" withLevel:LOG_INFO fromClass:[[self class] description]];
		apiReqOK = NO;
	} else {	
		NSMutableString *jsonString = [NSMutableString stringWithFormat:@"%@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
		
		/* parse the JSON results */
		SBJSON *parser = [[SBJSON alloc] init];
		NSError *jsonError = nil;
		NSDictionary *jsonResults = [parser objectWithString:jsonString error:&jsonError];
		[parser release];
		
		if (jsonResults == nil) {
			[LogManager log:[NSString stringWithFormat:@"Error retrieving JSON results: %@", [jsonError localizedDescription]] withLevel:LOG_ERROR fromClass:[[self class] description]];
			*error = [[[NSString alloc] initWithFormat:@"Tesco API endpoint unreachable"] autorelease];
			apiReqOK = NO;
		} else {
			NSNumber *statusCode = [jsonResults objectForKey:@"StatusCode"];
			
			if ([statusCode intValue] != 0) {
				[LogManager log:[NSString stringWithFormat:@"API error: '%@'", jsonResults] withLevel:LOG_ERROR fromClass:[[self class] description]];
				*error = [[[NSString alloc] initWithFormat:@"%@", [jsonResults objectForKey:@"StatusInfo"]] autorelease];
				apiReqOK = NO;
			} else {
				*apiResults = jsonResults;
			}
		}
	}
	
	[LogManager log:[NSString stringWithFormat:@"Received response for request: '%@'", requestString] withLevel:LOG_INFO fromClass:[[self class] description]];
	
	return apiReqOK;
}

/*
 * Logs the user in to the Tesco store using email and password
 */
- (BOOL)login:(NSString *)email withPassword:(NSString *)password {
	BOOL loggedInSuccessfully = NO;
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LOGIN&email=%@&password=%@&developerkey=%@&applicationkey=%@", REST_SERVICE_URL, email, password, DEVELOPER_KEY, APPLICATION_KEY];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error];
	
	if (apiRequestOK == TRUE) {
		[sessionKey = [apiResults objectForKey:@"SessionKey"] retain];
		[self setCustomerName:[apiResults objectForKey:@"CustomerName"]];
		loggedInSuccessfully = YES;
	}
	
	return loggedInSuccessfully;
}

/*
 * Encodes a URL
 */
- (NSString *)urlEncodeValue:(NSString *)requestString {
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(NULL,
																	(CFStringRef)requestString,
																	NULL,
																	(CFStringRef)@"!*'\"();@+$,%#[]% ",
																	kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
}

/*
 * Creates a product from the JSON info
 */
- (Product *)createProductFromJSON:(NSDictionary *)productJSON fetchImages:(BOOL)fetchImages {
	NSNumber *productBaseID = [NSNumber numberWithInt:[[productJSON objectForKey:@"BaseProductId"] intValue]];
	NSNumber *productID = [NSNumber numberWithInt:[[productJSON objectForKey:@"ProductId"] intValue]];
	NSString *productName = [productJSON objectForKey:@"Name"];
	NSString *productPrice = [productJSON objectForKey:@"Price"];
	NSString *productOffer = [productJSON objectForKey:@"OfferPromotion"];
	
	NSURL *productImageURL = [NSURL URLWithString:[productJSON objectForKey:@"ImagePath"]];
	NSURL *productOfferImageURL = [NSURL URLWithString:[productJSON objectForKey:@"OfferLabelImagePath"]];
	
	Product *product = [[[Product alloc] initWithProductBaseID:productBaseID andProductID:productID andProductName:productName
							   andProductPrice:productPrice andProductOffer:productOffer
							   andProductImage:nil andProductOfferImage:nil] autorelease];
									 
	[product setProductImageURL:productImageURL];
	[product setProductOfferImageURL:productOfferImageURL];
	if (fetchImages) {
		[self fetchImagesForProduct:product];
	}
	
	
	return product;
}

@end
