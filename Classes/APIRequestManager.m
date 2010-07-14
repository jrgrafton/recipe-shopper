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
#import "DBProduct.h"
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
@end

@implementation APIRequestManager

- (id)init {
	if (self = [super init]) {
		//Initialisation code
	}
	return self;
}

- (NSArray*)fetchProductsMatchingSearchTerm: (NSString*)searchTerm onThisPage:(NSInteger) pageNumber andGiveMePageCount:(NSInteger*) pageCountHolder{
	NSMutableArray *products = [NSMutableArray array];
	
	NSString *loginRequestString = [NSString stringWithFormat:@"%@?command=LOGIN&email=&password=&developerkey=%@&applicationkey=%@",REST_SERVICE_URL,DEVELOPER_KEY,APPLICATION_KEY];
	
	//Perform anonymous login
	NSDictionary *loginDetails = [self getJSONForRequest:loginRequestString];
	NSString *sessionKey = @"";
	
	//Get Session key
	if (loginDetails != nil) {
		sessionKey = [loginDetails objectForKey:@"SessionKey"];
	}
	
	if ([sessionKey length] == 0){
		[LogManager log:@"Anonymous login failed while searching for products" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
		return products;
	}
	
	//Now we have session key try doing search...
	NSString *productSearchRequestString = [NSString stringWithFormat:@"%@?command=PRODUCTSEARCH&searchtext=%@&page=%d&sessionkey=%@",REST_SERVICE_URL,searchTerm,pageNumber,sessionKey];
	NSDictionary *productSearchResult = [self getJSONForRequest:productSearchRequestString];
	*pageCountHolder = [[productSearchResult objectForKey:@"TotalPageCount"] intValue];
	
	NSArray *JSONProducts = [productSearchResult objectForKey:@"Products"];
	
	for (NSDictionary *JSONProduct in JSONProducts) {
		[products addObject:[self buildProductFromInfo:JSONProduct]];
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
		NSString *msg = [NSString stringWithFormat:@"error parsing JSON: '%@'.",[error localizedDescription]];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
		results = [NSArray array];
	}
	
	//Always release alloc'd objects
	[parser release];
	[dataString release];
	
	return results;
}

@end
