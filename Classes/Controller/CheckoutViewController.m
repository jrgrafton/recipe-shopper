//
//  CheckoutViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "CheckoutViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"
#import "LogManager.h"
#import "DataManager.h"

@interface CheckoutViewController()

- (void)addProductButtonClicked:(id)sender;
- (void)addProductButtonClicked:(id)sender;

@end

@implementation CheckoutViewController

@synthesize deliverySlotsViewController;
@synthesize basketPrice;
@synthesize basketSavings;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	/* prevent the rows from being selected */
	[basketView setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* scroll the basket to the top */
	[basketView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	/* show the overlay view */
	[DataManager showOverlayView:basketView];
	
	/* update the online basket details */
	[NSThread detachNewThreadSelector:@selector(updateBasketDetails) toTarget:self withObject:nil];
}

- (IBAction)transitionToDeliverySlotView:(id)sender {
	if (deliverySlotsViewController == nil) {
		DeliverySlotsViewController *deliverySlotsView = [[DeliverySlotsViewController alloc] initWithNibName:@"DeliverySlotsView" bundle:nil];
		[self setDeliverySlotsViewController:deliverySlotsView];
		[deliverySlotsView release];
	}
	
	/* load the delivery slots into the delivery slot view before we transition */
	[deliverySlotsViewController loadDeliveryDates];
	
	/* transition to delivery slot view */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewController] pushViewController:self.deliverySlotsViewController animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		/* this is the basket summary section */
		return 50;
	} else {
		/* this is the basket itself */
		return 120;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
		/* this is the basket summary section */
		return 3;
	} else {
		/* this is the basket itself */
		return [DataManager getDistinctProductCount];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		/* this is the basket summary section */
		static NSString *BasketDetailsCellIdentifier = @"BasketSummaryCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:BasketDetailsCellIdentifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:BasketDetailsCellIdentifier] autorelease];
		}
		
		if ([indexPath row] == 0) {
			/* ensure we dont show an image */
			[[cell imageView] setImage:nil];
			
			/* total number of items in basket */
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
			[totalCostLabel setText:[NSString stringWithFormat:@"£%.2f", [[self basketPrice] floatValue]]];
			[totalCostLabel setTextAlignment: UITextAlignmentRight];
			
			if (waitingForAPI == YES) {
				[totalCostLabel setTextColor:[UIColor redColor]];
			}
			
			UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
			[accessoryView addSubview:totalCostLabel];
			[cell setAccessoryView:accessoryView];
			[accessoryView release];
			[totalCostLabel release];
		} else {
			[[cell imageView] setImage:nil];
			
			[[cell textLabel] setText:@"MultiBuy Savings"];
			[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
			[[cell detailTextLabel] setText:@""];
			
			UILabel *totalSavingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
			[totalSavingsLabel setText:[NSString stringWithFormat:@"£%.2f", [[self basketSavings] floatValue]]];
			[totalSavingsLabel setTextAlignment: UITextAlignmentRight];
			
			if (waitingForAPI == YES) {
				[totalSavingsLabel setTextColor:[UIColor redColor]];
			}
			
			UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
			[accessoryView addSubview:totalSavingsLabel];
			[cell setAccessoryView:accessoryView];
			[accessoryView release];
			[totalSavingsLabel release];
		}
	} else if (indexPath.section == 1) {
		/* this is the basket itself */
		static NSString *ProductBasketCellIdentifier = @"ProductBasketCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:ProductBasketCellIdentifier];
		
		Product *product = [DataManager getProductFromBasket:[indexPath row]];
		NSNumber *quantity = [DataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:ProductBasketCellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([buttons count] > 1) {
			[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
	
	return cell;	
}

#pragma mark -
#pragma mark Tab Bar Controller delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	if ([DataManager offlineMode] == YES) {
		UIAlertView *offlineAlert = [[UIAlertView alloc] initWithTitle:@"Offline mode" message:@"Feature unavailable in offline mode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[offlineAlert show];
		[offlineAlert release];
		return NO;
	} else if (([DataManager loggedIn] == NO) && (viewController == [tabBarController.viewControllers objectAtIndex:3])) {
		[DataManager requestLoginToStore];
		return NO;
	}
	
	return YES;
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
			
			/* add the cost of one of these items to the basket price */
			CGFloat productPrice = [[product productPrice] floatValue];
			CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
			[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice + productPrice]];
			
			/* reload the product basket - the price and multibuy savings will be updated once the 
			 online basket price (which may be different) is calculated */
			waitingForAPI = YES;
			
			/* stop looking - we've found it */
			break;			
		}
	}
	
	/* reload the data so the new values are displayed */
	[basketView reloadData];
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
			
			/* deduct the cost of one of these items from the basket price */
			CGFloat productPrice = [[product productPrice] floatValue];
			CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
			[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice - productPrice]];
			
			/* reload the product basket - the price and multibuy savings will be updated once the 
			 online basket price (which may be different) is calculated */
			waitingForAPI = YES;
			
			/* stop looking - we've found it */
			break;			
		}
	}
	
	/* reload the data so the new values are displayed */
	[basketView reloadData];
}

- (void)updateBasketDetails {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* get the latest basket details (price, savings etc.) */
	NSDictionary *basketDetails = [DataManager getBasketDetails];
	[self setBasketPrice:[basketDetails objectForKey:@"BasketPrice"]];
	[self setBasketSavings:[basketDetails objectForKey:@"BasketSavings"]];
	
	/* reload the basket details section to show the new values */
	waitingForAPI = NO;
	[basketView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
	
	[DataManager hideOverlayView];
	
	[pool release];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
