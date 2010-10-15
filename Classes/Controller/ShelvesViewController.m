//
//  OnlineShopShelvesViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ShelvesViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"

@implementation ShelvesViewController

@synthesize productsViewController;
@synthesize aisle;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	shelves = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[self navigationItem] setTitle:aisle];
	
	[shelves removeAllObjects];
	[shelves addObjectsFromArray:[DataManager getShelvesForAisle:aisle]];
	[shelvesView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [shelves count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShelfCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* Create a cell for this row's shelf name */
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	[[cell textLabel] setText:[shelves objectAtIndex:[indexPath row]]];
	
	/* add a disclosure indicator so that it looks like you can press it */
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (productsViewController == nil) {
		ProductsViewController *productsView = [[ProductsViewController alloc] initWithNibName:@"ProductsView" bundle:nil];
		[self setProductsViewController:productsView];
		[productsView release];
	}
	
	[productsViewController setShelf:[shelves objectAtIndex:[indexPath row]]];
	
	/* make sure the list is scrolled to the top */
	//[productsViewController.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	[shelvesView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* transition to products view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.productsViewController animated:YES];
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
}


@end

