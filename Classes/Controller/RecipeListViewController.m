//
//  RecipeListViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "RecipeListViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"

@implementation RecipeListViewController

@synthesize recipeViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		dataManager = [DataManager getInstance];
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[recipeListView setBackgroundColor: [UIColor clearColor]];
	
	//Create extended name mappings
	extendedNameMappings = [[NSDictionary dictionaryWithObjectsAndKeys:
						 @"Cake and Biscuits", @"Bread, cakes & biscuits",  
						 @"Beautiful Breakfasts", @"Breakfast",
						 @"Tasty Desserts", @"Dessert",
						 @"Delectable Dinners", @"Dinners",
						 @"Hydrating Drinks", @"Drinks",
						 @"Lucious Lunches", @"Lunches",
						 @"Delicious Mains", @"Main",
						 @"Party Food", @"Party food",
						 @"Refreshing Salads", @"Salads",
						 @"Yummy Sauces", @"Sauces",
						 @"Snacks and Sides", @"Snacks & side dishes",
						 @"Sumptious Soups", @"Soups",
						 @"Salacious Starters", @"Starter",
						 nil] retain];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	/* make sure we reload the table data each time we see the view in case a new recipe has been added */
	[recipeListView reloadData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[NSThread sleepForTimeInterval:0.5];
	/* transition to recipe view when webview has finished loading */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewNavController] pushViewController:[self recipeViewController] animated:YES];
}

- (void)loadRecipesForCategory:(NSString *)category {
	categoryName = [category retain];
	recipes = [[dataManager getAllRecipesInCategory:category] retain];
	[recipeListView reloadData];
	
	/* make sure the list is scrolled to the top */
	[recipeListView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recipes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([indexPath row] == 0)? 110:85;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = ([indexPath row] == 0)? @"RecipeCellHeader":@"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* create a cell for this row's recipe */
	Recipe *recipe = [recipes objectAtIndex:[indexPath row]];
	
	if ([indexPath row] == 0) {		
		[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier withRecipe:recipe isHeader:YES];
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:4];
		[headerLabel setText:[extendedNameMappings objectForKey:categoryName]];
	} else {
		[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier withRecipe:recipe isHeader:NO];
	}
    
    return cell;	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (recipeViewController == nil) {
		RecipeViewController *recipeView = [[RecipeViewController alloc] initWithNibName:@"RecipeView" bundle:nil];
		[self setRecipeViewController:recipeView];
		[recipeView release];
	}
	
	[recipeListView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* force view to load all resources before its pushed on to main view stack */
	[[recipeViewController view] setHidden:FALSE];
	[recipeViewController processViewForRecipe:[recipes objectAtIndex:[indexPath row]] withWebViewDelegate:self];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	[recipes release];
	[categoryName release];
	[extendedNameMappings release];
}


@end

