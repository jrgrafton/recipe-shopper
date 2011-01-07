//
//  HomeViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/10/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "HomeViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "LogManager.h"

@interface HomeViewController()
- (void)switchToOfflineMode;
- (void)loginSuccess;
- (void)loginFailed;
- (void)networkConnectionSucceeded;
- (void)networkConnectionFailed;
@end

@implementation HomeViewController

@synthesize recipeBasketViewController;
@synthesize recipeHistoryViewController;
@synthesize recipeCategoryViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//initWithNib does not get called when controller is root in navigation stack
	dataManager = [DataManager getInstance];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	if ([[dataManager getUserPreference:@"offlineMode"] isEqualToString:@"YES"]) {
		[dataManager setOfflineMode:YES];
		[offlineModeSwitch setOn:YES];
	} else {
		[dataManager setOfflineMode:NO];
		[offlineModeSwitch setOn:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* add ourselves as an observer for offline mode switch messages so we can set the switch if need be */
	/* Note this notification is sent whenever anon session key can not be generated and user selects offline mode from alert */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToOfflineMode) name:@"SwitchToOffline" object:nil];
	
	//If we have logged in elsewhere make sure our interface is in correct state
	if ([dataManager loggedIn]) {
		[self loginSuccess];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver: self];	
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
	
    return true;
}

- (IBAction)login:(id)sender {
	/* add ourselves as an observer for logged in messages so we can replace the login button when the user has logged in */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"LoggedIn" object:nil];
	
	/* add ourselves as an observer for login failed so we can prompt user */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"LoginFailed" object:nil];
	
	/* add ourselves as an observer for login cancelled so we can remove ourselves as observer */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCancelled) name:@"LoginCancelled" object:nil];
	
	[dataManager requestLoginToStore];
}

- (void)switchToOfflineMode {
	[offlineModeSwitch setOn:YES];
}

- (void)loginSuccess {
	[[NSNotificationCenter defaultCenter] removeObserver: self];	
	
	/* replace the login button and register link with the greeting label and the logout button */
	[loginButton setHidden:YES];
	[logoutButton setHidden:NO];
	[createAccountButton setHidden:YES];
	[loggedOutGreetingLabel setHidden:YES];
	[loggedInGreetingLabel setHidden:NO];
	[loggedInGreetingLabel setText:[NSString stringWithFormat:@"Hello, %@", [[dataManager getCustomerName] capitalizedString]]];
}

- (void)loginFailed {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
	[errorAlert show];
	[errorAlert release];
}

- (void)loginCancelled {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)logoutComplete {
	/* then replace the logout button and the greeting with the login button and register link again */
	[loginButton setHidden:NO];
	[logoutButton setHidden:YES];
	[createAccountButton setHidden:NO];
	[loggedInGreetingLabel setHidden:YES];
	[loggedOutGreetingLabel setHidden:NO];
	
	[dataManager hideOverlayView];
}

- (IBAction)logout:(id)sender {
	[dataManager showOverlayView:[[self view] window]];
	[dataManager setOverlayLabelText:@"Logging out"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutComplete) name:@"LogoutComplete" object:nil];
	
	/* log out of the store */
	[NSThread detachNewThreadSelector:@selector(logoutOfStore) toTarget:dataManager withObject:nil];
}

- (IBAction)transitionToRecipeCategoryView:(id)sender {
	if (recipeCategoryViewController == nil) {
		RecipeCategoryViewController *recipeCategoryView = [[RecipeCategoryViewController alloc] initWithNibName:@"RecipeCategoryView" bundle:nil];
		[self setRecipeCategoryViewController:recipeCategoryView];
		[recipeCategoryView release];
	}
	
	/* transition to recipe category view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewNavController] pushViewController:self.recipeCategoryViewController animated:YES];
}

- (IBAction)transitionToRecipeBasketView:(id)sender {
	if (recipeBasketViewController == nil) {
		RecipeBasketViewController *recipeBasketView = [[RecipeBasketViewController alloc] initWithNibName:@"RecipeBasketView" bundle:nil];
		[self setRecipeBasketViewController:recipeBasketView];
		[recipeBasketView release];
	}
	
	/* transition to recipe basket view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewNavController] pushViewController:self.recipeBasketViewController animated:YES];
}

- (IBAction)transitionToRecipeHistoryView:(id)sender {
	if (recipeHistoryViewController == nil) {
		RecipeHistoryViewController *recipeHistoryView = [[RecipeHistoryViewController alloc] initWithNibName:@"RecipeHistoryView" bundle:nil];
		[self setRecipeHistoryViewController:recipeHistoryView];
		[recipeHistoryView release];
	}
	
	/* transition to recipe category view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewNavController] pushViewController:self.recipeHistoryViewController animated:YES];
}

- (IBAction)offlineModeValueChanged:(id)sender {
	if ([offlineModeSwitch isOn] == NO) {
		
		[dataManager setUserPreference:@"offlineMode" prefValue:@"NO"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionSucceeded) name:@"PhoneHasNetworkConnection" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectionFailed) name:@"PhoneHasNoNetworkConnection" object:nil];
		
		[NSThread detachNewThreadSelector:@selector(phoneHasNetworkConnection) toTarget:dataManager withObject:nil];
	}else {
		[dataManager setOfflineMode:YES];
		[dataManager setUserPreference:@"offlineMode" prefValue:@"YES"];
	}
}

- (void)networkConnectionSucceeded {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[offlineModeSwitch setOn:NO];
	[dataManager setOfflineMode:NO];
	[dataManager setUserPreference:@"offlineMode" prefValue:@"NO"];
}

- (void)networkConnectionFailed {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[offlineModeSwitch setOn:YES];
	[dataManager setOfflineMode:YES];
	UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to shop online while phone has no network connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[warningAlert show];
	[warningAlert release];
	
	[dataManager setUserPreference:@"offlineMode" prefValue:@"YES"];
	
	return;
}

- (IBAction)createAccount:(id)sender {
	if (![dataManager phoneIsOnline]) {
		UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Unable to create account while offline" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[warningAlert show];
		[warningAlert release];
		return;
	}else {
		UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"New Account" message:@"You will now be transferred to Tesco.com for account creation" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Proceed",nil];
		[successAlert show];
		[successAlert release];
	}
}

#pragma mark -
#pragma mark UIAlertView responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//In case user clicks cancel on login
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	if ([alertView title] == @"New Account" && buttonIndex != [alertView cancelButtonIndex]) {
		NSURL *url = [NSURL URLWithString:@"https://secure.tesco.com/register/default.aspx?newReg=true&ui=iphone"];
		
		if (![[UIApplication sharedApplication] openURL:url]){
			[LogManager log:@"Unable to open Tesco.com registration page" withLevel:LOG_ERROR fromClass:@"HomeViewController"];
		}
	}else if ([alertView title] == @"Error" && buttonIndex == 1) {
		/* Retry on login failed screen */
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:@"LoggedIn" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailed) name:@"LoginFailed" object:nil];
		[dataManager requestLoginToStore];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
