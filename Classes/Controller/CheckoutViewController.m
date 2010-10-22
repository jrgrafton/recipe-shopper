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
- (void)loadDeliveryDates;

@end

#define CELL_TITLE_TAG 1
#define CELL_INFO_TAG 2
#define CELL_ACTIVITY_INDICATOR_TAG 3

@implementation CheckoutViewController

@synthesize deliverySlotsViewController;
@synthesize basketPrice;
@synthesize basketSavings;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[basketView setBackgroundColor: [UIColor clearColor]];
	
	/* add this object as an observer of the change basket method so we can update the basket details when they change */
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBasketDetails) name:@"BasketChanged" object:nil];
	
	/* prevent the rows from being selected */
	[basketView setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* scroll the basket to the top */
	[basketView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	/* show the overlay view */
	[DataManager showOverlayView:[[self view] window]];
	
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
	[DataManager showOverlayView:[[self view] window]];
	[DataManager setOverlayLabelText:@"Loading delivery slots"];
	[NSThread detachNewThreadSelector:@selector(loadDeliveryDates) toTarget:self withObject:nil];
	
}

- (void)loadDeliveryDates {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[deliverySlotsViewController loadDeliveryDates];
	[DataManager hideOverlayView];
	
	/* transition to delivery slot view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewController] pushViewController:self.deliverySlotsViewController animated:YES];
	
	[pool release];
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
		static NSString *CellIdentifier = @"BasketSummaryCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		/* create a cell for this row's info */
		if (cell == nil) {
			/* load the basket view cell nib */
			NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"BasketViewCell" owner:self options:nil];
			
			for (id viewElement in bundle) {
				if ([viewElement isKindOfClass:[UITableViewCell class]])
					cell = (UITableViewCell *)viewElement;
			}
		}

		UILabel *titleLabel = (UILabel *)[cell viewWithTag:CELL_TITLE_TAG];
		UILabel *infoLabel = (UILabel *)[cell viewWithTag:CELL_INFO_TAG];
		UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:CELL_ACTIVITY_INDICATOR_TAG];
		
		if ([indexPath row] == 0) {
			[titleLabel setText:@"Number Of Items"];
			[infoLabel setText:[NSString stringWithFormat:@"%d", [DataManager getTotalProductCount]]];
		} else if ([indexPath row] == 1) {
			[titleLabel setText:@"Total Cost"];
			[infoLabel setText:[NSString stringWithFormat:@"£%.2f", [[self basketPrice] floatValue]]];
			
			if (waitingForAPI == YES) {
				[activityIndicator startAnimating];
			} else {
				[activityIndicator stopAnimating];
			}
		} else {
			[titleLabel setText:@"MultiBuy Savings"];
			[infoLabel setText:[NSString stringWithFormat:@"£%.2f", [[self basketSavings] floatValue]]];
			
			if (waitingForAPI == YES) {
				[activityIndicator startAnimating];
			} else {
				[activityIndicator stopAnimating];
			}
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
	[basketView reloadData];
	
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
