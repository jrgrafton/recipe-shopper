//
//  APIPaymentManager.m
//  RecipeShopper
//
//  Created by User on 8/6/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "APIPaymentManager.h"
#import "DataManager.h"

@interface APIPaymentManager ()
//Private class functions
-(void)loginSuccessful;
@end

static NSString* loginSuccessfulNotification = @"loginSuccessfulNotification";

@implementation APIPaymentManager

- (id)init {
	if (self = [super init]) {
		//Initialisation code
		NSURL *tescoUrl = [NSURL URLWithString:@"http://www.tesco.com/superstore/"];
		NSURLRequest *tescoDotComRequest = [NSURLRequest requestWithURL:tescoUrl];
		urlConnection = [[NSURLConnection alloc] initWithRequest:tescoDotComRequest delegate:self];
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
	
	//Add cookies for login
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies];
	//Need v and u and t
	NSString *vCookie = @"";
	NSString *uCookie = @"";
	NSString *tCookie = @"";
	
	for (NSHTTPCookie *cookie in cookies) {
		if ([[cookie name] isEqualToString:@"v"]) {
			vCookie = [cookie value];
		}else if ([[cookie name] isEqualToString:@"u"]) {
			uCookie = [cookie value];
		}else if ([[cookie name] isEqualToString:@"t"]) {
			tCookie = [cookie value];
		}
		
	}
	NSString *cookieString = [NSString stringWithFormat:@"v=%@;u=%@;t=%@;sessionTest=True",vCookie,uCookie,tCookie];
	
	[tescoLoginRequest setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
	[tescoLoginRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
	[tescoLoginRequest setValue:@"secure.tesco.com" forHTTPHeaderField:@"Host"];
	[tescoLoginRequest setValue:cookieString forHTTPHeaderField:@"Cookie"];
	
	[tescoLoginRequest setHTTPMethod:@"POST"];
	[tescoLoginRequest setHTTPBody:postData];
	
	NSLog(@"Request is: %@",postDataString);
	NSLog(@"Headers: %@",[(tescoLoginRequest) allHTTPHeaderFields]);
	
	urlConnection = [[NSURLConnection alloc] initWithRequest:tescoLoginRequest delegate:self];
	[pool release];
	
	//We want to know when login has succeeded
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessful) name:loginSuccessfulNotification object:self];
}

- (void)loginSuccessful{
	NSLog(@"LOGIN SUCCESSFUL GOING TO GROCERY SCREEN");
	NSURL *groceriesURL = [NSURL URLWithString:@"https://secure.tesco.com/groceries/checkout/"];
	NSMutableURLRequest *tescoGroceryPageRequest = [NSMutableURLRequest requestWithURL:groceriesURL];
	urlConnection = [[NSURLConnection alloc] initWithRequest:tescoGroceryPageRequest delegate:self];
}

#pragma mark NSURLDelegate Methods

- (NSURLRequest *)connection: (NSURLConnection *)inConnection
			 willSendRequest: (NSURLRequest *)inRequest
			redirectResponse: (NSURLResponse *)inRedirectResponse {
	
	NSLog(@"REDIRECT");
	
    if (inRedirectResponse) {
        NSMutableURLRequest *r = [[inRequest mutableCopy] autorelease];
        [r setURL: [inRedirectResponse URL]];
        //[r setHTTPBody: NSURLRequest];
        return r;
    } else {
        return inRequest;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
	
	//Print all header fields
	NSLog(@"Headers: %@",[((NSHTTPURLResponse*)response) allHeaderFields]);
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
	
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	NSLog(@"%@",dataString);
	
    [receivedData setLength:0];
	[urlConnection release];
	
	NSLog(@"Shared cookies are %@",[[NSHTTPCookieStorage sharedHTTPCookieStorage]cookies]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [urlConnection release];
	
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	
    // inform the use
    NSLog(@"Connection failed! Error - %@ %@",[error localizedDescription],[[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[urlConnection release];
    [super dealloc];
}

@end
