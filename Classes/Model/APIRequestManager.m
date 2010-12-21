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
#define SHELF_SIMULATED_PAGE_SIZE 15
#define MAX_RETRY_COUNT 3	//Maximum amount of times to API retry request before giving up
#define MIN_API_CALL_INTERVAL 750 //Minimum allowed time between subsequent API calls (in ms)
#define TIMEOUT_SECS 10	//Amount of secs before request will timeout

@interface APIRequestManager()

- (BOOL)apiRequest:(NSString *)initialRequestString returningApiResults:(NSDictionary **)apiResults returningError:(NSString **)error requestAttempt:(NSInteger)requestAttempt isLogin:(BOOL)isLogin;
- (void)createAnonymousSessionKey;
- (BOOL)login:(NSString *)email withPassword:(NSString *)password;
- (NSString *)urlEncodeValue:(NSString *)requestString;
- (Product *)createProductFromJSON:(NSDictionary *)productJSON fetchImages:(BOOL)fetchImages;

@property (assign) double lastUpdateRequestTime;
@property (assign) NSRecursiveLock *generatingSessionKeyLock;
@property (assign) NSRecursiveLock *apiRequestLock;

@end

@implementation APIRequestManager

@synthesize sessionKey;
@synthesize offlineMode;
@synthesize loggedIn;
@synthesize customerName;
@synthesize userEmail;
@synthesize userPassword;
@synthesize lastUpdateRequestTime;
@synthesize generatingSessionKeyLock;
@synthesize apiRequestLock;

- (id)init {
	if (self = [super init]) {
		generatingSessionKeyLock = [[NSRecursiveLock alloc] init];
		apiRequestLock = [[NSRecursiveLock alloc] init];
		departments = [[NSMutableDictionary alloc] init];
		aisles = [[NSMutableDictionary alloc] init];
		shelves = [[NSMutableDictionary alloc] init];
		shelfProductCache = [[NSMutableArray alloc] init];
		[self setLastUpdateRequestTime:[[NSDate date] timeIntervalSince1970]];
		[self setLoggedIn:NO];
	}
	
	return self;
}

- (BOOL)loginToStore:(NSString *)email withPassword:(NSString *)password {
	[self setUserEmail:email];
	[self setUserPassword:password];
	[self setLoggedIn:[self login:email withPassword:password]];
	return [self loggedIn];
}

- (void)logoutOfStore {
	/* go back to using an anonymous session key */
	[self createAnonymousSessionKey];
	[self setLoggedIn:NO];
}

- (void)createAnonymousSessionKey {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (![[DataManager getInstance] phoneIsOnline]) {
		[LogManager log:@"Phone is either offline or offline mode has been set. Refusing to create anonymous key" withLevel:LOG_INFO fromClass:[[self class] description]];
	} else {
		BOOL loginFailed = YES;
		if ([self login:@"" withPassword:@""]) {
			[LogManager log:[NSString stringWithFormat:@"Created anonymous login with session key: %@", [self sessionKey]] withLevel:LOG_INFO fromClass:[[self class] description]];
			loginFailed = NO;
		}
		if (loginFailed) {
			[LogManager log:[NSString stringWithFormat:@"Failed to create anonymous login"] withLevel:LOG_ERROR fromClass:[[self class] description]];
			
			UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Failed to connect to Tesco.com. Retry or switch to offline mode?" delegate:self cancelButtonTitle:@"Switch Mode" otherButtonTitles:@"Retry", nil];
			[loginAlert show];
			[loginAlert release];
		}
	}

	[pool release];
}

- (NSDictionary *)getOnlineBasket {
	NSMutableDictionary *onlineBasket = [[[NSMutableDictionary alloc] init] autorelease];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTBASKET&FAST=y", REST_SERVICE_URL];
	
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO];
	
	if (apiRequestOK == YES) {
		for (NSDictionary *product in [apiResults objectForKey:@"BasketLines"]) {
			NSString *productID = [product objectForKey:@"ProductId"];
			NSString *quantity = [product objectForKey:@"BasketLineQuantity"];
			[onlineBasket setObject:quantity forKey:productID];
		}
	}
	
	return onlineBasket;
}

- (Product *)createProductFromProductBaseID:(NSString *)productBaseID fetchImages:(BOOL)fetchImages {
    NSString *requestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@", REST_SERVICE_URL, productBaseID];
    NSDictionary *apiResults;
    NSString *error;
    Product *product;
    if ([self apiRequest:requestString returningApiResults: &apiResults returningError:&error requestAttempt:1 isLogin:NO] == YES) {
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
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTPRODUCTCATEGORIES", REST_SERVICE_URL];
	NSString *error;
	
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO] == YES) {
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
		NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTPRODUCTSBYCATEGORY&category=%@", REST_SERVICE_URL, [shelves objectForKey:shelf]];
		NSString *error;
		
		if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO] == YES) {
			for (NSDictionary *productInfo in [apiResults objectForKey:@"Products"]) {
				[shelfProductCache addObject:[self createProductFromJSON:productInfo  fetchImages:NO]];
			}
		}
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
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTBASKET&FAST=Y", REST_SERVICE_URL];
	
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO] == YES) {
		[basketDetails setObject:[apiResults objectForKey:@"BasketGuidePrice"] forKey:@"BasketPrice"];
		[basketDetails setObject:[apiResults objectForKey:@"BasketGuideMultiBuySavings"] forKey:@"BasketSavings"];
		[basketDetails setObject:[apiResults objectForKey:@"BasketTotalClubcardPoints"] forKey:@"BasketPoints"];
		[basketDetails setObject:[apiResults objectForKey:@"BasketQuantity"] forKey:@"BasketQuantity"];
	}
	
	return basketDetails;
}

- (BOOL)updateBasketQuantity:(NSString *)productID byQuantity:(NSNumber *)quantity {
	BOOL basketAlteredOK = NO;
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&productid=%@&changequantity=%@", REST_SERVICE_URL, productID, quantity];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO];
	
	if (apiRequestOK == TRUE) {
		basketAlteredOK = YES;
	}
	
	return basketAlteredOK;
}

/*
 * Gets a list of available delivery slots and their price
 */
- (NSDictionary *)getDeliveryDates {
	NSMutableDictionary *deliveryDates = [[[NSMutableDictionary alloc] init] autorelease];
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LISTDELIVERYSLOTS", REST_SERVICE_URL];
		
	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO] == YES) {
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
				NSMutableArray *deliverySlotsForDate = [[[NSMutableArray alloc] init] autorelease];
				[deliverySlotsForDate addObject:deliverySlot];
				
				/* add this delivery date (and corresponding time/slot array) to the delivery dates */
				[deliveryDates setObject:deliverySlotsForDate forKey:deliverySlotDate];
			} else {
				/* this delivery date is already in the list so just add this delivery time to its time/slots array */
				[[deliveryDates objectForKey:deliverySlotDate] addObject:deliverySlot];
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
	NSString *requestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&page=%d", REST_SERVICE_URL, searchTerm, page];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:NO];
	
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
	NSString *requestString = [NSString stringWithFormat:@"%@?command=CHOOSEDELIVERYSLOT&deliveryslotid=%@", REST_SERVICE_URL, deliverySlotID];

	if ([self apiRequest:requestString returningApiResults:&apiResults returningError:error requestAttempt:1 isLogin:NO] == YES) {
		requestString = [NSString stringWithFormat:@"%@?command=READYFORCHECKOUT", REST_SERVICE_URL];
		return [self apiRequest:requestString returningApiResults:&apiResults returningError:error requestAttempt:1 isLogin:NO];
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
#pragma mark Button responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        /* switch to offline mode */
        [[DataManager getInstance] setOfflineMode:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SwitchToOffline" object:self userInfo:nil];
    } else {
        /* retry the login attempt */
        [NSThread detachNewThreadSelector:@selector(createAnonymousSessionKey) toTarget:self withObject:nil];
    }
}

#pragma mark -
#pragma mark private functions

- (BOOL)apiRequest:(NSString *)initialRequestString returningApiResults:(NSDictionary **)apiResults returningError:(NSString **)error requestAttempt:(NSInteger)requestAttempt isLogin:(BOOL)isLogin {
	/* If this is not a login request block until all login requests finish first! */
	[apiRequestLock lock];
	
	if (!isLogin) {
		[generatingSessionKeyLock lock];
		[generatingSessionKeyLock unlock];
	}
	
	/* If we have no session key try and generate new Anonymous key */
	if ([[self sessionKey] length] == 0 && !isLogin) {
		[LogManager log:@"API request without key; checking online connectivity" withLevel:LOG_INFO fromClass:[[self class] description]];
		if ([[DataManager getInstance] phoneIsOnline]) {
			[LogManager log:@"Phone is online; generating anonymous key" withLevel:LOG_INFO fromClass:[[self class] description]];
			[self createAnonymousSessionKey];
		}else {
			[LogManager log: [NSString stringWithFormat:@"Phone is offline; cancelling request %@", initialRequestString] withLevel:LOG_INFO fromClass:[[self class] description]];
			return NO;
		}
	}
	
	double timeSinceLastRequest = [[NSDate date] timeIntervalSince1970] - [self lastUpdateRequestTime];
	
	if (timeSinceLastRequest < MIN_API_CALL_INTERVAL) {
		[NSThread sleepForTimeInterval:((MIN_API_CALL_INTERVAL - timeSinceLastRequest) / 1000.0f)];
	}
	
	[self setLastUpdateRequestTime:[[NSDate date] timeIntervalSince1970]];
	
	[apiRequestLock unlock];

	BOOL apiReqOK = YES;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setTimeoutInterval: TIMEOUT_SECS];
	
	/* add the session key (if necessary) here so that we can change it if it's expired and needs recreating */
	NSMutableString *requestString = [NSMutableString stringWithString:initialRequestString];
	
	if (isLogin == NO) {
		[requestString appendString:[NSString stringWithFormat:@"&sessionkey=%@", sessionKey]];
	}
	 
	[request setURL:[NSURL URLWithString:[self urlEncodeValue:requestString]]];
	[request setHTTPMethod:@"GET"];
	
	[LogManager log:[NSString stringWithFormat:@"Sending request: '%@'", requestString] withLevel:LOG_INFO fromClass:[[self class] description]];
	
	/* send the GET request */
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	
	if (data == nil) {
		[LogManager log:@"Request fetched no/invalid results" withLevel:LOG_INFO fromClass:[[self class] description]];
		if (requestAttempt < MAX_RETRY_COUNT) {
			[LogManager log:[NSString stringWithFormat:@"Retrying request (attempt %d of %d)",requestAttempt, MAX_RETRY_COUNT] withLevel:LOG_INFO fromClass:[[self class] description]];
			return [self apiRequest:initialRequestString returningApiResults:apiResults returningError:error requestAttempt:++requestAttempt isLogin:isLogin];
		}
		
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
			
			if (requestAttempt < MAX_RETRY_COUNT) {
				[LogManager log:[NSString stringWithFormat:@"Retrying request (attempt %d of %d)",requestAttempt, MAX_RETRY_COUNT] withLevel:LOG_INFO fromClass:[[self class] description]];
				return [self apiRequest:initialRequestString returningApiResults:apiResults returningError:error requestAttempt:++requestAttempt isLogin:isLogin];
			}
			
			apiReqOK = NO;
		} else {
			NSNumber *statusCode = [jsonResults objectForKey:@"StatusCode"];
			
			if ([statusCode intValue] != 0) {
				/* something's gone wrong with the API so we need to find out what has happened */
				if ([statusCode intValue] == 120) {
					[LogManager log:@"API call failed due to out of date/invalid session key" withLevel:LOG_ERROR fromClass:[[self class] description]];
					
					/* chances are, the user has left the app for ages and the session key is now invalid so we need a new one */
					if (loggedIn == YES) {
						/* user was logged in so use their original credentials to try and log them back in */
						[LogManager log:@"User was logged in - logging back in" withLevel:LOG_ERROR fromClass:[[self class] description]];
						[self login:[self userEmail] withPassword:[self userPassword]];
					} else {
						/* user was not logged in so create an anonymous session key */
						[LogManager log:@"User was not logged in - recreating anonymous session key" withLevel:LOG_ERROR fromClass:[[self class] description]];
						[self createAnonymousSessionKey];
					}
					
					/* we need to resend the current request as it failed the last time - we should now have a valid session key */
					return [self apiRequest:initialRequestString returningApiResults:apiResults returningError:error requestAttempt:++requestAttempt isLogin:isLogin];
				} else {
					[LogManager log:[NSString stringWithFormat:@"API error: '%@'", jsonResults] withLevel:LOG_ERROR fromClass:[[self class] description]];
					*error = [[[NSString alloc] initWithFormat:@"%@", [jsonResults objectForKey:@"StatusInfo"]] autorelease];
				}
				
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
	[generatingSessionKeyLock lock];
	
	BOOL loggedInSuccessfully = NO;
	NSDictionary *apiResults;
	NSString *error;
	NSString *requestString = [NSString stringWithFormat:@"%@?command=LOGIN&email=%@&password=%@&developerkey=%@&applicationkey=%@", REST_SERVICE_URL, email, password, DEVELOPER_KEY, APPLICATION_KEY];
	BOOL apiRequestOK = [self apiRequest:requestString returningApiResults:&apiResults returningError:&error requestAttempt:1 isLogin:YES];
	
	if (apiRequestOK == YES) {
		[self setSessionKey: [apiResults objectForKey:@"SessionKey"]];
		[self setCustomerName:[apiResults objectForKey:@"CustomerName"]];
		loggedInSuccessfully = YES;
	}
	
	[generatingSessionKeyLock unlock];
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
	NSString *productOfferValidity = [productJSON objectForKey:@"OfferValidity"];
	
	NSURL *productImageURL = [NSURL URLWithString:[productJSON objectForKey:@"ImagePath"]];
	NSURL *productOfferImageURL = [NSURL URLWithString:[productJSON objectForKey:@"OfferLabelImagePath"]];
	
	Product *product = [[[Product alloc] initWithProductBaseID:productBaseID andProductID:productID andProductName:productName
											   andProductPrice:productPrice andProductOffer:productOffer 
									   andProductOfferValidity:productOfferValidity andProductImage:nil 
										  andProductOfferImage:nil andProductFetchedOffline:NO] autorelease];
									 
	[product setProductImageURL:productImageURL];
	[product setProductOfferImageURL:productOfferImageURL];
	if (fetchImages) {
		[self fetchImagesForProduct:product];
	}
	
	[product setMaxAmount:[[productJSON objectForKey:@"MaximumPurchaseQuantity"] intValue]];
	return product;
}

@end
