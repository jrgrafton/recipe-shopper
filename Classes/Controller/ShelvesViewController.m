//
//  OnlineShopShelvesViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ShelvesViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"
#import "DataManager.h"

@interface ShelvesViewController()

- (void)loadProducts:(NSString *)shelf;

@end

@implementation ShelvesViewController

@synthesize productsViewController;
@synthesize aisle;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[shelvesView setBackgroundColor: [UIColor clearColor]];
	
	shelves = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[shelves removeAllObjects];
	[shelves addObjectsFromArray:[DataManager getShelvesForAisle:aisle]];
	
	if ([shelves count] == 0) {
		/* just pop up a window to say so */
		UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"Online Shop" message:[NSString stringWithFormat:@"No results found for '%@'", aisle] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noResultsAlert show];
		[noResultsAlert release];
	}
	
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
	NSString *CellIdentifier = ([indexPath row] == 0)? @"ShelvesCellHeader":@"ShelvesCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[UITableViewCellFactory createOnlineShopShelfTableCell:&cell withIdentifier:CellIdentifier withShelfName:[shelves objectAtIndex:[indexPath row]] isHeader:([indexPath row] == 0)];
	
	if ([indexPath row] == 0) {
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:3];
		[headerLabel setText:[self aisle]];
	}
	
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([indexPath row] == 0)? 64:44; 
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (productsViewController == nil) {
		ProductsViewController *productsView = [[ProductsViewController alloc] initWithNibName:@"ProductsView" bundle:nil];
		[productsView setProductShelf:[shelves objectAtIndex:[indexPath row]]];
		[self setProductsViewController:productsView];
		[productsView release];
	}
	
	[DataManager showOverlayView:[[self view] window]];
	[DataManager setOverlayLabelText:[NSString stringWithFormat:@"Downloading %@", [shelves objectAtIndex:[indexPath row]]]];
	[DataManager showActivityIndicator];
	
	[NSThread detachNewThreadSelector:@selector(loadProducts:) toTarget:self withObject:[shelves objectAtIndex:[indexPath row]]];
}

#pragma mark -
#pragma mark Private methods

- (void)loadProducts:(NSString *)shelf {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[productsViewController loadProducts:shelf];
	
	/* transition to products view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.productsViewController animated:YES];
	
	[pool release];
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

