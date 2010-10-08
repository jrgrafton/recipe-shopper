//
//  RecipeCategoryViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright Assentec 2010. All rights reserved.
//

#import "RecipeCategoryViewController.h"
#import "RecipeShopperAppDelegate.h"

@implementation RecipeCategoryViewController

@synthesize recipeListViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
    categoryMappings = [[NSDictionary dictionaryWithObjectsAndKeys:
						 @"Bread, cakes & biscuits", [NSNumber numberWithInt:CAKES], 
						 @"Breakfast", [NSNumber numberWithInt:BREAKFASTS],
						 @"Dessert", [NSNumber numberWithInt:DESSERTS],
						 @"Dinners", [NSNumber numberWithInt:DINNERS],
						 @"Drinks", [NSNumber numberWithInt:DRINKS],
						 @"Lunches", [NSNumber numberWithInt:LUNCHES],
						 @"Main", [NSNumber numberWithInt:MAINS],
						 @"Party food", [NSNumber numberWithInt:PARTY],
						 @"Salads", [NSNumber numberWithInt:SALADS],
						 @"Sauces", [NSNumber numberWithInt:SAUCES],
						 @"Snacks & side dishes", [NSNumber numberWithInt:SNACKS],
						 @"Soups", [NSNumber numberWithInt:SOUPS],
						 @"Starter", [NSNumber numberWithInt:STARTERS],
						 nil] retain];
		
	/* ensure the recipe category view is the right size */
	recipeCategoryView.contentSize = CGSizeMake(320.0f, 1145.0f);	
}

- (IBAction)categoryChosen:(id)sender {
	/* find the category name chosen from the tag of the button pressed */
	NSString *categoryName = [categoryMappings objectForKey:[NSNumber numberWithInt:[sender tag]]];
	
	if ([self recipeListViewController] == nil) {
		/* get a reference to the recipe list view */
		RecipeListViewController *recipeListView = [[RecipeListViewController alloc] initWithNibName:@"RecipeListView" bundle:nil];
		self.recipeListViewController = recipeListView;
		[recipeListView release];
	}
	
	/* load the recipes that are in this category into the recipe list */
	[recipeListViewController loadRecipesForCategory:categoryName];
	
	/* make sure the list is scrolled to the top */
	[recipeListViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	/* transition to new view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate recipeBookViewController] pushViewController:self.recipeListViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[categoryMappings release];
	[recipeListViewController release];
}

@end
