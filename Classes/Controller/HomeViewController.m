//
//  HomeViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/10/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "HomeViewController.h"
#import "RecipeShopperAppDelegate.h"

@implementation HomeViewController

@synthesize recipeBasketViewController;
@synthesize recipeHistoryViewController;
@synthesize recipeCategoryViewController;

- (IBAction)transitionToRecipeBasketView:(id)sender {
	if (recipeBasketViewController == nil) {
		RecipeBasketViewController *recipeBasketView = [[RecipeBasketViewController alloc] initWithNibName:@"RecipeBasketView" bundle:nil];
		[self setRecipeBasketViewController:recipeBasketView];
		[recipeBasketView release];
	}
	
	/* transition to recipe basket view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:self.recipeBasketViewController animated:YES];
}

- (IBAction)transitionToRecipeHistoryView:(id)sender {
	if (recipeHistoryViewController == nil) {
		RecipeHistoryViewController *recipeHistoryView = [[RecipeHistoryViewController alloc] initWithNibName:@"RecipeHistoryView" bundle:nil];
		[self setRecipeHistoryViewController:recipeHistoryView];
		[recipeHistoryView release];
	}
	
	/* transition to recipe category view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:self.recipeHistoryViewController animated:YES];
}

- (IBAction)transitionToRecipeCategoryView:(id)sender {
	if (recipeCategoryViewController == nil) {
		RecipeCategoryViewController *recipeCategoryView = [[RecipeCategoryViewController alloc] initWithNibName:@"RecipeCategoryView" bundle:nil];
		[self setRecipeCategoryViewController:recipeCategoryView];
		[recipeCategoryView release];
	}
	
	/* transition to recipe category view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:self.recipeCategoryViewController animated:YES];
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
