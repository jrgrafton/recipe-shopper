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

#define DEVELOPER_KEY xIvRaeGkY6OavPL1XtX9
#define APPLICATION_KEY CA1A9E0437CBE399E890

#define ANONYMOUS_LOGIN_REQUEST_STRING(developerKey,applicationKey) @"https://secure.techfortesco.com/groceryapi_b1/restservice.aspx?command=LOGIN&email=&password=&developerkey=" #developerKey "&applicationkey=" #applicationKey ""
#define PRODUCT_SEARCH_REQUEST_STRING(searchTerm,sessionKey,pageNumber) @"http://www.techfortesco.com/groceryapi_b1/restservice.aspx?command=PRODUCTSEARCH&searchtext=" #searchTerm "&page=" #pageNumber "&sessionkey=" #sessionKey ""

@interface APIRequestManager ()
//Private class functions
-(NSData *)httpGetRequest:(NSString*)requestUrl;
-(NSString *)urlEncodeValue:(NSString *)string;
-(NSArray *)getJSONForRequest:(NSString*)requestString;
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
	
	//Perform anonymous login
	NSData *data = [self httpGetRequest:ANONYMOUS_LOGIN_REQUEST_STRING(APPLICATION_KEY,DEVELOPER_KEY)];
	NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSArray *details = [self getJSONForRequest:result];
	NSString *sessionKey = @"";
	
	//Get Session key
	for (NSDictionary *detail in details){
		sessionKey = [detail objectForKey:@"SessionKey"];
	}
	if ([sessionKey length] == 0){
		[LogManager log:@"Anonymous login failed while searching for products" withLevel:LOG_ERROR fromClass:@"APIRequestManager"];
		return products;
	}
	
	//Now we have session key try doing search...
	data = [self httpGetRequest:PRODUCT_SEARCH_REQUEST_STRING(searchTerm,sessionKey,pageNumber)];	
	result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	return products;
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

-(NSArray *)getJSONForRequest:(NSString*)requestString{
	NSData *data = [self httpGetRequest:requestString];	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	
	if([dataString length] == 0){
		[LogManager log:@"Request fetched no/invalid results" withLevel:LOG_INFO fromClass:@"APIRequestManager"];
		return [NSArray array];
	}
	
	NSMutableString* jsonString = [NSMutableString stringWithFormat:@"%@", dataString];
	
	SBJSON *parser = [[SBJSON alloc] init];
	NSError *error = nil;
	NSArray *results = [parser objectWithString:jsonString allowScalar:TRUE error:&error];
	
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
