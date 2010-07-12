//
//  CheckoutAddProductViewController.m
//  RecipeShopper
//
//  Created by User on 7/11/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import "CheckoutAddProductViewController.h"
#import "LogManager.h"
#import "DataManager.h"
#import "DBProduct.h"

@interface CheckoutAddProductViewController ()
//Private class functions
-(void)getProductsMatchingSearchTerm:(NSString*) searchTerm;
-(void)showLoadingOverlay;
-(void)hideLoadingOverlay;
-(void) decreaseCountForProduct:(id)sender;
-(void) increaseCountForProduct:(id)sender;
-(NSInteger) getDesiredProductQuantity:(DBProduct*) product
-(void)updateTableViewWithProducts:(NSArray*)products 
@end

@implementation CheckoutAddProductViewController

@synthesize delegate;

#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	[[navigationBar topItem] setTitleView: imageView];
	[imageView release];
	
	//Ensure we are the delegate and datasource for the table view
	[productSearchTableView setDelegate:self];
	[productSearchTableView setDataSource:self];
	
	//Add the search bar
	[searchBar setPlaceholder:@"Enter Search Term"];
	[searchBar setDelegate: self];
	[productSearchTableView setTableHeaderView:searchBar];
	[searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
	
	//Initialise found products array
	foundProducts = [NSArray array];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
	//Hide keyboard
	[searchBar resignFirstResponder];
	
	//Blank out found products array
	[foundProducts release];
	foundProducts = [NSArray array];
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

#pragma mark -
#pragma mark General View Functionality

-(void)showLoadingOverlay{
	loadingView = [LoadingView loadingViewInView:(UIView *)productSearchTableView withText:@"Finding Products..." 
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


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
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
	NSArray *productBasket = [DataManager getProductBasket];
	DBProduct *product = [productBasket objectAtIndex:[indexPath row]];
	[[cell textLabel] setNumberOfLines:2];
	[[cell textLabel] setText: [product productName]];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:10]];
	[[cell imageView] setImage: [product productIcon]];
	
	
	//Create the accessoryView for everything to be inserted into
	UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,126,54)];
	
	//Minus button
	UIButton *minusButton  = [[UIButton alloc] initWithFrame:CGRectMake(0,6,44,44)];
	[minusButton setTag:[[product productBaseID] intValue]];
	[minusButton addTarget:self action:@selector(decreaseCountForProduct:) forControlEvents:UIControlEventTouchUpInside];
	UIImage *minusImage = [UIImage imageNamed:@"button_minus.png"];
	[minusButton setImage:minusImage forState:UIControlStateNormal];
	
	//Count label
	UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(37,0,13,54)];
	NSInteger productQuantity = [self getDesiredProductQuantity:product];
	
	[countLabel setText:[NSString stringWithFormat:@"%d", productQuantity]];
	[countLabel setFont:[UIFont boldSystemFontOfSize:11]];
	[countLabel setTextAlignment: UITextAlignmentCenter];
	
	//Plus button
	UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(43,6,44,44)];
	[plusButton setTag:[[product productBaseID] intValue]];
	[plusButton addTarget:self action:@selector(increaseCountForProduct:) forControlEvents:UIControlEventTouchUpInside];
	UIImage *plusImage = [UIImage imageNamed:@"button_plus.png"];
	[plusButton setBackgroundImage:plusImage forState:UIControlStateNormal];
	
	//Price label
	UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,0,42,54)];
	[priceLabel setText:[NSString stringWithFormat:@"£%.2f", ([[product productPrice] floatValue] * productQuantity)]];
	[priceLabel setFont:[UIFont boldSystemFontOfSize:11]];
	[priceLabel setTextAlignment: UITextAlignmentRight];
	
	//Add everything to accessory view
	[accessoryView addSubview:minusButton];
	[accessoryView addSubview:plusButton];
	[accessoryView addSubview:countLabel];
	[accessoryView addSubview:priceLabel];
	
	//Ensure count label is in front of button
	[accessoryView bringSubviewToFront:countLabel];
	
	//Finally add accessory view itself
	[cell setAccessoryView:accessoryView];
	[accessoryView release];
    
    return cell;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
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

#pragma mark -
#pragma action management

- (IBAction)actionDone {
	[self.delegate currentViewControllerDidFinish:self];	
}

-(NSInteger) getDesiredProductQuantity:(DBProduct*) product {
	NSString *productKey = [NSString stringWithFormat:@"%@",[product productBaseID]];
	
	NSNumber *count = [desiredProductQuantities objectForKey:productKey];
	if (count == nil) {
		count = [NSNumber numberWithInt:1];
		[desiredProductQuantities setValue:count forKey:productKey];
	}
	
	return count;
}

- (void) decreaseCountForProduct:(id)sender {
	NSInteger productBaseID = [sender tag];
	NSString *productKey = [NSString stringWithFormat:@"%d",productBaseID];
	
	NSNumber *count = [desiredProductQuantities objectForKey:productKey];
	if ([count intValue] > 1) {
		count = [NSNumber numberWithInt:[[count intValue] - 1]];
	}
	
	[desiredProductQuantities setValue:count forKey:productKey];
	
	[self.tableView reloadData];
}

- (void) increaseCountForProduct:(id)sender {
	NSInteger productBaseID = [sender tag];
	NSString *productKey = [NSString stringWithFormat:@"%d",productBaseID];
	
	NSNumber *count = [desiredProductQuantities objectForKey:productKey];
	if ([count intValue] < 99) {
		count = [NSNumber numberWithInt:[[count intValue] + 1]];
	}
	
	[desiredProductQuantities setValue:count forKey:productKey];
	
	[self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	//Ensure we remove keyboard
	[searchBar resignFirstResponder];
	
	//Perform search
	[productSearchTableView setScrollEnabled:FALSE];
	[self showLoadingOverlay];
	[NSThread detachNewThreadSelector: @selector(getProductsMatchingSearchTerm:) toTarget:self withObject:[searchBar text]];
	
}

-(void)getProductsMatchingSearchTerm:(NSString*) searchTerm{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSInteger pageCountHolder = 0;
		NSArray products = [DataManager fetchProductsMatchingSearchTerm:searchTerm onThisPage:1 andGiveMePageCount:&pageCountHolder];
		
		if ([products count] == 0) {
			UIAlertView *emptyResults = [[UIAlertView alloc] initWithTitle: @"No Results" message: [NSString stringWithFormat:@"Unable to find any products matching %@",searchTerm] delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
			[emptyResults show];
			[emptyResults release];
			closestStores = [NSArray array];
		}
		
		[self performSelectorOnMainThread:@selector(updateTableViewWithProducts:) withObject:stores waitUntilDone:TRUE];
	}
	@catch (id exception) {
		NSString *msg = [NSString stringWithFormat:@"Exception: '%@'.",exception];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CheckoutAddProductViewController"];
	}
	@finally {
		[pool release];
	}
}

-(void)updateTableViewWithProducts:(NSArray*)products {
	//Retain cause its part of another threads memory pool!!
	closestStores = [[NSArray arrayWithArray:stores] retain];
	[self.tableView reloadData];	
	[self.tableView setScrollEnabled:TRUE];
	[self hideLoadingOverlay];
}

@end

