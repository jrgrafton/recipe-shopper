//
//  AislesViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "AislesViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"
#import "DataManager.h"

@implementation AislesViewController

@synthesize department;
@synthesize shelvesViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[aislesView setBackgroundColor: [UIColor clearColor]];
	
	aisles = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//[[self navigationItem] setTitle:department];
	
	[aisles removeAllObjects];
	[aisles addObjectsFromArray:[DataManager getAislesForDepartment:department]];
	
	if ([aisles count] == 0) {
		/* just pop up a window to say so */
		UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"Online Shop" message:[NSString stringWithFormat:@"No results found for '%@'", department] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noResultsAlert show];
		[noResultsAlert release];
	}
	
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([indexPath row] == 0)? 64:44; 
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = ([indexPath row] == 0)? @"AisleCellHeader":@"AisleCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	[UITableViewCellFactory createOnlineShopAisleTableCell:&cell withIdentifier:CellIdentifier withAisleName:[aisles objectAtIndex:[indexPath row]] isHeader:([indexPath row] == 0)];
	
	if ([indexPath row] == 0) {
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:3];
		[headerLabel setText: [self department]];
	}
	
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
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
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

