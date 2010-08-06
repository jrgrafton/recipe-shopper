//
//  RecipeSpecificCategoryViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 6/8/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "RecipeSpecificCategoryViewController.h"
#import "DataManager.h"
#import "RecipeShopperAppDelegate.h"
#import "NSData-Extended.h"
#import "UITableViewCellFactory.h"


@implementation RecipeSpecificCategoryViewController

@synthesize commonSpecificRecipeViewController;
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

#pragma mark -
#pragma mark View Lifecycle Management

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	//Set background colour
	[categoryTableView setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
													   green:0.9137254901960784 
														blue:0.9568627450980392
													   alpha:1.0]];
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//Only transition when webview has finished loading
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate recipeCategoryViewNavController] pushViewController:[self commonSpecificRecipeViewController] animated:YES];
}

#pragma mark -
#pragma mark Additional Instance Functions

-(void) loadRecipesForCategory:(NSString*) categoryString {
	categoryName = [categoryString retain];
	recipes = [[DataManager fetchAllRecipesInCategory: categoryString] retain];
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [recipes count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return categoryName;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    return 90;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
	//Try and use cached cell...
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    // Set up the cell...
	DBRecipe *recipeObject = [recipes objectAtIndex:[indexPath row]];
	[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier usingRecipeObject:recipeObject];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Open specific recipe view
	if (commonSpecificRecipeViewController == nil) {
		CommonSpecificRecipeViewController *specificRecipeView = [[CommonSpecificRecipeViewController alloc] initWithNibName:@"CommonSpecificRecipeView" bundle:nil];
		[self setCommonSpecificRecipeViewController: specificRecipeView];
		[specificRecipeView release];
	}
	[categoryTableView  deselectRowAtIndexPath:indexPath  animated:YES];
	
	//This forces view to load all resources before its pushed on to main view stack
	[[commonSpecificRecipeViewController view] setHidden:FALSE];
	[commonSpecificRecipeViewController processViewForRecipe:[recipes objectAtIndex:[indexPath row]] withWebViewDelegate:self];
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
	[recipes release];
	[categoryName release];
}


@end

