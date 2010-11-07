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

@interface ShelvesViewController()

- (void)loadProducts:(NSString *)shelf;

@end

@implementation ShelvesViewController

@synthesize productsViewController;
@synthesize aisle;

#pragma mark -
#pragma mark View lifecycle

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
	
	[shelvesView setBackgroundColor: [UIColor clearColor]];
	
	shelves = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[shelves removeAllObjects];
	[shelves addObjectsFromArray:[dataManager getShelvesForAisle:aisle]];
	
	if ([shelves count] == 0) {
		/* just pop up a window to say so */
		UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"Online Shop" message:[NSString stringWithFormat:@"No results found for '%@'", aisle] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noResultsAlert show];
		[noResultsAlert release];
	}
	
	[shelvesView reloadData];
	
	/* Notification when batch of product images have finished being fetched so we know when to transition */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productImageBatchFetchCompleteNotification) name:@"productImageBatchFetchComplete" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	/* Don't care about notifications unless I am current view controller */
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
	
	[dataManager showOverlayView:[[self view] window]];
	[dataManager setOverlayLabelText:[NSString stringWithFormat:@"Downloading %@", [shelves objectAtIndex:[indexPath row]]]];
	[dataManager showActivityIndicator];
	
	[NSThread detachNewThreadSelector:@selector(loadProducts:) toTarget:self withObject:[shelves objectAtIndex:[indexPath row]]];
}

#pragma mark -
#pragma mark Private methods

- (void)loadProducts:(NSString *)shelf {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[productsViewController setCurrentPage:1];
	[productsViewController setProductShelf:shelf];
	[productsViewController loadProducts];
	
	[pool release];
}

- (void)productImageBatchFetchCompleteNotification {
	/* transition to products view only after we know its completely finished loading */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
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

