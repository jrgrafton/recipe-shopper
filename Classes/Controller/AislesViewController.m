//
//  AislesViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "AislesViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "DataManager.h"

@implementation AislesViewController

@synthesize department;
@synthesize shelvesViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	aisles = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[[self navigationItem] setTitle:department];
	
	[aisles removeAllObjects];
	[aisles addObjectsFromArray:[DataManager getAislesForDepartment:department]];
	[aislesView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [aisles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"AisleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* Create a cell for this row's aisle name */
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	[[cell textLabel] setText:[aisles objectAtIndex:[indexPath row]]];
	
	/* add a disclosure indicator so that it looks like you can press it */
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (shelvesViewController == nil) {
		ShelvesViewController *shelvesView = [[ShelvesViewController alloc] initWithNibName:@"ShelvesView" bundle:nil];
		[self setShelvesViewController:shelvesView];
		[shelvesView release];
	}
	
	[shelvesViewController setAisle:[aisles objectAtIndex:[indexPath row]]];
	
	[aislesView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* transition to shelves view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewController] pushViewController:self.shelvesViewController animated:YES];
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

