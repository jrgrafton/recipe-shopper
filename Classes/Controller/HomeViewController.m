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
- (void)loginSuccess;
- (void)loginFailed;
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
	
	/* Try and do a cheeky cached load of product departments */
	[NSThread detachNewThreadSelector:@selector(getDepartments) toTarget:dataManager withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	//If we have logged in elsewhere make sure our interface is in correct state
	if ([dataManager loggedIn]) {
		[self loginSuccess];
	}
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
	
	[dataManager requestLoginToStore];
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
	
	UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Login failed" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Retry",nil];
	[successAlert show];
	[successAlert release];
}

- (IBAction)logout:(id)sender {
	/* log out of the store */
	[dataManager logoutOfStore];
	
	/* then replace the logout button and the greeting with the login button and register link again */
	[loginButton setHidden:NO];
	[logoutButton setHidden:YES];
	[createAccountButton setHidden:NO];
	[loggedInGreetingLabel setHidden:YES];
	[loggedOutGreetingLabel setHidden:NO];
}

- (IBAction)transitionToRecipeCategoryView:(id)sender {
	if (recipeCategoryViewController == nil) {
		RecipeCategoryViewController *recipeCategoryView = [[RecipeCategoryViewController alloc] initWithNibName:@"RecipeCategoryView" bundle:nil];
		[self setRecipeCategoryViewController:recipeCategoryView];
		[recipeCategoryView release];
	}
	
	/* transition to recipe category view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:self.recipeCategoryViewController animated:YES];
}

- (IBAction)transitionToRecipeBasketView:(id)sender {
	if (recipeBasketViewController == nil) {
		RecipeBasketViewController *recipeBasketView = [[RecipeBasketViewController alloc] initWithNibName:@"RecipeBasketView" bundle:nil];
		[self setRecipeBasketViewController:recipeBasketView];
		[recipeBasketView release];
	}
	
	/* transition to recipe basket view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:self.recipeBasketViewController animated:YES];
}

- (IBAction)transitionToRecipeHistoryView:(id)sender {
	if (recipeHistoryViewController == nil) {
		RecipeHistoryViewController *recipeHistoryView = [[RecipeHistoryViewController alloc] initWithNibName:@"RecipeHistoryView" bundle:nil];
		[self setRecipeHistoryViewController:recipeHistoryView];
		[recipeHistoryView release];
	}
	
	/* transition to recipe category view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:self.recipeHistoryViewController animated:YES];
}

- (IBAction)offlineModeValueChanged:(id)sender {
	[dataManager setOfflineMode:[offlineModeSwitch isOn]];
	
	if ([offlineModeSwitch isOn] == YES) {
		[dataManager setUserPreference:@"offlineMode" prefValue:@"YES"];
	} else {
		[dataManager setUserPreference:@"offlineMode" prefValue:@"NO"];
	}
}

- (IBAction)createAccount:(id)sender {
	UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"New Account" message:@"You will now be transferred to Tesco.com for account creation" delegate:self cancelButtonTitle:@"Proceed" otherButtonTitles:nil];
	[successAlert show];
	[successAlert release];
}

#pragma mark -
#pragma mark UIAlertView responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//In case user clicks cancel on login
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	if ([alertView title] == @"New Account") {
		NSURL *url = [NSURL URLWithString:@"https://secure.tesco.com/register/default.aspx?newReg=true&ui=iphone"];
		
		if (![[UIApplication sharedApplication] openURL:url]){
			[LogManager log:@"Unable to open Tesco.com registration page" withLevel:LOG_ERROR fromClass:@"HomeViewController"];
		}
	}else if ([alertView title] == @"Error" && buttonIndex == 1) {
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
