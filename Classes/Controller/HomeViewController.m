//
//  HomeViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/10/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "HomeViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"
#include "LogManager.h"

@implementation HomeViewController

@synthesize recipeBasketViewController;
@synthesize recipeHistoryViewController;
@synthesize recipeCategoryViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[DataManager setOfflineMode:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
	
    return true;
}

- (IBAction)login:(id)sender {
	[DataManager requestLoginToStore];
	
	/* add ourselves as an observer for logged in messages so we can replace the login button when the user has logged in */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(replaceLoginButton) name:@"LoggedIn" object:nil];
}

- (void)replaceLoginButton {
	/* replace the login button and register link with the greeting label and the logout button */
	[loginButton setHidden:YES];
	[logoutButton setHidden:NO];
	[createAccountButton setHidden:YES];
	[greetingLabel setHidden:NO];
	[greetingLabel setText:[NSString stringWithFormat:@"Hello, %@", [[DataManager getCustomerName] capitalizedString]]];
}

- (IBAction)logout:(id)sender {
	/* log out of the store */
	[DataManager logoutOfStore];
	
	/* then replace the logout button and the greeting with the login button and register link again */
	[loginButton setHidden:NO];
	[logoutButton setHidden:YES];
	[createAccountButton setHidden:NO];
	[greetingLabel setHidden:YES];
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
	[DataManager setOfflineMode: [offlineModeSwitch isOn]];
}

- (IBAction)createAccount:(id)sender {
	UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"New Account" message:@"You will now be transferred to Tesco.com for account creation" delegate:self cancelButtonTitle:@"Proceed" otherButtonTitles:nil];
	[successAlert show];
	[successAlert release];
}

#pragma mark -
#pragma mark UIAlertView responders

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	//User wishes to proceed to payment screen
	NSURL *url = [NSURL URLWithString:@"https://secure.tesco.com/register/default.aspx?newReg=true&ui=iphone"];
	
	if (![[UIApplication sharedApplication] openURL:url]){
		[LogManager log:@"Unable to open Tesco.com registration page" withLevel:LOG_ERROR fromClass:@"HomeViewController"];
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
