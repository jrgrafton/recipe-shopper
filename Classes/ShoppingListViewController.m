//
//  ShoppingListViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 10/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "ShoppingListViewController.h"
#import "UITableViewCellFactory.h"
#import "DataManager.h"

@interface ShoppingListViewController()

- (void)addProductButtonClicked:(id)sender;
- (void)removeProductButtonClicked:(id)sender;

@end

@implementation ShoppingListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
		
	[self.tableView setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* scroll the list to the top */
	[self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Shopping List";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [DataManager getDistinctProductCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ShoppingListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* create a cell for this row's product */
	Product *product = [DataManager getProductFromBasket:[indexPath row]];
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
	
	NSEnumerator *productsEnumerator = [[DataManager getProductBasket] keyEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productBaseID] intValue] == [productBaseID intValue]) {
			/* we've found the product that relates to this product ID so increase its quantity in the product basket */
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
	
	NSEnumerator *productsEnumerator = [[DataManager getProductBasket] keyEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productBaseID] intValue] == [productBaseID intValue]) {
			/* we've found the product that relates to this product ID so decrease its quantity in the product basket */
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

