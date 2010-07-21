//
//  RequestManager.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "APIRequestManager.h"
#import "JSON.h"
#import "LogManager.h"
#import "DataManager.h"
#import "DBProduct.h"
#import "APIDeliverylot.h"
#import "UIImage-Extended.h"

#define DEVELOPER_KEY @"xIvRaeGkY6OavPL1XtX9"
#define APPLICATION_KEY @"CA1A9E0437CBE399E890"
#define REST_SERVICE_URL @"https://secure.techfortesco.com/groceryapi_b1/restservice.aspx"

#define PRODUCT_SEARCH_REQUEST_STRING(searchTerm,sessionKey,pageNumber) @"http://www.techfortesco.com/groceryapi_b1/restservice.aspx?command=PRODUCTSEARCH&searchtext=" #searchTerm "&page=" #pageNumber "&sessionkey=" #sessionKey ""

@interface APIRequestManager ()
//Private class functions
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
	}
	return self;
}

- (NSArray*)fetchAvailableDeliverySlots {
	NSMutableArray *availableDeliverySlots = [NSMutableArray array];
	
	NSString *fetchDeliverySlotsRequestString = [NSString stringWithFormat:@"%@?command=LISTDELIVERYSLOTS&SESSIONKEY=%@",REST_SERVICE_URL,authenticatedSessionKey];
	NSDictionary *deliveryDetails = [self getJSONForRequest:fetchDeliverySlotsRequestString];
	
	if (deliveryDetails == nil) {
	#ifdef DEBUG
		[LogManager log:@"Error fetching delivery slots (NO JSON RETURNED)" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	#endif
		return [NSArray array];
	}else {
		NSNumber *statusCode = [deliveryDetails objectForKey:@"StatusCode"];
		if ([statusCode intValue] != 0) {
	#ifdef DEBUG
			NSString* msg = [NSString stringWithFormat:@"Error fetching delivery slots (%@)",deliveryDetails];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	#endif
			return [NSArray array];
		}else{
			//Request seems to have returned successfully...
			NSArray *JSONDeliveryDates = [deliveryDetails objectForKey:@"DeliverySlots"];
			NSDateFormatter *df = [[NSDateFormatter alloc] init];
			[df setDateFormat:@"yyyy-MM-dd hh:mm"];
			
			for (NSDictionary *JSONDeliveryDate in JSONDeliveryDates) {
				NSString *deliverySlotID = [JSONDeliveryDate objectForKey:@"DeliverySlotId"];
				NSString *deliverySlotBranchNumber = [JSONDeliveryDate objectForKey:@"BranchNumber"];
				NSDate *deliverySlotStartDate = [df dateFromString:[JSONDeliveryDate objectForKey:@"SlotDateTimeStart"]];
				NSDate *deliverySlotEndDate = [df dateFromString:[JSONDeliveryDate objectForKey:@"SlotDateTimeEnd"]];
				NSString *deliverySlotCost = [NSString stringWithFormat:@"%@",[JSONDeliveryDate objectForKey:@"ServiceCharge"]];
				
				APIDeliverySlot * apiDeliverySlot = [[APIDeliverySlot alloc] initWithDeliverySlotID:deliverySlotID 
																		andDeliverySlotBranchNumber:deliverySlotBranchNumber 
																		andDeliverySlotStartDate:deliverySlotStartDate 
																	    andDeliverySlotEndDate:deliverySlotEndDate 
																		andDeliverySlotCost:deliverySlotCost];
				
				[availableDeliverySlots addObject:apiDeliverySlot];
			}
			[df release];
		}
	}
	
	//Ensure returned array is sorted
	[availableDeliverySlots sortUsingSelector:@selector(compareByDeliverySlotStart:)];
	
	return [NSArray arrayWithArray:availableDeliverySlots];

}

- (BOOL)addProductBasketToStoreBasket {
	NSArray *productBasket = [DataManager getProductBasket];
	
	NSInteger index = 1;
	NSInteger totalSize = [productBasket count];
	
	for (DBProduct *product in productBasket) {
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Adding product %d of %d",index,totalSize] waitUntilDone:FALSE];
		NSInteger productCount = [DataManager getCountForProduct:product];
		NSNumber *productBaseID = [product productBaseID];
		NSString *addToBasketRequestString = [NSString stringWithFormat:@"%@?command=CHANGEBASKET&PRODUCTID=%@&CHANGEQUANTITY=%d&SESSIONKEY=%@",REST_SERVICE_URL,productBaseID,productCount,authenticatedSessionKey];
		NSDictionary *loginDetails = [self getJSONForRequest:addToBasketRequestString];
		
		if (loginDetails == nil){
			#ifdef DEBUG
			NSString* msg = [NSString stringWithFormat:@"Error adding product [%@] to online basket (NO JSON RETURNED)",productBaseID];
			[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
			#endif
			return FALSE;
		}else {
			NSNumber *statusCode = [loginDetails objectForKey:@"StatusCode"];
			if ([statusCode intValue] != 0) {
				#ifdef DEBUG
				NSString* msg = [NSString stringWithFormat:@"Error adding product [%@] to online basket (%@)",productBaseID,loginDetails];
				[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
				#endif
				return FALSE;
			}else {
				#ifdef DEBUG
				NSString* msg = [NSString stringWithFormat:@"Successfully added product [%@](%d) to online basket",productBaseID,productCount];
				[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];
				#endif
			}
		}
		index++;
	}
	return TRUE;
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
	#ifdef DEBUG
		NSString* msg = [NSString stringWithFormat:@"Login failed for [%@]/[%@]",email,password];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	#endif
		return nil;
	}
	
	return sessionKey;
}

- (NSArray*)getFilteredProductList:(NSArray*)productIdList{
	NSString* sessionKey = [self getSessionKeyForEmail:@"" usingPassword:@""];
	
	//If API is down just return original list
	if (sessionKey == nil) {
		return productIdList;
	}
	
	//Now we have session key try doing search...
	NSMutableArray *filteredProducts = [NSMutableArray array];
	NSInteger index = 1;
	NSInteger totalSize = [productIdList count];
	for (NSNumber *productBaseId in productIdList) {
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Verifying product %d of %d",index,totalSize] waitUntilDone:FALSE];
		
		NSString *productSearchRequestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&sessionkey=%@",REST_SERVICE_URL,productBaseId,sessionKey];
		NSDictionary *productSearchResult = [self getJSONForRequest:productSearchRequestString];
		NSArray *JSONProducts = [productSearchResult objectForKey:@"Products"];
		if ([JSONProducts count] != 0) {
			//Have to rebuild product in case price, description etc has changed
			[filteredProducts addObject: [self buildProductFromInfo:[JSONProducts objectAtIndex:0]]];
		}
		
#ifdef DEBUG
		else{
			NSString *msg = [NSString stringWithFormat:@"Product with baseid %@ exists in database but not on website",productBaseId];
			[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];
		}
#endif
		index++;
	}
	return filteredProducts;
}

- (BOOL)loginToStore:(NSString*) email withPassword:(NSString*) password {
	if ([email length] == 0 || [password length] == 0) {
		return FALSE;
	}
	authenticatedSessionKey = [self getSessionKeyForEmail:email usingPassword:password];
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

-(DBProduct*)buildProductFromInfo:(NSDictionary*)productInfo{
	NSNumber *productBaseID = [NSNumber numberWithInt:[[productInfo objectForKey:@"BaseProductId"] intValue]];
	NSString *productName = [productInfo objectForKey:@"Name"];
	NSString *productPrice = [productInfo objectForKey:@"Price"];
	UIImage *productIcon = [self getImageForProduct:[productInfo objectForKey:@"ImagePath"]];
	NSDate *lastUpdated = [NSDate date];
	
	return [[DBProduct alloc] initWithProductID:productBaseID andProductName:productName
								andProductPrice:productPrice andProductIcon:productIcon
								 andLastUpdated:lastUpdated andUserAdded:YES];
}
							   
-(UIImage*) getImageForProduct:(NSString*)iconUrl{
	UIImage *image = [[[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:iconUrl]]] autorelease];
	UIImage *defaultImage = [UIImage imageNamed:@"icon_product_default.jpg"];
	
	if (image == nil){
		return defaultImage;
	}
	
	image = [image resizedImage:CGSizeMake(41,41) interpolationQuality:kCGInterpolationHigh];
	UIImage *finalImage = [UIImage pasteImage:image intoImage:defaultImage atOffset:CGPointMake(2, 2)];
	return finalImage;					  
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
#ifdef DEBUG
	NSString *msg = [NSString stringWithFormat:@"Sending request: '%@'.",requestUrl];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIRequestManager"];
#endif
	return [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
}

-(id)getJSONForRequest:(NSString*)requestString{
	NSData *data = [self httpGetRequest:requestString];	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if([dataString length] == 0){
		[LogManager log:@"Request fetched no/invalid results" withLevel:LOG_INFO fromClass:@"APIRequestManager"];
		return [NSArray array];
	}
	
	NSMutableString* jsonString = [NSMutableString stringWithFormat:@"%@", dataString];
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSError *error = nil;
	id results = [parser objectWithString:jsonString allowScalar:TRUE error:&error];
	
	if(error != nil){
	#ifdef DEBUG
		NSString *msg = [NSString stringWithFormat:@"error parsing JSON: '%@'.",[error localizedDescription]];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
	#endif
		results = [NSArray array];
	}
	
	//Always release alloc'd objects
	[parser release];
	[dataString release];
	
	return results;
}

@end
