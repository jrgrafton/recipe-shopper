//
//  HomeStoreTableViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HomeStoreTableViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "HomeViewNavController.h"
#import "DataManager.h"
#import "LoadingView.h"
#import "HTTPStore.h"

@interface HomeStoreTableViewController ()
//Private class functions
-(void)getClosestStoresToCurrentLocation;
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
	
	//Set up initial view
	busyFetchingClosestStores = TRUE;
	
	//Fetch closest stores to populate view
	loadingView = [LoadingView loadingViewInView:(UIView *)[self tableView] withText:@"Finding Stores..." 
							   andFont:[UIFont systemFontOfSize:16.0f] andFontColor:[UIColor grayColor]
							   andCornerRadius:0 andBackgroundColor:[UIColor colorWithRed:1.0 
																					  green:1.0 
																					   blue:1.0
																					  alpha:1.0]
								andDrawStroke:FALSE];
	self.tableView.scrollEnabled = FALSE;
	[NSThread detachNewThreadSelector: @selector(getClosestStoresToCurrentLocation) toTarget:self withObject:nil];
}

- (void) segmentButtonPressed:(id)sender{
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	if ([segmentedControl selectedSegmentIndex] == 0) {
		//Nearest selected
		[segmentedControl setSelectedSegmentIndex:0];
		
		if (!busyFetchingClosestStores){
			loadingView = [LoadingView loadingViewInView:(UIView *)[self tableView] withText:@"Finding Stores..." 
												 andFont:[UIFont systemFontOfSize:16.0f] andFontColor:[UIColor grayColor]
												 andCornerRadius:0 andBackgroundColor:[UIColor colorWithRed:1.0 
																							  green:1.0 
																							   blue:1.0
																							  alpha:1.0]
												 andDrawStroke:FALSE];
			
			[NSThread detachNewThreadSelector: @selector(getClosestStoresToCurrentLocation) toTarget:self withObject:nil];
			self.tableView.scrollEnabled = FALSE;
		}
		
	}else{
		//Search selected
		[segmentedControl setSelectedSegmentIndex:1];
	}
}

-(void)getClosestStoresToCurrentLocation {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSArray *coords = [DataManager getCurrentLatitudeLongitude];
		NSArray *stores = [DataManager fetchClosestStores:coords andReturnUpToThisMany:15];
		[self performSelectorOnMainThread:@selector(updateTableViewWithStores:) withObject:stores waitUntilDone:TRUE];
		busyFetchingClosestStores = FALSE;
	}
	@catch (id exception) {
		NSLog(@"%@", exception);
	}
	@finally {
		[pool release];
	}
}

-(void)updateTableViewWithStores:(NSArray*)stores {
	//Build rows from result
	

	self.tableView.scrollEnabled = TRUE;
	if(loadingView != nil){
		[loadingView removeView];
		loadingView = nil;
	}
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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

