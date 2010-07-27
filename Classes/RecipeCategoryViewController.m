//
//  RecipeCatagoryViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 6/7/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "RecipeCategoryViewController.h"
#import "RecipeShopperAppDelegate.h"

#define SCROLL_VIEW_MAX_HEIGHT 1145.0f

@implementation RecipeCategoryViewController

@synthesize recipeSpecificCategoryViewController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark -
#pragma mark View Lifecycle Management

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Setup category mappings
	categoryMappings = [[NSDictionary dictionaryWithObjectsAndKeys:
						@"Bread, cakes & biscuits", [NSNumber numberWithInt: BREAD_CAKES_BISCUITS], 
						@"Breakfast", [NSNumber numberWithInt: BREAKFAST],
						@"Dessert", [NSNumber numberWithInt: DESSERT],
						@"Dinners", [NSNumber numberWithInt: DINNERS],
						@"Drinks", [NSNumber numberWithInt: DRINKS],
						@"Lunches", [NSNumber numberWithInt: LUNCHES],
						@"Main", [NSNumber numberWithInt: MAIN],
						@"Party food", [NSNumber numberWithInt: PARTY_FOOD],
						@"Salads", [NSNumber numberWithInt: SALADS],
						@"Sauces", [NSNumber numberWithInt: SAUCES],
						@"Snacks & side dishes", [NSNumber numberWithInt: SNACKS_SIDE_DISHES],
						@"Soups", [NSNumber numberWithInt: SOUPS],
						@"Starter", [NSNumber numberWithInt: STARTER],
						nil] retain];
	
	self.title = NSLocalizedString(@"Recipe Book", @"Complete Tesco recipe list");
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	//Ensure scroll view is right size
	scrollView.contentSize = CGSizeMake(320.0f, SCROLL_VIEW_MAX_HEIGHT);
}

#pragma mark -
#pragma mark Additional Instance Functions

-(IBAction)categoryChosen:(id) sender {
	NSNumber *category = [NSNumber numberWithInt:[sender tag]];
	NSString *categoryName = [categoryMappings objectForKey:category];
	
	if ([self recipeSpecificCategoryViewController] == nil) {
		RecipeSpecificCategoryViewController *categorySpecificView = [[RecipeSpecificCategoryViewController alloc] initWithNibName:@"RecipeSpecificCategoryView" bundle:nil];
		self.recipeSpecificCategoryViewController = categorySpecificView;
		[categorySpecificView release];
	}
	
	//Always set new category name
	[recipeSpecificCategoryViewController loadRecipesForCategory:categoryName];
	
	//Ensure its scrolled to the top
	[recipeSpecificCategoryViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	//Transition to new view
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate recipeCategoryViewNavController] pushViewController:self.recipeSpecificCategoryViewController animated:YES];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
	[categoryMappings release];
	[recipeSpecificCategoryViewController release];
}


@end
