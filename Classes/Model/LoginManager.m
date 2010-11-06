//
//  LoginManager.m
//  RecipeShopper
//
//  Created by Simon Barnett on 23/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "LoginManager.h"
#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"

@implementation LoginManager

@synthesize loginName;

- (id)init {
	[super init];
	dataManager = [DataManager getInstance];
	return self;
}

- (void)requestLoginToStore {
	if ([dataManager loggedIn] == NO) {
		if ([dataManager phoneIsOnline] == YES) {
			UIAlertView *loginPrompt = [[UIAlertView alloc] initWithTitle:@"Login" message:@"Please login to your account\n\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
			
			UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 260.0, 30.0)];
			[emailField setBackgroundColor:[UIColor whiteColor]];
			[emailField setPlaceholder:@"john@example.com"];
			[emailField setAutocorrectionType: UITextAutocorrectionTypeNo];
			[emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[emailField setBorderStyle:UITextBorderStyleBezel];
			[emailField setKeyboardType:UIKeyboardTypeEmailAddress];
			
			NSString *cachedEmail = [dataManager getUserPreference:@"login.email"];
			
			if (cachedEmail != nil) {
				[emailField setText:cachedEmail];
			}
			
			[loginPrompt addSubview:emailField];
			
			UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 120.0, 260.0, 30.0)];
			[passwordField setBackgroundColor:[UIColor whiteColor]];
			[passwordField setPlaceholder:@"Password"];
			[passwordField setSecureTextEntry:YES];
			[passwordField setAutocorrectionType: UITextAutocorrectionTypeNo];
			[passwordField setBorderStyle:UITextBorderStyleBezel];
			
			NSString *cachedPassword = [dataManager getUserPreference:@"login.password"];
			
			if (cachedPassword != nil) {
				[passwordField setText:cachedPassword];
			}
			
			[loginPrompt addSubview:passwordField];
			
			[emailField becomeFirstResponder];
			[loginPrompt show];
			[loginPrompt release];
			[passwordField release];
			[emailField release];
		} else {
			UIAlertView *networkError = [[UIAlertView alloc] initWithTitle:@"Network error" message:@"Feature unavailable offline" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
			[networkError show];
			[networkError release];
		}
	}
}

#pragma mark -
#pragma mark Buttons responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[alertView title] isEqualToString:@"Login"] && [alertView cancelButtonIndex] != buttonIndex) {
		UITextField *emailField = [[alertView subviews] objectAtIndex:4];
		[emailField resignFirstResponder];
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([[alertView title] isEqualToString:@"Login"] && [alertView cancelButtonIndex] != buttonIndex) {
		NSString *emailText = [[[alertView subviews] objectAtIndex:4] text];
		NSString *passwordText = [[[alertView subviews] objectAtIndex:5] text];
		
		if (emailText == nil) {
			emailText = @"";
		}
		
		if (passwordText == nil) {
			passwordText = @"";
		}
		
		NSMutableArray *details = [NSMutableArray arrayWithCapacity:2];
		[details addObject:emailText];
		[details addObject:passwordText];
		
		RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
		[dataManager showOverlayView:[[[[appDelegate tabBarController] selectedViewController] view] window]];
		
		[NSThread detachNewThreadSelector:@selector(loginToStore:) toTarget:self withObject:details];
	} else if ([[alertView title] isEqualToString:@""] && [alertView cancelButtonIndex] != buttonIndex) {
		/* retry button after failed login */
		[self requestLoginToStore];
	}
}

- (void)loginToStore:(NSArray *)details {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[dataManager setOverlayLabelText:@"Logging in ..."];
	
	if ([dataManager loginToStore:[details objectAtIndex:0] withPassword:[details objectAtIndex:1]] == YES) {
		/* save username and password in preferences */
		[dataManager setUserPreference:@"login.email" prefValue:[details objectAtIndex:0]];
		[dataManager setUserPreference:@"login.password" prefValue:[details objectAtIndex:1]];
		
		/* save the login name so we can display it on the home page */
		[self setLoginName:[details objectAtIndex:0]];
		
		/* empty the online basket  PROMPT TO EMPTY BASKET HERE*/
		[dataManager emptyOnlineBasket];
		
		/* add any products which may be in the product basket to the online basket now */
		[dataManager addProductBasketToOnlineBasket];
		
		[dataManager hideOverlayView];
		
		/* inform any observers that the user has logged in */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:self];
	}else{
		/* LOGIN FAILED */
		[dataManager hideOverlayView];
		
		/* inform any observers that the loggin has failed */
		[[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFailed" object:self];
	}
	
	[pool release];
}

@end
