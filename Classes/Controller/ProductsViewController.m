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

- (void)addProductButtonClicked:(id)sender;
- (void)removeProductButtonClicked:(id)sender;

@end

@implementation ProductsViewController

@synthesize productShelf;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed:@"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	dataManager = [DataManager getInstance];
	
	[productsView setBackgroundColor:[UIColor clearColor]];
	
	[productsView setAllowsSelection:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[productsView reloadData];
}

- (void)loadProducts:(NSString *)shelf {
	products = [[NSMutableArray alloc] init];
	[products removeAllObjects];
	[products addObjectsFromArray:[dataManager getProductsForShelf:shelf]];
	
	/* scroll the products to the top */
	[productsView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	if ([products count] == 0) {
		/* just pop up a window to say so */
		UIAlertView *noResultsAlert = [[UIAlertView alloc] initWithTitle:@"Online Shop" message:[NSString stringWithFormat:@"No results found for '%@'", shelf] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[noResultsAlert show];
		[noResultsAlert release];
	}
	
	[productsView reloadData];
	[dataManager hideOverlayView];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([indexPath row] == 0)? 135:120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = ([indexPath row] == 0)? @"ProductCellHeader":@"ProductCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    /* Create a cell for this row's product */
	Product *product = [products objectAtIndex:[indexPath row]];
	NSNumber *quantity = [dataManager getProductQuantityFromBasket:product];
	NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO isHeader:([indexPath row] == 0)];
	
	[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([buttons count] > 1) {
		[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	
	if ([indexPath row] == 0) {
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:[self productShelf]];
	}
	
    return cell;
}

/*
 * Add this cell's product (identified by the tag of the sender, which will be the product ID)
 * to both the product basket and the online basket
 */
- (void)addProductButtonClicked:(id)sender {
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
- (void)removeProductButtonClicked:(id)sender {
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

