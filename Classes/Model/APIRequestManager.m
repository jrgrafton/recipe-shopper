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
#import "DataManager.h"

#define DEVELOPER_KEY @"xIvRaeGkY6OavPL1XtX9"
#define APPLICATION_KEY @"CA1A9E0437CBE399E890"
#define REST_SERVICE_URL @"https://secure.techfortesco.com/groceryapi_b1/restservice.aspx"
#define MAX_ASYNC_REQUESTS 15

@interface APIRequestManager()

- (BOOL)apiRequest:(NSString *)requestString returningApiResults:(NSDictionary **)apiResults returningError:(NSString **)error;
- (BOOL)emptyBasket;
- (BOOL)login:(NSString *)email withPassword:(NSString *)password;
- (void)processRequestQueue:(NSArray *)requestQueue;
- (void)processSingleRequest:(NSString *)requestString;
- (NSString *)urlEncodeValue:(NSString *)requestString;
- (Product *)createProductFromJSON:(NSDictionary *)productJSON;

@end

@implementation APIRequestManager

@synthesize offlineMode;
@synthesize loggedIn;
@synthesize customerName;

- (id)init {
	if (self = [super init]) {
		currentAsyncRequestCount = 0;
		requestResults = [[NSMutableDictionary alloc] init];
		departments = [[NSMutableDictionary alloc] init];
		aisles = [[NSMutableDictionary alloc] init];
		shelves = [[NSMutableDictionary alloc] init];
		
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

/*
 * Takes a list of product Base IDs, finds them in the online store and adds them to an array
 */
- (NSArray *)createProductsFromProductBaseIDs:(NSDictionary *)productBaseIDList {
	NSMutableArray *products = [NSMutableArray array];
	NSMutableArray *requestQueue = [[NSMutableArray alloc] init];
	
	for (NSString *productBaseID in [productBaseIDList allKeys]) {
		NSString *requestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&sessionkey=%@", REST_SERVICE_URL, productBaseID, sessionKey];
		[requestQueue addObject:requestString];
	}
	
	/* spawn a thread to process the request queue */
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector: @selector(processRequestQueue:) toTarget:self withObject:requestQueue];
	[pool release];
	
	/* now spin until all requests have been serviced */
	while ([[requestResults allKeys] count] < [requestQueue count]) {
		[NSThread sleepForTimeInterval:0.2];
	}
	
	/* all requests have returned, now iterate through, populating products array */
	for (NSString *result in requestResults) {
		id apiResult = [requestResults objectForKey:result];
		
		if (apiResult == [NSNull null]) {
			/* API request for search must have failed */
			/* CREATE A DUMMY PRODUCT FOR THIS ONE */
		} else {
			NSString *totalProducts = [apiResult objectForKey:@"TotalProductCount"];
			
			if ([totalProducts intValue] == 0) {
				/* couldn't find the product ID in the online store, so just create a dummy product */
				//[products addObject:[self createDummyProduct:[apiResult objectForKey:@"StatusInfo"]]];
			} else {
				/* assume its a single product, so we want the first (and only) one */
				[products addObject:[self createProductFromJSON:[[apiResult objectForKey:@"Products"] objectAtIndex:0]]];
			}
		}
	}
	
	/* finally ensure that both requestQueue and requestResults are emptied */
	[requestQueue removeAllObjects];
	[requestResults removeAllObjects];
	
	[requestQueue release];
	
	return products;
}

- (NSArray *)getDepartments {
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

- (NSArray *)getProductsForShelf:(NSString *)shelf {
	NSMutableArray *products = [NSMutableArray array];
	NSDictionary *apiResults;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTPRODUCTSBYCATEGORY&category=%@&sessionkey=%@", REST_SERVICE_URL, [shelves objectForKey:shelf], sessionKey];
	NSString *error;
	
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error] == YES) {
		for (NSDictionary *productInfo in [apiResults objectForKey:@"Products"]) {
			[products addObject:[self createProductFromJSON:productInfo]];
		}
	}
	
	return products;
}

/*
 * Adds all of the products that are currently in the internal basket to 
 * the online basket by adding each "CHANGEBASKET" request to a queue and kicking
 * off each request in a separate thread.
 * If any requests fail for any reason, we fail the whole process
 */
- (BOOL)addProductBasketToBasket {
	/* assume success unless we hear otherwise */
	BOOL productBasketAddedOK = YES;
	NSMutableArray *requestQueue = [[NSMutableArray alloc] init];
	
	/* first, empty the store basket by removing all products */
	[DataManager setOverlayLabelText:@"Emptying online basket ..."];
	
	if ([self emptyBasket] == YES) {
		/* now add all of the products in our local basket to the store basket */
		NSDictionary *productBasket = [DataManager getProductBasket];
		NSEnumerator *productsEnumerator = [productBasket keyEnumerator];
		Product *product;
		
		[DataManager setOverlayLabelText:@"Adding products to online basket ..."];
		
		while ((product = [productsEnumerator nextObject])) {
			NSString *requestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&productid=%@&changequantity=%@&sessionkey=%@", REST_SERVICE_URL, [product productID], [productBasket objectForKey:product], sessionKey];
			[requestQueue addObject:requestString];
		}
		
		/* spawn a thread to process the request queue */
		[NSThread detachNewThreadSelector:@selector(processRequestQueue:) toTarget:self withObject:requestQueue];
		
		/* now spin until all requests have been serviced */
		while ([[requestResults allKeys] count] < [requestQueue count]) {
			[NSThread sleepForTimeInterval:0.2];
		}
		
		/* all requests have returned, now iterate through checking to see if any of them failed */
		for (NSString *result in requestResults) {
			if ([requestResults objectForKey:result] == [NSNull null]) {
				/* when one fails, we fail the whole thing */
				productBasketAddedOK = NO;
			}
		}
		
		/* finally ensure that both requestQueue and restDictionary are emptied */
		[requestQueue removeAllObjects];
		[requestResults removeAllObjects];
	} else {
		/* API request failed */
		productBasketAddedOK = NO;
	}
	
	[requestQueue release];
	
	return productBasketAddedOK;
}

- (NSDictionary *)getBasketDetails {
	NSMutableDictionary *basketDetails = [NSMutableDictionary dictionary];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTBASKET&sessionkey=%@", REST_SERVICE_URL, sessionKey];
	
	[DataManager setOverlayLabelText:@"Updating online basket ..."];
	
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error] == YES) {
		[basketDetails setObject:[apiResults objectForKey:@"BasketGuidePrice"] forKey:@"BasketPrice"];
		[basketDetails setObject:[apiResults objectForKey:@"BasketGuideMultiBuySavings"] forKey:@"BasketSavings"];
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
		[dateFormatter setDateFormat:@"yyyy-MM-dd"];
		
		NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
		[timeFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
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
			[products addObject:[self createProductFromJSON:productInfo]];
		}
	}
	
	return products;
}

- (void)chooseDeliverySlot:(NSString *)deliverySlotID {
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=CHOOSEDELIVERYSLOT&deliveryslotid=%@&sessionkey=%@", REST_SERVICE_URL, deliverySlotID, sessionKey];
	[self apiRequest:requestString returningApiResults:&apiResults returningError:&error];
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

- (BOOL)emptyBasket {
	BOOL basketEmptiedOK = YES;
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTBASKETSUMMARY&sessionkey=%@", REST_SERVICE_URL, sessionKey];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error];
	NSMutableArray *requestQueue = [[NSMutableArray alloc] init];
	
	if (apiRequestOK == TRUE) {
		for (NSDictionary *product in [apiResults objectForKey:@"BasketLines"]) {
			NSString *productID = [product objectForKey:@"ProductId"];
			NSInteger quantity = 0 - [[product objectForKey:@"BasketLineQuantity"] intValue];
			NSString *requestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&productid=%@&changequantity=%d&sessionkey=%@", REST_SERVICE_URL, productID, quantity, sessionKey];
			[requestQueue addObject:requestString];
		}
		
		/* spawn a thread to process the request queue */
		[NSThread detachNewThreadSelector: @selector(processRequestQueue:) toTarget:self withObject:requestQueue];
		
		/* now spin until all requests have been serviced */
		while ([[requestResults allKeys] count] < [requestQueue count]) {
			[NSThread sleepForTimeInterval:0.2];
		}
		
		/* finally ensure that both requestQueue and requestResults are emptied */
		[requestQueue removeAllObjects];
		[requestResults removeAllObjects];
	} else {
		basketEmptiedOK = NO;
	}
	
	[requestQueue release];
	
	return basketEmptiedOK;
}

/*
 * Sends each API request in the queue to its own thread to be processed
 */
- (void)processRequestQueue:(NSArray *)requestQueue {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	for (NSInteger index = 0; index < [requestQueue count]; index++) {
		NSString *request = [requestQueue objectAtIndex:index];
		
		if (currentAsyncRequestCount < MAX_ASYNC_REQUESTS) {
			currentAsyncRequestCount++;
			[NSThread detachNewThreadSelector:@selector(processSingleRequest:) toTarget:self withObject:request];
		} else {
			//Better done with MUTEX locks if we had the time
			[NSThread sleepForTimeInterval:0.5];
			index--;
		}
	}
	
	[pool release];
}

/*
 * Processes a single API request at a time, setting the value of the 
 * result in an array for checking later
 */
- (void)processSingleRequest:(NSString *)requestString {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* retain request string since we are operating in new thread */
	[requestString retain];
	
	NSDictionary *apiResults;
	NSString *error;
	
	if ([self apiRequest:requestString returningApiResults: &apiResults returningError:&error] == YES) {
		[requestResults setValue:apiResults forKey:requestString];
	} else {
		[requestResults setValue:[NSNull null] forKey:requestString];
	}
	
	currentAsyncRequestCount--;
	
	[requestString release];
	[pool release];
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
- (Product *)createProductFromJSON:(NSDictionary *)productJSON {
	NSNumber *productBaseID = [NSNumber numberWithInt:[[productJSON objectForKey:@"BaseProductId"] intValue]];
	NSNumber *productID = [NSNumber numberWithInt:[[productJSON objectForKey:@"ProductId"] intValue]];
	NSString *productName = [productJSON objectForKey:@"Name"];
	NSString *productPrice = [productJSON objectForKey:@"Price"];
	NSString *productOffer = [productJSON objectForKey:@"OfferPromotion"];
	
	UIImage *productImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[productJSON objectForKey:@"ImagePath"]]]] autorelease];
	
	if (productImage == nil) {
		productImage = [UIImage imageNamed:@"icon_product_default.jpg"];
	}
	
	NSString *productOfferImageUrl = [productJSON objectForKey:@"OfferLabelImagePath"];
	UIImage *productOfferImage;
	
	if ([productOfferImageUrl length] != 0) {
		productOfferImage = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:productOfferImageUrl]]] autorelease];
	} else {
		productOfferImage = nil;
	}
	
	return [[[Product alloc] initWithProductBaseID:productBaseID andProductID:productID andProductName:productName
							   andProductPrice:productPrice andProductOffer:productOffer
							   andProductImage:productImage andProductOfferImage:productOfferImage] autorelease];
}

@end
