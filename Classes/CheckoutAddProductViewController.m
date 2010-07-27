//
//  CheckoutAddProductViewController.m
//  RecipeShopper
//
//  Created by User on 7/11/10.
//  Copyright 2010 Asset Enhancing Software Software. All rights reserved.
//

#import "CheckoutAddProductViewController.h"
#import "LogManager.h"
#import "DataManager.h"
#import "DBProduct.h"

@interface CheckoutAddProductViewController ()
//Private class functions
-(void) getProductsMatchingSearchTerm:(NSString*) searchTerm;
-(void) showLoadingOverlay;
-(void) hideLoadingOverlay;
-(void) decreaseCountForProduct:(id)sender;
-(void) increaseCountForProduct:(id)sender;
-(NSInteger) getDesiredProductQuantity:(DBProduct*) product;
-(void) updateTableViewWithProducts:(NSArray*)products;
-(void) fetchNextPage:(id)sender;
@end

@implementation CheckoutAddProductViewController

@synthesize delegate;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View Lifecycle Management

- (void)viewDidLoad {
    [super viewDidLoad];

	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	[[navigationBar topItem] setTitleView: imageView];
	[imageView release];
	
	//Ensure we are the delegate and datasource for the table view
	[productSearchTableView setDelegate:self];
	[productSearchTableView setDataSource:self];
	
	//Set background colour
	[productSearchTableView setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
																green:0.9137254901960784 
																 blue:0.9568627450980392
																alpha:1.0]];
	
	//Add the search bar
	[searchBar setPlaceholder:@"Enter Search Term"];
	[searchBar setDelegate: self];
	[productSearchTableView setTableHeaderView:searchBar];
	[searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
	
	//Initialisations
	currentPage = 1;
	maxPage = 1;
	desiredProductQuantities = [[NSMutableDictionary alloc] initWithCapacity:20];//20 Being the number of items per page
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[searchBar becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	
	//Hide keyboard
	[searchBar resignFirstResponder];
	
	//Blank out found products array
	[foundProducts release];
	foundProducts = [NSArray array];
	[productSearchTableView reloadData];
	
	//Ensure loading overlay is removed
	[self hideLoadingOverlay];
	
	//Current and max page set to 1
	currentPage = 1;
	maxPage = 1;
}

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [foundProducts count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if ([foundProducts count] == 0) {
		return @"";
	}else {
		return [NSString stringWithFormat: @"Search Results (Page %d of %d)",currentPage,maxPage];
	}
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
	return 60;
}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 76;
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (currentPage == maxPage || [foundProducts count] == 0){
		return nil;
	}
	
    if(footerView == nil) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
		
		UIImage *image = [[UIImage imageNamed:@"button_green.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
		//create the button
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setBackgroundImage:image forState:UIControlStateNormal];
		
		//the button should be as big as a table view cell
		[button setFrame:CGRectMake(10, 16, 300, 44)];
		
		//set title, font size and font color
		[button setTitle:@"Next Page" forState:UIControlStateNormal];
		[button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//set action of the button
		[button addTarget:self action:@selector(fetchNextPage:)
		 forControlEvents:UIControlEventTouchUpInside];
		
		//add the button to the view
		[footerView addSubview:button];
		
    }
	
    //return the view for the footer
    return footerView;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	DBProduct *product = [foundProducts objectAtIndex:[indexPath row]];
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
	[minusButton release];
	[plusButton release];
	[countLabel release];
	[priceLabel release];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DBProduct* product = [foundProducts objectAtIndex:[indexPath row]];
	NSInteger count = [[desiredProductQuantities objectForKey:[NSString stringWithFormat:@"%@",[product productBaseID]]] intValue];
	for (int i = 0; i < count; i++) {
		[DataManager addProductToBasket:product];
	}
	
	UIAlertView *productAdded = [[UIAlertView alloc] initWithTitle: @"Product Added" message: @"Product successfully added to basket" delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
	[productAdded show];
	[productAdded release]; 
	
	[productSearchTableView  deselectRowAtIndexPath:indexPath  animated:YES];
}


#pragma mark -
#pragma mark Additional Instance Functions

- (IBAction)actionDone {
	[self.delegate currentViewControllerDidFinish:self];	
}

-(NSInteger) getDesiredProductQuantity:(DBProduct*) product {
	NSString *productKey = [[NSString stringWithFormat:@"%@",[product productBaseID]] retain];
	
	NSNumber *count = [desiredProductQuantities objectForKey:productKey];
	if (count == nil) {
		count = [[[NSNumber alloc] initWithInt:1] autorelease];
		[desiredProductQuantities setValue:count forKey:productKey];
	}
	
	[productKey release];
	return [count intValue];
}

- (void) decreaseCountForProduct:(id)sender {
	NSInteger productBaseID = [sender tag];
	NSString *productKey = [NSString stringWithFormat:@"%d",productBaseID];
	
	NSNumber *count = [desiredProductQuantities objectForKey:productKey];
	if ([count intValue] > 1) {
		count = [NSNumber numberWithInt:[count intValue] - 1];
	}
	
	[desiredProductQuantities setValue:count forKey:productKey];
	
	[productSearchTableView reloadData];
}

- (void) increaseCountForProduct:(id)sender {
	NSInteger productBaseID = [sender tag];
	NSString *productKey = [NSString stringWithFormat:@"%d",productBaseID];
	
	NSNumber *count = [desiredProductQuantities objectForKey:productKey];
	if ([count intValue] < 99) {
		count = [NSNumber numberWithInt:[count intValue] + 1];
	}
	
	[desiredProductQuantities setValue:count forKey:productKey];
	
	[productSearchTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
	//Ensure we remove keyboard
	[searchBar resignFirstResponder];
	
	//Perform search
	[productSearchTableView setScrollEnabled:FALSE];
	[self showLoadingOverlay];
	currentPage = 1;
	[NSThread detachNewThreadSelector: @selector(getProductsMatchingSearchTerm:) toTarget:self withObject:[searchBar text]];
}

-(void)getProductsMatchingSearchTerm:(NSString*) searchTerm{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		NSInteger pageCountHolder = 0;
		NSArray *products = [DataManager fetchProductsMatchingSearchTerm:searchTerm onThisPage:currentPage andGiveMePageCount:&pageCountHolder];
		maxPage = pageCountHolder;
		lastSearchTerm = searchTerm;
		
		if ([products count] == 0) {
			UIAlertView *emptyResults = [[UIAlertView alloc] initWithTitle: @"No Results" message: [NSString stringWithFormat:@"Unable to find any products matching %@",searchTerm] delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
			[emptyResults show];
			[emptyResults release];
			foundProducts = [NSArray array];
		}
		
		[self performSelectorOnMainThread:@selector(updateTableViewWithProducts:) withObject:products waitUntilDone:TRUE];
	}
	@catch (id exception) {
		NSString *msg = [NSString stringWithFormat:@"Exception: '%@'.",exception];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CheckoutAddProductViewController"];
	}
	@finally {
		[pool release];
	}
}

-(void) updateTableViewWithProducts:(NSArray*)products {
	//Retain cause its part of another threads memory pool!!
	foundProducts = [[NSArray arrayWithArray:products] retain];
	[productSearchTableView setContentOffset:CGPointMake(0, 0) animated:NO];
	[productSearchTableView reloadData];	
	[productSearchTableView setScrollEnabled:TRUE];
	[self hideLoadingOverlay];
}

-(void) fetchNextPage:(id)sender {
	if (currentPage < maxPage) {
		[productSearchTableView setScrollEnabled:FALSE];
		[self showLoadingOverlay];
		currentPage++;
		[NSThread detachNewThreadSelector: @selector(getProductsMatchingSearchTerm:) toTarget:self withObject:lastSearchTerm];
	}
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
	[desiredProductQuantities release];
	[loadingView release];
}

@end

