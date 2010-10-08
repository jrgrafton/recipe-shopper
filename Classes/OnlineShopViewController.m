//
//  OnlineShopViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "OnlineShopViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"
#import "UIImage-Extended.h"

#define DEPARTMENTNAME_TAG 1
#define DEPARTMENTIMAGE_TAG 2

@interface OnlineShopViewController()

- (void)transitionToSearchResults:(NSString *)searchTerm;
- (void)transitionToBasketView;

@end

@implementation OnlineShopViewController

@synthesize aislesViewController;
@synthesize onlineBasketViewController;
@synthesize searchResultsViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	departments = [[DataManager getDepartments] retain];

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
	
	letUserSelectRow = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	/* remove keyboard */
	[searchBar resignFirstResponder];
	[NSThread detachNewThreadSelector:@selector(transitionToSearchResults:) toTarget:self withObject:[searchBar text]];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	/* add the overlay view */
	[DataManager hideActivityIndicator];
	[DataManager showOverlayView];
	
	letUserSelectRow = NO;
	[onlineShopView setScrollEnabled:NO];
}

- (void)overlayViewTouched {
	searchBarView.text = @"";
	[searchBarView resignFirstResponder];
	
	letUserSelectRow = YES;
	onlineShopView.scrollEnabled = YES;
	
	[DataManager hideOverlayView];
	
	[onlineShopView reloadData];
}

- (void)transitionToSearchResults:(NSString *)searchTerm {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* transition to the search results view */
	if (searchResultsViewController == nil) {
		SearchResultsViewController *searchResultsView = [[SearchResultsViewController alloc] initWithNibName:@"SearchResultsView" bundle:nil];
		[self setSearchResultsViewController:searchResultsView];
		[searchResultsView release];
	}
	
	[self overlayViewTouched];
	
	[searchResultsViewController setSearchTerm:searchTerm];
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.searchResultsViewController animated:YES];
	
	[pool release];
}

- (void)transitionToBasketView {
	/* transition to the basket view */
	if (onlineBasketViewController == nil) {
		OnlineBasketViewController *onlineBasketView = [[OnlineBasketViewController alloc] initWithNibName:@"OnlineBasketView" bundle:nil];
		[self setOnlineBasketViewController:onlineBasketView];
		[onlineBasketView release];
	}
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.onlineBasketViewController animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [departments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"DepartmentCell";
    UILabel *departmentNameLabel;
	UIImageView *departmentImage;
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* Create a cell for this row's department name */
	if (cell == nil) {
		/* load the product view cell nib */
        NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"DepartmentCell" owner:self options:nil];
		
        for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				cell = (UITableViewCell *)viewElement;
		}
	}
	
	NSString *departmentName = [departments objectAtIndex:[indexPath row]];
	
	departmentNameLabel = (UILabel *)[cell viewWithTag:DEPARTMENTNAME_TAG];
    [departmentNameLabel setText:departmentName];

	departmentImage = (UIImageView *)[cell viewWithTag:DEPARTMENTIMAGE_TAG];
	[departmentImage setImage:[departmentImages objectForKey:departmentName]];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (letUserSelectRow == YES) {
		return indexPath;
	} else {
		return nil;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (aislesViewController == nil) {
		AislesViewController *aislesView = [[AislesViewController alloc] initWithNibName:@"AislesView" bundle:nil];
		[self setAislesViewController:aislesView];
		[aislesView release];
	}
	
	[aislesViewController loadAislesForDepartment:[departments objectAtIndex:[indexPath row]]];
	
	[onlineShopView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* transition to aisles view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.aislesViewController animated:YES];
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
