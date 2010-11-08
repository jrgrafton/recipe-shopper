//
//  OnlineShopViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "OnlineShopViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"
#import "UIImage-Extended.h"

@implementation OnlineShopViewController

@synthesize aislesViewController;
@synthesize searchResultsViewController;
@synthesize departments;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		dataManager = [DataManager getInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//initWithNib does not get called when controller is root in navigation stack
	dataManager = [DataManager getInstance];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[onlineShopView setBackgroundColor: [UIColor clearColor]];
	
	departments = nil;
	 
	departmentImages = [[NSDictionary dictionaryWithObjectsAndKeys:
						 [UIImage imageNamed: @"cupboard_icon.png"], @"Food Cupboard", 
						 [UIImage imageNamed: @"fresh_icon.png"], @"Fresh Food",
						 [UIImage imageNamed: @"bakery_icon.png"], @"Bakery",
						 [UIImage imageNamed: @"baby_icon.png"], @"Baby",
						 [UIImage imageNamed: @"health_icon.png"], @"Health & Beauty",
						 [UIImage imageNamed: @"household_icon.png"], @"Household",
						 [UIImage imageNamed: @"home_icon.png"], @"Home & Ents",
						 [UIImage imageNamed: @"frozen_icon.png"], @"Frozen Food",
						 [UIImage imageNamed: @"drinks_icon.png"], @"Drinks",
						 [UIImage imageNamed: @"pets_icon.png"], @"Pets",
						 nil] retain];
}
	 
- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (departments == nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(departmentListFinishedLoading:) name:@"departmentListFinishedLoading" object:nil];
		
		/* If department list has already loaded just fetch cached array in main UI thread */
		if ([dataManager departmentListHasLoaded]) {
			[dataManager getDepartments];
		}else {
			[dataManager showOverlayView:[[self view] window]];
			[dataManager setOverlayLabelText:@"Loading departments"];
			/* We might have tried to load deparment list ahead of time from somewhere else */
			if (![dataManager loadingDepartmentList]) {
				[NSThread detachNewThreadSelector:@selector(getDepartments) toTarget:dataManager withObject:nil];
			}
		}
	}
	
	/* Notification when batch of product images have finished being fetched so we know when to transition */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productImageBatchFetchCompleteNotification) name:@"productImageBatchFetchComplete" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	/* Don't care about notifications unless I am current view controller */
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)departmentListFinishedLoading: (NSNotification *)notification {
	[self setDepartments: [[notification userInfo] objectForKey:@"departmentList"]];
	[onlineShopView reloadData];
	[dataManager hideOverlayView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	/* remove keyboard */
	[searchBar resignFirstResponder];
	
	/* transition to the search results view */
	if (searchResultsViewController == nil) {
		ProductsViewController *searchResultsView = [[ProductsViewController alloc] initWithNibName:@"ProductsView" bundle:nil];
		[self setSearchResultsViewController:searchResultsView];
		[searchResultsView release];
	}
	
	onlineShopView.scrollEnabled = YES;
	[dataManager hideOverlayView];
	
	[searchResultsViewController setCurrentPage:1];
	[searchResultsViewController setProductTerm:[[searchBar text] capitalizedString]];
	[searchResultsViewController setProductViewFor:PRODUCT_SEARCH];
	
	[dataManager showOverlayView:[[self view] window]];
	[dataManager setOverlayLabelText:[NSString stringWithFormat:@"Searching for %@", [searchBar text]]];
	[dataManager showActivityIndicator];
	
	[NSThread detachNewThreadSelector:@selector(searchForProducts) toTarget:self withObject:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
	[dataManager hideOverlayView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[dataManager showOverlayView:onlineShopView];
	[dataManager setOverlayViewOffset:[onlineShopView contentOffset]];
	[dataManager hideActivityIndicator];
	[searchBar setShowsCancelButton:YES animated:YES];
	[onlineShopView setScrollEnabled:NO];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([indexPath row] == 0)? 90:70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [departments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = ([indexPath row] == 0)? @"DepartmentCellHeader":@"DepartmentCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	NSString *departmentName = [departments objectAtIndex:[indexPath row]];

	[UITableViewCellFactory createOnlineShopDepartmentTableCell:&cell withIdentifier:CellIdentifier withDepartmentName:departmentName withIcon:[departmentImages objectForKey:departmentName] isHeader:([indexPath row] == 0)];
	
	if ([indexPath row] == 0) {
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:4];
		[headerLabel setText:@"Produce Categories"];
	}
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (aislesViewController == nil) {
		AislesViewController *aislesView = [[AislesViewController alloc] initWithNibName:@"AislesView" bundle:nil];
		[self setAislesViewController:aislesView];
		[aislesView release];
	}
	
	[aislesViewController setDepartment:[departments objectAtIndex:[indexPath row]]];
	
	[onlineShopView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* transition to aisles view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.aislesViewController animated:YES];
}

#pragma mark -
#pragma mark Private methods

- (void)searchForProducts {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[searchResultsViewController loadProducts];
	[pool release];
}

- (void)productImageBatchFetchCompleteNotification {
	[dataManager hideOverlayView];
	
	/* transition to products view only after we know its completely finished loading */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.searchResultsViewController animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
