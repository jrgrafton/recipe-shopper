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

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Home", @"Local store and recent recipe list");
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	
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

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


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
		[commonSpecificRecipeViewController processViewForRecipe:[[self recipeHistory] objectAtIndex:[indexPath row]]];
		
		RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[[appDelegate homeViewNavController] pushViewController:[self commonSpecificRecipeViewController] animated:YES];
	}
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[recipeHistory release];
	[HomeStoreViewController release];
    [super dealloc];
}


@end

