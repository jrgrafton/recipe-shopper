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

@synthesize basketPrice;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[productTableView setBackgroundColor: [UIColor clearColor]];
	
	[productTableView setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* scroll the list to the top */
	[productTableView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	/* reload the table data in case it has changed */
	[productTableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		/* this is the shopping list section */
		return 2;
	} else {
		/* this is the shopping list itself */
		return [DataManager getDistinctProductCount];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		/* this is the shopping list summary section */
		return ([indexPath row] == 0)? 70:50;
	} else {
		/* this is the shopping list itself */
		return ([indexPath row] == 0)? 135:120;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		/* this is the shopping list summary section */
		NSString *CellIdentifier = ([indexPath row] == 0)? @"ShoppingListSummaryCellHeader":@"ShoppingListSummaryCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		if ([indexPath row] == 0) {
			NSArray *keyValue = [NSArray arrayWithObjects:@"Number Of Items",[NSString stringWithFormat:@"%d",[DataManager getTotalProductCount]],nil];
			[UITableViewCellFactory createTotalTableCell:&cell withIdentifier:CellIdentifier withNameValuePair:keyValue isHeader:YES];
			UILabel *headerLabel = (UILabel *)[cell viewWithTag:4];
			[headerLabel setText:@"Totals"];
			
		} else if ([indexPath row] == 1) {
			NSArray *keyValue = [NSArray arrayWithObjects:@"Total Cost",[DataManager getProductBasketPrice],nil];
			[UITableViewCellFactory createTotalTableCell:&cell withIdentifier:CellIdentifier withNameValuePair:keyValue isHeader:NO];
		}
	} else if (indexPath.section == 1) {
		/* this is the shopping list itself */
		NSString *CellIdentifier = ([indexPath row] == 0)? @"ShoppingListCellHeader":@"ShoppingListCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		/* create a cell for this row's product */
		Product *product = [DataManager getProductFromBasket:[indexPath row]];
		NSNumber *quantity = [DataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:YES isHeader:([indexPath row] == 0)];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([buttons count] > 1) {
			[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:@"Shopping List"];
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
			
			/* add the cost of one of these items to the shopping list price */
			CGFloat productPrice = [[product productPrice] floatValue];
			CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
			[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice + productPrice]];
			
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[productTableView reloadData];
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
			
			/* deduct the cost of one of these items from the shopping list price */
			CGFloat productPrice = [[product productPrice] floatValue];
			CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
			[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice - productPrice]];
			
			break;
		}
	}
	
	/* reload the data so the new values are displayed */
	[productTableView reloadData];
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

