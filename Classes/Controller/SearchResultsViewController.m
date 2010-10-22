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
#import "DataManager.h"
#import "RecipeShopperAppDelegate.h"

@interface SearchResultsViewController()

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
}

- (void)newSearch {
	searchResults = [[NSMutableArray alloc] init];
	currentPage = 1;
	[searchResults removeAllObjects];
	[searchBarView setText:searchTerm];
	
	//[[self navigationItem] setTitle:searchTerm];
	
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
	
	[DataManager showOverlayView:[[self view] window]];
	[DataManager setOverlayLabelText:[NSString stringWithFormat:@"Searching for %@", searchTerm]];
	[DataManager showActivityIndicator];
	[NSThread detachNewThreadSelector:@selector(searchForProducts) toTarget:self withObject:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchResultsView setScrollEnabled:YES];
	
	[DataManager hideOverlayView];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[DataManager showOverlayView:searchResultsView];
	[DataManager setOverlayViewOffset:[searchResultsView contentOffset]];
	[DataManager hideActivityIndicator];
	[searchBar setShowsCancelButton:YES animated:YES];
	[searchResultsView setScrollEnabled:NO];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (currentPage >= totalPageCount) {
		return [searchResults count];
	} else if ([searchResults count] != 0) {
		return [searchResults count] + 1;
	} else {
		return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == [searchResults count]) {
		static NSString *CellIdentifier = @"MoreSearchResultsCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
				
		/* create a cell for loading more search results */
		if (cell == nil) {
			NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"MoreSearchResultsCell" owner:self options:nil];
			
			for (id viewElement in bundle) {
				if ([viewElement isKindOfClass:[UITableViewCell class]])
					cell = (UITableViewCell *)viewElement;
			}
		}
		
		return cell;
	} else {
		static NSString *CellIdentifier = @"SearchResultCell";
		
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		/* create a cell for this row's product */
		Product *product = [searchResults objectAtIndex:[indexPath row]];
		NSNumber *quantity = [DataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([buttons count] > 1) {
			[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		return cell;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == [searchResults count]) {
		currentPage++;
		[DataManager showOverlayView:searchResultsView];
		[DataManager setOverlayViewOffset:[searchResultsView contentOffset]];
		[DataManager setOverlayLabelText:[NSString stringWithFormat:@"Fetching page %d of %d", currentPage, totalPageCount]];
		[DataManager showActivityIndicator];		
		[NSThread detachNewThreadSelector:@selector(searchForProducts) toTarget:self withObject:nil];
	}
}

#pragma mark -
#pragma mark Private methods

- (void)searchForProducts {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSArray *results = [DataManager searchForProducts:[self searchTerm] onPage:currentPage totalPageCountHolder:&totalPageCount];
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
	[DataManager hideOverlayView];
	
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
			[DataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:1]];
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
			[DataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:-1]];
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

