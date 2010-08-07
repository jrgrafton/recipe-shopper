//
//  RequestManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "APIRequestManager.h"
#import "JSON.h"
#import "LogManager.h"
#import "DataManager.h"
#import "DBProduct.h"
#import "UIImage-Extended.h"

#define DEVELOPER_KEY @"xIvRaeGkY6OavPL1XtX9"
#define APPLICATION_KEY @"CA1A9E0437CBE399E890"
#define REST_SERVICE_URL @"https://secure.techfortesco.com/groceryapi_b1/restservice.aspx"

#define PRODUCT_SEARCH_REQUEST_STRING(searchTerm,sessionKey,pageNumber) @"http://www.techfortesco.com/groceryapi_b1/restservice.aspx?command=PRODUCTSEARCH&searchtext=" #searchTerm "&page=" #pageNumber "&sessionkey=" #sessionKey ""

#define MAX_ASYNC_REQUESTS 15

@interface APIRequestManager ()
//Private class functions
-(void)processJSONRequestQueue;
-(void)processSingleJSONRequest:(NSString*) requestString;
-(NSData *)httpGetRequest:(NSString*)requestUrl;
-(NSString *)urlEncodeValue:(NSString *)string;
-(id)getJSONForRequest:(NSString*)requestString;
-(DBProduct*)buildProductFromInfo:(NSDictionary*)productInfo;
-(UIImage*)getImageForProduct:(NSString*)iconUrl;
-(id)getSessionKeyForEmail:(NSString*)email usingPassword:(NSString*)password;
@end

@implementation APIRequestManager

- (id)init {
	if (self = [super init]) {
		//Initialisation code
		currentAsyncRequestCount = 0;
		JSONRequestQueue = [[NSMutableArray alloc] init];
		JSONRequestResults = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark -
#pragma mark public functions

- (NSDate*)verifyOrder:(NSString**)error {
	NSString *verifyOrderString = [NSString stringWithFormat:@"%@?command=READYFORCHECKOUT&SESSIONKEY=%@",REST_SERVICE_URL,authenticatedSessionKey];
	NSDictionary *verifyOrderDetails = [self getJSONForRequest:verifyOrderString];
	
	if (verifyOrderDetails == nil) {
		[LogManager log:@"Error verifying order (NO JSON RETURNED)" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
		*error = [[[NSString alloc] initWithFormat:@"Tesco API endpoint unreachable"] autorelease];
		return nil;
	}else{
		NSNumber *statusCode = [verifyOrderDetails objectForKey:@"StatusCode"];
		if ([statusCode intValue] != 0) {
		
			NSString* msg = [NSString stringWithFormat:@"Error verifying order (%@)",verifyOrderDetails];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
		
			*error = [[[NSString alloc] initWithFormat:@"%@",[verifyOrderDetails objectForKey:@"StatusInfo"]]autorelease];
			return nil;
		}else{
			NSLocale *          enUSPOSIXLocale;
			enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
			
			NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
			[df setLocale:enUSPOSIXLocale];
			[df setDateFormat:@"yyyy-MM-dd HH:mm"];
			
			return [df dateFromString:[verifyOrderDetails objectForKey:@"DeliverySlotReservationExpires"]];
		}
	}
}

- (BOOL)chooseDeliverySlot:(APIDeliverySlot*)deliverySlot returningError:(NSString**)error {
	NSString *chooseDeliverySlotString = [NSString stringWithFormat:@"%@?command=CHOOSEDELIVERYSLOT&DELIVERYSLOTID=%@&SESSIONKEY=%@",REST_SERVICE_URL,[deliverySlot deliverySlotID],authenticatedSessionKey];
	NSDictionary *chooseDeliverySlotResponse = [self getJSONForRequest:chooseDeliverySlotString];
	
	if (chooseDeliverySlotResponse == nil) {
		[LogManager log:@"Error reserving delivery slot (NO JSON RETURNED)" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];	
		*error = [[[NSString alloc] initWithFormat:@"Tesco API endpoint unreachable"] autorelease];
		return FALSE;
	}else{
		NSNumber *statusCode = [chooseDeliverySlotResponse objectForKey:@"StatusCode"];
		if ([statusCode intValue] != 0) {
			NSString* msg = [NSString stringWithFormat:@"Error reserving delivery slot (%@)",chooseDeliverySlotResponse];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
			*error = [[[NSString alloc] initWithFormat:@"%@",[chooseDeliverySlotResponse objectForKey:@"StatusInfo"]]autorelease];
			return FALSE;
		}else{
			return TRUE;
		}
	}
}

- (NSArray*)fetchAvailableDeliverySlots {
	NSMutableArray *availableDeliverySlots = [NSMutableArray array];
	
	NSString *fetchDeliverySlotsRequestString = [NSString stringWithFormat:@"%@?command=LISTDELIVERYSLOTS&SESSIONKEY=%@",REST_SERVICE_URL,authenticatedSessionKey];
	NSDictionary *deliveryDetails = [self getJSONForRequest:fetchDeliverySlotsRequestString];
	
	if (deliveryDetails == nil) {
		[LogManager log:@"Error fetching delivery slots (NO JSON RETURNED)" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
		return [NSArray array];
	}else {
		NSNumber *statusCode = [deliveryDetails objectForKey:@"StatusCode"];
		if ([statusCode intValue] != 0) {
	
			NSString* msg = [NSString stringWithFormat:@"Error fetching delivery slots (%@)",deliveryDetails];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	
			return [NSArray array];
		}else{
			//Request seems to have returned successfully...
			NSLocale *          enUSPOSIXLocale;
			enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
			
			NSArray *JSONDeliveryDates = [deliveryDetails objectForKey:@"DeliverySlots"];
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setLocale:enUSPOSIXLocale];
			[df setDateFormat:@"yyyy-MM-dd HH:mm"];
			
			NSInteger index = 0;
			for (NSDictionary *JSONDeliveryDate in JSONDeliveryDates) {
				NSString *deliverySlotID = [NSString stringWithFormat:@"%@",[JSONDeliveryDate objectForKey:@"DeliverySlotId"]];
				NSString *deliverySlotBranchNumber = [NSString stringWithFormat:@"%@",[JSONDeliveryDate objectForKey:@"BranchNumber"]];
				NSDate *deliverySlotStartDate = [df dateFromString:[JSONDeliveryDate objectForKey:@"SlotDateTimeStart"]];
				NSDate *deliverySlotEndDate = [df dateFromString:[JSONDeliveryDate objectForKey:@"SlotDateTimeEnd"]];
				NSString *deliverySlotCost = [JSONDeliveryDate objectForKey:@"ServiceCharge"];
				
				APIDeliverySlot * apiDeliverySlot = [[[APIDeliverySlot alloc] initWithDeliverySlotID:deliverySlotID 
																		andDeliverySlotBranchNumber:deliverySlotBranchNumber 
																		andDeliverySlotStartDate:deliverySlotStartDate 
																	    andDeliverySlotEndDate:deliverySlotEndDate 
																		andDeliverySlotCost:deliverySlotCost] autorelease];
				
				[availableDeliverySlots addObject:apiDeliverySlot];
				index++;
			}
			[df release];
		}
	}
	
	//Ensure returned array is sorted
	[availableDeliverySlots sortUsingSelector:@selector(compareByDeliverySlotStart:)];	
	return availableDeliverySlots;
}

- (BOOL)addProductBasketToStoreBasket {
	//First we have to verify the existing online basket is empty
	[self clearProductBasket];
	
	[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewLoadingText:) withObject:@"Adding products to Tesco.com basket" waitUntilDone:TRUE];
	NSArray *productBasket = [DataManager getProductBasket];
	
	for (DBProduct *product in productBasket) {
		NSInteger productCount = [DataManager getCountForProduct:product];
		NSNumber *productID = [product productID];
		NSString *addToBasketRequestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&PRODUCTID=%@&CHANGEQUANTITY=%d&SESSIONKEY=%@",REST_SERVICE_URL,productID,productCount,authenticatedSessionKey];
		[JSONRequestQueue addObject:addToBasketRequestString];
	}
	
	//Spawn a thread to process the request queue
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector: @selector(processJSONRequestQueue) toTarget:self withObject:nil];
	[pool release];
	
	//Now spin until all requests have been serviced
	while ([[JSONRequestResults allKeys] count] < [JSONRequestQueue count]) {
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Adding product %d of %d",[[JSONRequestResults allKeys] count] + 1,[JSONRequestQueue count]] waitUntilDone:TRUE];
		[NSThread sleepForTimeInterval:0.2];
	}
	
	//All requests have returned, now interate through populating filteredProducts array
	for (NSString *key in JSONRequestResults) {
		id result = [JSONRequestResults valueForKey:key];
		if (result == [NSNull null]) { //Request could have failed
			
			NSString* msg = [NSString stringWithFormat:@"Error during add product to online basket request [%@] (NO JSON RETURNED)",key];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
			
			//If even one add to online basket fails we fail the whole process
			return FALSE;
		}else {
			NSNumber *statusCode = [result objectForKey:@"StatusCode"];
			if ([statusCode intValue] != 0) {
				
				NSString* msg = [NSString stringWithFormat:@"Error during add product to online basket request [%@]",result];
				[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
				
				return FALSE;
			}else {
				
				NSString* msg = [NSString stringWithFormat:@"Successfully addded product to basket [%@]",result];
				[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];
				
			}
		}
	}
	
	//Finally ensure that both requestQueue and restDictionary are emptied
	[JSONRequestQueue removeAllObjects];
	[JSONRequestResults removeAllObjects];
	
	return TRUE;
}
- (void)clearProductBasket {
	[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewLoadingText:) withObject:@"Emptying Tesco.com basket" waitUntilDone:TRUE];
	NSArray* currentBasket = [self fetchBasketSummary];
	
	for (NSDictionary* item in currentBasket) {
		NSInteger basketLineQuantity = 0 - [[item valueForKey:@"BasketLineQuantity"] intValue];
		NSInteger productID = [[item valueForKey:@"ProductId"] intValue];
		NSString *removeFromBasketRequestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&PRODUCTID=%d&CHANGEQUANTITY=%d&SESSIONKEY=%@",REST_SERVICE_URL,productID,basketLineQuantity,authenticatedSessionKey];
		[JSONRequestQueue addObject:removeFromBasketRequestString];
	}
	
	//Spawn a thread to process the request queue
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector: @selector(processJSONRequestQueue) toTarget:self withObject:nil];
	[pool release];
	
	//Now spin until all requests have been serviced
	while ([[JSONRequestResults allKeys] count] < [JSONRequestQueue count]) {
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Removing product %d of %d",[[JSONRequestResults allKeys] count] + 1,[JSONRequestQueue count]] waitUntilDone:TRUE];
		[NSThread sleepForTimeInterval:0.2];
	}
	
	//Finally ensure that both requestQueue and restDictionary are emptied
	[JSONRequestQueue removeAllObjects];
	[JSONRequestResults removeAllObjects];
}

- (NSArray*)fetchBasketSummary {
	NSString *fetchBasketSummaryRequestString = [NSString stringWithFormat:@"%@?command=LISTBASKETSUMMARY&SESSIONKEY=%@",REST_SERVICE_URL,authenticatedSessionKey];
	NSDictionary *basketDetails = [self getJSONForRequest:fetchBasketSummaryRequestString];
	
	if (basketDetails == nil) {
	
		[LogManager log:@"Error fetching basket content slots (NO JSON RETURNED)" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	
		return [NSArray array];
	}else {
		NSNumber *statusCode = [basketDetails objectForKey:@"StatusCode"];
		if ([statusCode intValue] != 0) {
	
			NSString* msg = [NSString stringWithFormat:@"Error fetching basket content (%@)",basketDetails];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	
			return [NSArray array];
		}
	}
	
	return [basketDetails objectForKey:@"BasketLines"];
}

- (BOOL)loginToStore:(NSString*) email withPassword:(NSString*) password {
	if ([email length] == 0 || [password length] == 0) {
		return FALSE;
	}
	authenticatedSessionKey = [[self getSessionKeyForEmail:email usingPassword:password] retain];
	authenticatedTime = [NSDate date];
	
	return authenticatedSessionKey != nil;
}

- (NSArray*)fetchProductsMatchingSearchTerm: (NSString*)searchTerm onThisPage:(NSInteger) pageNumber andGiveMePageCount:(NSInteger*) pageCountHolder{
	NSMutableArray *products = [NSMutableArray array];
	
	NSString* sessionKey = [self getSessionKeyForEmail:@"" usingPassword:@""];
	
	if (sessionKey == nil) {
		return products;
	}
	
	//Now we have session key try doing search...
	NSString *productSearchRequestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&page=%d&sessionkey=%@",REST_SERVICE_URL,searchTerm,pageNumber,sessionKey];
	NSDictionary *productSearchResult = [self getJSONForRequest:productSearchRequestString];
	
	if (pageCountHolder != nil){
		*pageCountHolder = [[productSearchResult objectForKey:@"TotalPageCount"] intValue];
	}
	
	NSArray *JSONProducts = [productSearchResult objectForKey:@"Products"];
	
	NSInteger index = 1;
	NSInteger totalSize = [JSONProducts count];
	for (NSDictionary *JSONProduct in JSONProducts) {
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Fetching info for product %d of %d",index,totalSize] waitUntilDone:FALSE];
		[products addObject:[self buildProductFromInfo:JSONProduct]];
		index++;
	}
	
	return products;
}


- (NSArray*)getFilteredProductList:(NSArray*)productIdList{
	NSString* sessionKey = [self getSessionKeyForEmail:@"" usingPassword:@""];
	
	//If API is down just return original list
	if (sessionKey == nil) {
		return productIdList;
	}
	
	//Now we have session key try doing search...
	NSMutableArray *filteredProducts = [NSMutableArray array];
	
	for (NSNumber *productBaseId in productIdList) {
		//Add all our requests to queue
		NSString *productSearchRequestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&sessionkey=%@",REST_SERVICE_URL,productBaseId,sessionKey];
		[JSONRequestQueue addObject:productSearchRequestString];
	}
	
	//Spawn a thread to process the request queue
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSThread detachNewThreadSelector: @selector(processJSONRequestQueue) toTarget:self withObject:nil];
	[pool release];
	
	//Now spin until all requests have been serviced
	while ([[JSONRequestResults allKeys] count] < [JSONRequestQueue count]) {
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Verifying product %d of %d",[[JSONRequestResults allKeys] count] + 1,[JSONRequestQueue count]] waitUntilDone:TRUE];
		
		//Would be better done with MUTEX locks if we had the time
		[NSThread sleepForTimeInterval:0.2];
	}
	
	//All requests have returned, now interate through populating filteredProducts array
	for (NSString *key in JSONRequestResults) {
		id result = [JSONRequestResults valueForKey:key];
		if (result != [NSNull null]) { //Request could have failed
			//Assume its a dict object if its not null
			NSArray *JSONProducts = [result objectForKey:@"Products"];
			if ([JSONProducts count] != 0) {
				//Have to rebuild product in case price, description etc has changed
				[filteredProducts addObject: [self buildProductFromInfo:[JSONProducts objectAtIndex:0]]];
			}
			
			else{
				NSString *msg = [NSString stringWithFormat:@"Product exists in database but not on website"];
				[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];
			}
			
		}
	}
	
	//Finally ensure that both requestQueue and restDictionary are emptied
	[JSONRequestQueue removeAllObjects];
	[JSONRequestResults removeAllObjects];
	
	return filteredProducts;
}

#pragma mark -
#pragma mark private functions


-(void)processJSONRequestQueue {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	for (NSInteger index = 0; index < [JSONRequestQueue count]; index++) {
		NSString *JSONRequest = [JSONRequestQueue objectAtIndex: index];
		if (currentAsyncRequestCount < MAX_ASYNC_REQUESTS){
			currentAsyncRequestCount++;
			[NSThread detachNewThreadSelector: @selector(processSingleJSONRequest:) toTarget:self withObject:JSONRequest];
		}else {
			//Better done with MUTEX locks if we had the time
			[NSThread sleepForTimeInterval:0.5];
			index--; //Reset index
		}
	}
	
	[pool release];
}

-(void)processSingleJSONRequest:(NSString*) requestString{
	//Need pool surrounding URL request since we are in thread
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//Retain request string since we are operating in new thread
	[requestString retain];
	
	//Perform actual request
	NSDictionary *result = [self getJSONForRequest:requestString];
	
	if (result == nil) {
		[JSONRequestResults setValue:[NSNull null] forKey:requestString];
	
		NSString* msg = [NSString stringWithFormat:@"Error processing request %@ (NO JSON RETURNED)",requestString];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	
	}else {
		[JSONRequestResults setValue:result forKey:requestString];
	}

	
	NSNumber *statusCode = [result objectForKey:@"StatusCode"];
	if ([statusCode intValue] != 0) {
	
		NSString* msg = [NSString stringWithFormat:@"Error processing request %@ (%@)",requestString,result];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	
	}
	currentAsyncRequestCount--;
	
	//Release request string
	[requestString release];
	
	//Release pool
	[pool release];
}

-(id)getJSONForRequest:(NSString*)requestString{
	NSData *data = [self httpGetRequest:requestString];	
	NSString *dataString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	if([dataString length] == 0){
		[LogManager log:@"Request fetched no/invalid results" withLevel:LOG_INFO fromClass:@"APIRequestManager"];
		return [NSArray array];
	}
	
	NSMutableString* jsonString = [NSMutableString stringWithFormat:@"%@", dataString];
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSError *error = nil;
	id results = [parser objectWithString:jsonString allowScalar:TRUE error:&error];
	
	if(error != nil){

		NSString *msg = [NSString stringWithFormat:@"error parsing JSON: '%@'.",[error localizedDescription]];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];

		results = [NSArray array];
	}
	
	//Always release alloc'd objects
	[parser release];
	
	return results;
}

-(NSString *) urlEncodeValue:(NSString*)requestString{
	CFStringRef urlString = CFURLCreateStringByAddingPercentEscapes(
																	NULL,
																	(CFStringRef)requestString,
																	NULL,
																	(CFStringRef)@"!*'\"();@+$,%#[]% ",
																	kCFStringEncodingUTF8 );
    return [(NSString *)urlString autorelease];
}

-(NSData*)httpGetRequest:(NSString*)requestUrl {
	//Ensure its fully URL encoded
	requestUrl = [self urlEncodeValue:requestUrl];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];  
	[request setURL:[NSURL URLWithString:requestUrl]];
	[request setHTTPMethod:@"GET"];

	NSString *msg = [NSString stringWithFormat:@"Sending request: '%@'.",requestUrl];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];

	return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

-(DBProduct*)buildProductFromInfo:(NSDictionary*)productInfo{
	NSNumber *productID = [NSNumber numberWithInt:[[productInfo objectForKey:@"ProductId"] intValue]];
	NSNumber *productBaseID = [NSNumber numberWithInt:[[productInfo objectForKey:@"BaseProductId"] intValue]];
	NSString *productName = [productInfo objectForKey:@"Name"];
	NSString *productPrice = [productInfo objectForKey:@"Price"];
	UIImage *productIcon = [self getImageForProduct:[productInfo objectForKey:@"ImagePath"]];
	NSDate *lastUpdated = [NSDate date];
	
	return [[[DBProduct alloc] initWithProductID:productID andProductBaseID: productBaseID andProductName:productName
								 andProductPrice:productPrice andProductIcon:productIcon
								  andLastUpdated:lastUpdated andUserAdded:YES] autorelease];
}

-(id)getSessionKeyForEmail:(NSString*)email usingPassword:(NSString*)password {
	NSString *loginRequestString = [NSString stringWithFormat:@"%@?command=LOGIN&email=%@&password=%@&developerkey=%@&applicationkey=%@",REST_SERVICE_URL,email,password,DEVELOPER_KEY,APPLICATION_KEY];
	
	//Perform anonymous login
	NSDictionary *loginDetails = [self getJSONForRequest:loginRequestString];
	NSString *sessionKey = @"";
	
	//Get Session key
	if (loginDetails != nil) {
		sessionKey = [loginDetails objectForKey:@"SessionKey"];
	}
	
	if ([sessionKey length] == 0){

		NSString* msg = [NSString stringWithFormat:@"Login failed for [%@]/[%@]",email,password];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];

		return nil;
	}else{

		NSString* msg = [NSString stringWithFormat:@"Login succeeded for [%@]/[%@] (%@)",email,password,sessionKey];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];

	}
	
	return sessionKey;
}

-(UIImage*) getImageForProduct:(NSString*)iconUrl{
	UIImage *image = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]] autorelease];
	UIImage *defaultImage = [UIImage imageNamed:@"icon_product_default.jpg"];
	
	if (image == nil){
		return defaultImage;
	}
	
	// to put the image in the small box, use this code
	//image = [image resizedImage:CGSizeMake(120,120) interpolationQuality:kCGInterpolationHigh andScale:2.0];
	//UIImage *finalImage = [UIImage pasteImage:image intoImage:defaultImage atOffset:CGPointMake(2, 2)];
	//return finalImage;
	
	// to leave the images full size, use this code
	return  image;
}

- (void)dealloc {
	[JSONRequestQueue release];
	[JSONRequestResults release];	
    [super dealloc];
}

@end
