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
#import "DataManager.h"

@interface ProductsViewController()

- (void)addProductButtonClicked:(id)sender;
- (void)removeProductButtonClicked:(id)sender;

@end

@implementation ProductsViewController

@synthesize products;

- (void)viewDidLoad {
    [super viewDidLoad];
		
	[productsView setAllowsSelection:NO];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[productsView reloadData];
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadProductsForShelf:(NSString *)shelf {
	[self setProducts:[DataManager getProductsForShelf:shelf]];
	[productsView reloadData];
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
    return [products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ProductCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    /* Create a cell for this row's product */
	Product *product = [products objectAtIndex:[indexPath row]];
	NSNumber *quantity = [DataManager getProductQuantityFromBasket:product];
	NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity];
	
	[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	if ([buttons count] > 1) {
		[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
	
    return cell;
}

#pragma mark -
#pragma mark Private methods

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
			[DataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:1]];
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[self.tableView reloadData];
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
			[DataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:-1]];
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[self.tableView reloadData];
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

