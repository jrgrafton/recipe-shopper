//
//  CheckoutRecipeBasketViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 6/11/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "CheckoutRecipeBasketViewController.h"
#import "DataManager.h"
#import "RecipeShopperAppDelegate.h"


@implementation CheckoutRecipeBasketViewController

@synthesize commonSpecificRecipeViewController;

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
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	
	//Set background colour
	[recipeBasketTableView setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
														   green:0.9137254901960784 
															blue:0.9568627450980392
														   alpha:1.0]];
	
	self.title = NSLocalizedString(@"Checkout", @"Checkout your recipes");
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager getRecipeBasket] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"Recipe List";
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	NSMutableArray *recipeBasket = [DataManager getRecipeBasket];
	
	DBRecipe *recipeObject = [recipeBasket objectAtIndex:[indexPath row]];
	[[cell textLabel] setText: [recipeObject recipeName]];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
	[[cell imageView] setImage: [recipeObject iconSmall]];
	cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
	
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Open specific recipe view
	if (commonSpecificRecipeViewController == nil) {
		CommonSpecificRecipeViewController *specificRecipeView = [[CommonSpecificRecipeViewController alloc] initWithNibName:@"CommonSpecificRecipeView" bundle:nil];
		[self setCommonSpecificRecipeViewController: specificRecipeView];
		[specificRecipeView release];
	}
	[recipeBasketTableView  deselectRowAtIndexPath:indexPath  animated:YES];
	[commonSpecificRecipeViewController processViewForRecipe:[[DataManager getRecipeBasket] objectAtIndex:[indexPath row]]];
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewNavController] pushViewController:commonSpecificRecipeViewController animated:YES];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[[DataManager getRecipeBasket] removeObjectAtIndex:[indexPath row]];
		
		//Decrement badge number
		RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		UITabBarController *rootController = [appDelegate rootController];
		[[rootController.tabBar.items objectAtIndex:2] setBadgeValue: [NSString stringWithFormat:@"%d",[DataManager getRecipeBasketSize]]];
		
		if ([DataManager getRecipeBasketSize] == 0) {
			[[rootController.tabBar.items objectAtIndex:2] setBadgeValue: NULL];
		}
		
		
		// Delete row from table view
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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
    [super dealloc];
}


@end

