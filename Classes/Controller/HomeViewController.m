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

@implementation HomeViewController

@synthesize recipeBasketViewController;
@synthesize recipeHistoryViewController;
@synthesize recipeCategoryViewController;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[webView setBackgroundColor:[UIColor clearColor]];
	[webView loadHTMLString:@"<a href=\"https://secure.tesco.com/register/default.aspx?newReg=true&ui=nokia\">Register with Tesco.com</a>" baseURL:nil];
	
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
	[webView setHidden:YES];
	[greetingLabel setHidden:NO];
	[greetingLabel setText:[NSString stringWithFormat:@"Hello %@", [DataManager getCustomerName]]];
	[logoutButton setHidden:NO];
}

- (IBAction)logout:(id)sender {
	/* log out of the store */
	[DataManager logoutOfStore];
	
	/* then replace the logout button and the greeting with the login button and register link again */
	[loginButton setHidden:NO];
	[webView setHidden:NO];
	[greetingLabel setHidden:YES];
	[logoutButton setHidden:YES];
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
	if (offlineModeSwitch.on) {
		[DataManager setOfflineMode:YES];
	} else {
		[DataManager setOfflineMode:NO];
	}
}

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
