//
//  APIPaymentManager.m
//  RecipeShopper
//
//  Created by User on 8/6/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "APIPaymentManager.h"
#import "DataManager.h"
#import "LogManager.h"
#import "RegexKitLite.h"

@interface APIPaymentManager ()
//Private class functions
-(NSHTTPCookie*)getCookieForName: (NSString*)name;
-(void)setCookiesForUrlRequest: (NSMutableURLRequest*)urlRequest withCookieKeys:(NSString*)cookieNameOne, ...;
@end

@implementation APIPaymentManager

- (id)init {
	if (self = [super init]) {
		//Initialisation code
		NSURL *tescoUrl = [NSURL URLWithString:@"https://secure.tesco.com/groceries/checkout/payment/default.aspx"];
		NSURLRequest *tescoRequest = [[NSMutableURLRequest requestWithURL:tescoUrl] retain];
		
		NSString* msg = [NSString stringWithFormat:@"Sending %@ request: URL %@ headers [[[%@]]]",[tescoRequest HTTPMethod],[tescoRequest URL],[tescoRequest allHTTPHeaderFields]];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];

		urlConnection = [[NSURLConnection alloc] initWithRequest:tescoRequest delegate:self];
		receivedData = [[NSMutableData data] retain];
	}
	return self;
}

#pragma mark external functions
- (void)navigateToPaymentPage {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *email = [[DataManager fetchUserPreference:@"login.email"] stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
	NSString *password = [DataManager fetchUserPreference:@"login.password"];
	
	[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:[NSString stringWithFormat:@"Stage 1 of 5"] waitUntilDone:TRUE];
	
	//Post login credentials to site
	NSURL *tescoLoginUrl = [NSURL URLWithString:@"https://secure.tesco.com/register/default.aspx?vstore=0"];
	NSMutableURLRequest *tescoLoginRequest = [NSMutableURLRequest requestWithURL:tescoLoginUrl];
	NSString *postDataString = [NSString stringWithFormat:@"form=fSignin&from=https://secure.tesco.com/"
								"groceries/checkout/payment/default.aspx&formData=bmV3UmVnPXRydWUm&loginID=%@"
								"&password=%@&seamlesswebtag=&confirm-signin.x=39&confirm-signin.y=7",email,password];
	NSData *postData = [postDataString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	NSString *postLength = [NSString stringWithFormat:@"%i",[postData length]];
	
	[self setCookiesForUrlRequest:tescoLoginRequest withCookieKeys:@"v",@"u",@"t",@"sessionTest",nil];
	
	[tescoLoginRequest setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[tescoLoginRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[tescoLoginRequest setValue:@"secure.tesco.com" forHTTPHeaderField:@"Host"];
	
	[tescoLoginRequest setHTTPMethod:@"POST"];
	[tescoLoginRequest setHTTPBody:postData];
	
	NSString* msg = [NSString stringWithFormat:@"Sending POST request: URL %@ headers [[[%@]]] data [[[%@]]]",[tescoLoginRequest URL],[tescoLoginRequest allHTTPHeaderFields],postDataString];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];
	
	urlConnection = [[NSURLConnection alloc] initWithRequest:tescoLoginRequest delegate:self];
	[pool release];
}

#pragma mark Private helper functions
-(void)setCookiesForUrlRequest: (NSMutableURLRequest*)urlRequest withCookieKeys:(NSString*)cookieNameOne, ...{
	va_list args;
	va_start(args, cookieNameOne);
	NSString *cookieName;
	NSMutableString *cookieRequestString = [NSMutableString string];
	
	for (cookieName = cookieNameOne; cookieName != nil; cookieName = va_arg(args, NSString*)){
		NSHTTPCookie* cookie = [self getCookieForName:cookieName];
		if (cookie != nil) {
			cookieRequestString = [NSString stringWithFormat:@"%@;%@=%@",cookieRequestString,[cookie name],[cookie value]];
		}
	}
	[urlRequest setValue:cookieRequestString forHTTPHeaderField:@"Cookie"];
	va_end(args);	
}

-(NSHTTPCookie*)getCookieForName: (NSString*)name {
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
	for (NSHTTPCookie *cookie in cookies) {
		if ([[cookie name] isEqualToString:name]) {
			return cookie;
		}
	}
	return nil;
}

#pragma mark NSURLDelegate Methods

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	if (redirectResponse) {
		request = request;

		NSString* msg = [NSString stringWithFormat:@"Redirect response: URL %@ status code %i header fields are [[[%@]]]",[redirectResponse URL],[(NSHTTPURLResponse *)redirectResponse statusCode],[(NSHTTPURLResponse *)redirectResponse allHeaderFields]];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];
		
        NSMutableURLRequest *r = [[request mutableCopy] autorelease]; // clone original request
        [r setURL: [request URL]];
		if ([(NSHTTPURLResponse*)redirectResponse statusCode] == 307) {
			[r setHTTPMethod:@"POST"];
		}else {
			[r setHTTPMethod:@"GET"];
		}
		[self setCookiesForUrlRequest:r withCookieKeys:@"s",@"v",@"u",@"t",nil];
		
		msg = [NSString stringWithFormat:@"Will send %@ request: URL %@ header fields are[[[%@]]]",[r HTTPMethod],[r URL],[r allHTTPHeaderFields]];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];
		
        return r;
    } else {
        return request;
    }
	
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
	NSString* msg = [NSString stringWithFormat:@"Response: %i header fields are[[[%@]]]",[(NSHTTPURLResponse *)response statusCode],[(NSHTTPURLResponse *)response allHeaderFields]];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];
	
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// do something with the data
    // receivedData is declared as a method instance elsewhere
	NSString *dataString = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];
	
	NSString* msg = [NSString stringWithFormat:@"Success! Received %d bytes of data [[[%@]]]",[receivedData length],dataString];
	[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];
	
    [receivedData setLength:0];
	[urlConnection release];
	
	//Need to check if webpage we recieved contains META refresh tag (hmmm...)
	NSString* regex = @".*?<meta http-equiv=\"[Rr][Ee][Ff][Rr][Ee][Ss][Hh]\".*?[Uu][Rr][Ll]=[\"]{0,1}(.*?)[\"]{0,1}[ ]{0,1}/>.*";
	NSString* redirectURLString = [dataString stringByMatching:regex capture:1];
	
	if(redirectURLString !=nil){
		//Honour meta refresh
		NSURL *redirectURL = [NSURL URLWithString:redirectURLString];
		NSMutableURLRequest *redirectRequest = [[NSMutableURLRequest requestWithURL:redirectURL] retain];
		[redirectRequest setValue:@"secure.tesco.com" forHTTPHeaderField:@"Host"];
		[redirectRequest setHTTPMethod:@"GET"];
		
		//Set all cookies that we are gonna be needing
		[self setCookiesForUrlRequest:redirectRequest withCookieKeys:@"v",@"u",@"t",@"CustomerId",@"CID",@"BTCCMS",@"UIMode",@"PS",@"SSVars",nil];
		
		NSString* msg = [NSString stringWithFormat:@"Sending %@ request: URL %@ headers [[[%@]]]",[redirectRequest HTTPMethod],[redirectRequest URL],[redirectRequest allHTTPHeaderFields]];
		[LogManager log:msg withLevel:LOG_INFO fromClass:@"APIPaymentManager"];
		
		urlConnection = [[NSURLConnection alloc] initWithRequest:redirectRequest delegate:self];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [urlConnection release];
	
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // print error
	NSString* msg = [NSString stringWithFormat:@"Connection failed! Error - %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSErrorFailingURLStringKey]];
	[LogManager log:msg withLevel:LOG_ERROR fromClass:@"APIPaymentManager"];
	
	//Be sure to notify all waiting parties with nil object
	[[NSNotificationCenter defaultCenter] postNotificationName:@"paymentPageLoaded" object:nil userInfo:nil];
}

- (void)dealloc {
	[urlConnection release];
    [super dealloc];
}

@end
