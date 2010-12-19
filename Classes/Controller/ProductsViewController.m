//
//  ProductsViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ProductsViewController.h"
#import "Product.h"
#import "UITableViewCellFactory.h"
#import "LogManager.h"

@interface ProductsViewController()

- (void)plusProductButtonClicked:(id)sender;
- (void)minusProductButtonClicked:(id)sender;
- (void)fetchMoreProducts;
- (void)productImageBatchFetchCompleteNotification;

@end

@implementation ProductsViewController

@synthesize productTerm;
@synthesize currentPage;
@synthesize productViewFor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		dataManager = [DataManager getInstance];
		products = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed:@"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[productsView setBackgroundColor:[UIColor clearColor]];
	
	[productsView setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[productsView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	/* Notification when batch of product images have finished being fetched */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productImageBatchFetchCompleteNotification) name:@"productImageBatchFetchComplete" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
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
    return [products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = ([indexPath row] == 0)? @"ProductCellHeader":[NSString stringWithFormat:@"ProductCell%i",[indexPath row]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	/* Create a cell for this row's product */
	Product *product = [products objectAtIndex:[indexPath row]];
	
	NSNumber *quantity = [dataManager getProductQuantityFromBasket:product];
	NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO isProductUnavailableCell:NO isHeader:([indexPath row] == 0)];
	
	[[buttons objectAtIndex:0] addTarget:self action:@selector(plusProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([buttons count] > 1) {
		[[buttons objectAtIndex:1] addTarget:self action:@selector(minusProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if ([indexPath row] == 0) {
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:[self productTerm]];
	}
	
	return cell;
}

#pragma mark -
#pragma mark private methods

- (void)loadProducts {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (currentPage == 1) {
		[products removeAllObjects];
	}
	
	NSArray *result = [NSArray array];
	
	switch (productViewFor) {
		case PRODUCT_SHELF:
			result = [dataManager getProductsForShelf:productTerm onPage:currentPage totalPageCountHolder:&totalPageCount];
			break;
		case PRODUCT_SEARCH:
			result = [dataManager searchForProducts:productTerm onPage:currentPage totalPageCountHolder:&totalPageCount];
			break;
		default:
			break;
	}
	
	
	[dataManager setOverlayLoadingLabelText:[NSString stringWithFormat:@"%d products left to fetch",[result count]]];
	
	[dataManager fetchImagesForProductBatch: result];
	[products addObjectsFromArray: result];
	
	if ([products count] == 0) {
		/* just pop up a window to say so */
		UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"Online Shop" message:[NSString stringWithFormat:@"No results found for '%@'", productTerm] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noResultsAlert show];
		[noResultsAlert release];
	}
	
	[pool release];
}

- (void)fetchMoreProducts {
	currentPage++;
	[dataManager showOverlayView:[[self view] window]];
	[dataManager setOverlayLabelText:[NSString stringWithFormat:@"Fetching page %d of %d", currentPage, totalPageCount]];
	[dataManager showActivityIndicator];		
	[NSThread detachNewThreadSelector:@selector(loadProducts) toTarget:self withObject:nil];
}

- (void)productImageBatchFetchCompleteNotification {
	[dataManager hideOverlayView];
	[productsView reloadData];
}

/*
 * Add this cell's product (identified by the tag of the sender, which will be the product ID)
 * to both the product basket and the online basket
 */
- (void)plusProductButtonClicked:(id)sender {
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	NSEnumerator *productsEnumerator = [products objectEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productBaseID] intValue] == [productBaseID intValue]) {
			/* we've found the product that relates to this product ID so increase its quantity in the basket */
			[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:1]];
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[productsView reloadData];
}

/*
 * Remove this cell's product (identified by the tag of the sender, which will be the product ID)
 * from both the product basket and the online basket
 */
- (void)minusProductButtonClicked:(id)sender {
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	NSEnumerator *productsEnumerator = [products objectEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productBaseID] intValue] == [productBaseID intValue]) {
			/* we've found the product that relates to this product ID so decrease its quantity in the basket */
			[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:-1]];
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[productsView reloadData];
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

