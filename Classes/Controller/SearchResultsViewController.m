//
//  SearchResultsViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "Product.h"
#import "UITableViewCellFactory.h"
#import "RecipeShopperAppDelegate.h"

@interface SearchResultsViewController()

- (void)fetchMoreProducts;
- (void)searchForProducts;

@end

@implementation SearchResultsViewController

@synthesize searchTerm;

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[searchResultsView setBackgroundColor: [UIColor clearColor]];
	
	/* prevent the rows from being selected */
	[searchResultsView setAllowsSelection:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[searchResultsView reloadData];
}

- (void)newSearch {
	searchResults = [[NSMutableArray alloc] init];
	currentPage = 1;
	[searchResults removeAllObjects];
	[searchBarView setText:searchTerm];
	
	[self searchForProducts];
}

#pragma mark -
#pragma mark Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchResultsView setScrollEnabled:YES];
	
	currentPage = 1;
	[searchResults removeAllObjects];
	[self setSearchTerm:[searchBar text]];
	
	[dataManager showOverlayView:[[self view] window]];
	[dataManager setOverlayLabelText:[NSString stringWithFormat:@"Searching for %@", searchTerm]];
	[dataManager showActivityIndicator];
	[NSThread detachNewThreadSelector:@selector(searchForProducts) toTarget:self withObject:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchResultsView setScrollEnabled:YES];
	
	[dataManager hideOverlayView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[dataManager showOverlayView:searchResultsView];
	[dataManager setOverlayViewOffset:[searchResultsView contentOffset]];
	[dataManager hideActivityIndicator];
	[searchBar setShowsCancelButton:YES animated:YES];
	[searchResultsView setScrollEnabled:NO];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([indexPath row] == 0)? 135:120;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return (currentPage < totalPageCount)? 90:0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if(footerView == nil) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
		
		UIImage *image = [[UIImage imageNamed:@"fetchMore.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
		//create the button
		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 300, 67)];
		[button setBackgroundImage:image forState:UIControlStateNormal];

		//set action of the button
		[button addTarget:self action:@selector(fetchMoreProducts)
		 forControlEvents:UIControlEventTouchUpInside];
		
		//add the button to the view
		[footerView addSubview:button];
		[button release];
    }
	
    //return the view for the footer
    return (currentPage < totalPageCount)? footerView:nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = ([indexPath row] == 0)? @"SearchResultCellHeader":@"SearchResultCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* create a cell for this row's product */
	Product *product = [searchResults objectAtIndex:[indexPath row]];
	NSNumber *quantity = [dataManager getProductQuantityFromBasket:product];
	NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO isHeader:([indexPath row] == 0)];

	[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([buttons count] > 1) {
		[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if ([indexPath row] == 0) {
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:[[self searchTerm] capitalizedString]];
	}
	
	return cell;
}

#pragma mark -
#pragma mark Private methods

- (void)fetchMoreProducts {
	currentPage++;
	[dataManager showOverlayView:searchResultsView];
	[dataManager setOverlayViewOffset:[searchResultsView contentOffset]];
	[dataManager setOverlayLabelText:[NSString stringWithFormat:@"Fetching page %d of %d", currentPage, totalPageCount]];
	[dataManager showActivityIndicator];		
	[NSThread detachNewThreadSelector:@selector(searchForProducts) toTarget:self withObject:nil];
}

- (void)searchForProducts {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *results = [dataManager searchForProducts:[self searchTerm] onPage:currentPage totalPageCountHolder:&totalPageCount];
	[searchResults addObjectsFromArray:results];
	
	if ([searchResults count] == 0) {
		/* just pop up a window to say so */
		UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"Search results" message:[NSString stringWithFormat:@"No results found for '%@'", searchTerm] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noResultsAlert show];
		[noResultsAlert release];
	}
	
	if (currentPage == 1) {
		/* scroll the search results to the top */
		[searchResultsView setContentOffset:CGPointMake(0, 0) animated:NO];
	}
	
	[searchResultsView reloadData];
	[dataManager hideOverlayView];
	
	[pool release];
}

/*
 * Add this cell's product (identified by the tag of the sender, which will be the product ID)
 * to both the product basket and the online basket
 */
- (void)addProductButtonClicked:(id)sender {
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	NSEnumerator *productsEnumerator = [searchResults objectEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productBaseID] intValue] == [productBaseID intValue]) {
			/* we've found the product that relates to this product ID so increase its quantity in the basket */
			[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:1]];
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[searchResultsView reloadData];
}

/*
 * Remove this cell's product (identified by the tag of the sender, which will be the product ID)
 * from both the product basket and the online basket
 */
- (void)removeProductButtonClicked:(id)sender {
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	NSEnumerator *productsEnumerator = [searchResults objectEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productBaseID] intValue] == [productBaseID intValue]) {
			/* we've found the product that relates to this product ID so decrease its quantity in the basket */
			[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:-1]];
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[searchResultsView reloadData];
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

