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
		return 50;
	} else {
		/* this is the shopping list itself */
		return 120;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		/* this is the shopping list summary section */
		static NSString *ShoppingListDetailsCellIdentifier = @"ShoppingListSummaryCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:ShoppingListDetailsCellIdentifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ShoppingListDetailsCellIdentifier] autorelease];
		}
		
		if ([indexPath row] == 0) {
			/* ensure we dont show an image */
			[[cell imageView] setImage:nil];
			
			/* total number of items in shopping list */
			[[cell textLabel] setText: @"Number Of Items"];
			[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
			[[cell detailTextLabel] setText:@""];
			
			UILabel *numItemsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
			[numItemsLabel setText:[NSString stringWithFormat:@"%d", [DataManager getTotalProductCount]]];
			[numItemsLabel setTextAlignment: UITextAlignmentRight];
			
			UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
			[accessoryView addSubview:numItemsLabel];
			[cell setAccessoryView:accessoryView];
			[accessoryView release];
			[numItemsLabel release];
		} else if ([indexPath row] == 1) {
			[[cell imageView] setImage:nil];
			
			[[cell textLabel] setText:@"Total Cost"];
			[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
			[[cell detailTextLabel] setText:@""];
			
			UILabel *totalCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
			[totalCostLabel setText:[DataManager getProductBasketPrice]];
			[totalCostLabel setTextAlignment: UITextAlignmentRight];
			
			UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
			[accessoryView addSubview:totalCostLabel];
			[cell setAccessoryView:accessoryView];
			[accessoryView release];
			[totalCostLabel release];
		}
	} else if (indexPath.section == 1) {
		/* this is the shopping list itself */
		static NSString *CellIdentifier = @"ShoppingListCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		/* create a cell for this row's product */
		Product *product = [DataManager getProductFromBasket:[indexPath row]];
		NSNumber *quantity = [DataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:YES];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([buttons count] > 1) {
			[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
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

