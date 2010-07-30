//
//  HomeViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 5/18/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeStoreViewController.h"
#import "CommonSpecificRecipeViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "LogManager.h"
#import "DBRecipe.h"
#import "DataManager.h"

@implementation HomeViewController

@synthesize recipeHistory,homeStoreViewController,commonSpecificRecipeViewController;

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
	self.title = NSLocalizedString(@"Home", @"Local store and recent recipe list");
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	//Set background colour
	[homeTableView setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
													green:0.9137254901960784 
													 blue:0.9568627450980392
													alpha:1.0]];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	//Fetch the latest 10 recipes and refresh the table
	[self setRecipeHistory:[DataManager fetchLastPurchasedRecipes:10]];
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
		return 1;
	}else {
		return [recipeHistory count];
	}

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if(section == 0)
		return @"My Home Store";
	else
		return @"Recent Recipes";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// Set up the cell...
	if(indexPath.section == 0) {
		//Store locator
		NSString *homeStore = [DataManager fetchUserPreference:@"home.store"];
		if (homeStore == NULL) {
			homeStore = @"None";
		}
		[[cell textLabel] setText: homeStore];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:18]];
		[[cell imageView] setImage: nil];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}else {
		//List of recent recipes
		DBRecipe *recipeObject = [recipeHistory objectAtIndex:[indexPath row]];
		[[cell textLabel] setText: [recipeObject recipeName]];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
		[[cell imageView] setImage: [recipeObject iconSmall]];
		cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
	}
	
    return cell;
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
	if (indexPath.section == 0) {
		return 50;
	}else{
		return 60;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Choose home store screen
	if (indexPath.section == 0) {
		if ([self homeStoreViewController] == nil) {
			HomeStoreViewController *homeStoresView = [[HomeStoreViewController alloc] initWithNibName:@"HomeStoreView" bundle:nil];
			self.homeStoreViewController = homeStoresView;
			[homeStoresView release];
		}
		//Check for network connectivity
		if (![DataManager phoneIsOnline]) {
			[LogManager log:@"Internet connection could not be detected" withLevel:LOG_WARNING fromClass:@"HomeViewController"];
			UIAlertView *networkError = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Feature unavailable offline" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
			[networkError show];
			[networkError release];
			[homeTableView  deselectRowAtIndexPath:indexPath  animated:YES]; 
			return;
		}else {
			[LogManager log:@"Internet connection successfully detected" withLevel:LOG_INFO fromClass:@"HomeViewController"];
		}
										
		RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[[appDelegate homeViewNavController] pushViewController:[self homeStoreViewController] animated:YES];
	}else{
		//Open specific recipe view
		if ([self commonSpecificRecipeViewController] == nil) {
			CommonSpecificRecipeViewController *specificRecipeView = [[CommonSpecificRecipeViewController alloc] initWithNibName:@"CommonSpecificRecipeView" bundle:nil];
			self.commonSpecificRecipeViewController = specificRecipeView;
			[specificRecipeView release];
		}
		[homeTableView  deselectRowAtIndexPath:indexPath  animated:YES];
		
		//This forces view to load all resources before its pushed on to main view stack
		[[commonSpecificRecipeViewController view] setHidden:FALSE];
		[commonSpecificRecipeViewController processViewForRecipe:[[self recipeHistory] objectAtIndex:[indexPath row]] withWebViewDelegate:self];
	}
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//Only transition when webview has finished loading
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewNavController] pushViewController:[self commonSpecificRecipeViewController] animated:YES];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[recipeHistory release];
	[homeStoreViewController release];
    [super dealloc];
}


@end

