//
//  HomeStoreTableViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "HomeStoreTableViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "AllViewsNavController.h"
#import "DataManager.h"
#import "LoadingView.h"
#import "HTTPStore.h"
#import "LogManager.h"

@interface HomeStoreTableViewController ()
//Private class functions
-(void)getClosestStoresToCurrentLocation;
-(void)getClosestStoresToSearchLocation:(NSString*) location;
-(void)showLoadingOverlay;
-(void)hideLoadingOverlay;
@end

@implementation HomeStoreTableViewController

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
	
	//Add UISegmentedControl for nearest and search
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Nearest",@"Search",nil]];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 200, 30);
	segmentedControl.selectedSegmentIndex = 0;
	
	[segmentedControl addTarget:self
	                    action:@selector(segmentButtonPressed:)
	           forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView = segmentedControl;
	
	[segmentedControl release];
}

-(void)showLoadingOverlay{
	loadingView = [LoadingView loadingViewInView:(UIView *)[self tableView] withText:@"Finding Stores..." 
								 andFont:[UIFont systemFontOfSize:16.0f] andFontColor:[UIColor grayColor]
								 andCornerRadius:0 andBackgroundColor:[UIColor colorWithRed:1.0 
																					  green:1.0 
																					   blue:1.0
																					  alpha:1.0]
								 andDrawStroke:FALSE];
}

-(void)hideLoadingOverlay{
	if(loadingView != nil){
		[loadingView removeView];
		loadingView = nil;
	}
}

- (void) segmentButtonPressed:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	if ([segmentedControl selectedSegmentIndex] == 0) {
		//If we are already searching ensure that tab selection stays where it was
		if (busyFetchingClosestStores){
			[segmentedControl setSelectedSegmentIndex:1];
			return;
		}
		//Ensure we remove search bar
		[searchBar resignFirstResponder];
		self.tableView.tableHeaderView = nil;
		
		//Nearest selected
		[segmentedControl setSelectedSegmentIndex:0];
		busyFetchingClosestStores = TRUE;
		[self showLoadingOverlay];
		
		[NSThread detachNewThreadSelector: @selector(getClosestStoresToCurrentLocation) toTarget:self withObject:nil];
		[self.tableView setScrollEnabled:FALSE];
		
	}else{
		//If we are already searching ensure that tab selection stays where it was
		if (busyFetchingClosestStores){
			[segmentedControl setSelectedSegmentIndex:0];
			return;
		}
		//Search selected
		[segmentedControl setSelectedSegmentIndex:1];
		
		//Add the search bar
		[searchBar setPlaceholder:@"Enter Town/City or Postcode"];
		self.tableView.tableHeaderView = searchBar;
		searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	}
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	//Ensure we remove keyboard
	[searchBar resignFirstResponder];
	
	//self.tableView.tableHeaderView = nil;
	
	//Perform search
	[self.tableView setScrollEnabled:FALSE];
	[self showLoadingOverlay];
	[NSThread detachNewThreadSelector: @selector(getClosestStoresToSearchLocation:) toTarget:self withObject:[searchBar text]];
	
}

-(void)getClosestStoresToSearchLocation:(NSString*) address{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSArray *coords = [DataManager fetchGeolocationFromAddress:address];
		if (coords == nil || [coords count] == 0) {
			//Update table view with blank stores array
			[self performSelectorOnMainThread:@selector(updateTableViewWithStores:) withObject:[NSArray array] waitUntilDone:TRUE];
		}else{
			NSArray *stores = [DataManager fetchClosestStoresToGeolocation:coords andReturnUpToThisMany:15];
			[self performSelectorOnMainThread:@selector(updateTableViewWithStores:) withObject:stores waitUntilDone:TRUE];
		}
		busyFetchingClosestStores = FALSE;
	}
	@catch (id exception) {
		NSString *msg = [NSString stringWithFormat:@"Exception: '%@'.",exception];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"HomeStoreTableViewController"];
	}
	@finally {
		[pool release];
	}
}

-(void)getClosestStoresToCurrentLocation {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSArray *coords = [DataManager getCurrentLatitudeLongitude];
		if (coords == nil) {
			UIAlertView *gpsError = [[UIAlertView alloc] initWithTitle: @"GPS error" message: @"Unable to determine current position" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
			[gpsError show];
			[gpsError release];
			
			//Update table view with blank array
			[self performSelectorOnMainThread:@selector(updateTableViewWithStores:) withObject:[NSArray array] waitUntilDone:TRUE];
		}else{
			NSArray *stores = [DataManager fetchClosestStoresToGeolocation:coords andReturnUpToThisMany:15];
			[self performSelectorOnMainThread:@selector(updateTableViewWithStores:) withObject:stores waitUntilDone:TRUE];
		}
		busyFetchingClosestStores = FALSE;
	}
	@catch (id exception) {
		NSString *msg = [NSString stringWithFormat:@"Exception: '%@'.",exception];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"HomeStoreTableViewController"];
	}
	@finally {
		[pool release];
	}
}

-(void)updateTableViewWithStores:(NSArray*)stores {
	//Retain cause its part of another threads memory pool!!
	if ([stores count] == 0) {
		UIAlertView *locateError = [[UIAlertView alloc] initWithTitle: @"Sorry" message: @"I can't find any stores near this location. Please try searching again" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[locateError show];
		[locateError release];
	}else{
		closestStores = [[NSArray arrayWithArray:stores] retain];
		[self.tableView reloadData];	
	}
	
	[self.tableView setScrollEnabled:TRUE];
	[self hideLoadingOverlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	//Set up initial view
	busyFetchingClosestStores = TRUE;
	
	//Fetch closest stores to populate view
	[self showLoadingOverlay];
	[self.tableView setScrollEnabled:FALSE];
	[NSThread detachNewThreadSelector: @selector(getClosestStoresToCurrentLocation) toTarget:self withObject:nil];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

/*- (void)viewWillDisappear:(BOOL)animated {	
	[super viewWillDisappear:animated];
}*/


- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[searchBar resignFirstResponder];
	UISegmentedControl *segmentedControl = (UISegmentedControl*) self.navigationItem.titleView;
	segmentedControl.selectedSegmentIndex = 0;
	
	//Blank out closest stores array
	[closestStores release];
	closestStores = [NSArray array];
	[self.tableView reloadData];
	
	//Ensure loading overlay is removed
	[self hideLoadingOverlay];
}

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
    return [closestStores count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
    // Set up the cell...
	
	//List of recent recipes
	HTTPStore *storeObject = [closestStores objectAtIndex:[indexPath row]];
	
	[[cell textLabel] setText: [storeObject storeName]];
	[[cell textLabel] setFont: [UIFont systemFontOfSize:13]];
	
	[[cell imageView] setImage: nil];
	UILabel *distLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,70,40)];
	[distLabel setText:[NSString stringWithFormat:@"%@ miles", [storeObject storeDistanceFromCurrentLocation]]];
	[distLabel setFont:[UIFont boldSystemFontOfSize:11]];
	
	[cell setAccessoryView:distLabel];
	[distLabel release];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Insert new user preference for store
	HTTPStore *storeObject = [closestStores objectAtIndex:[indexPath row]];
	[DataManager putUserPreference:@"home.store" andValue:[storeObject storeName]];
	[DataManager putUserPreference:@"home.id"  andValue: [NSString stringWithFormat:@"%d", [storeObject storeID]]];
	
	//Get rid of this view
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewNavController] popViewControllerAnimated:TRUE];
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
    [super dealloc];
}


@end

