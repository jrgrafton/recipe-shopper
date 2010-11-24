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

@interface CheckoutViewController()

- (void)productBasketUpdateComplete;
- (void)onlineBasketUpdateComplete;
- (void)addProductButtonClicked:(id)sender;
- (void)addProductButtonClicked:(id)sender;
- (void)loadDeliveryDates;
@end

#define CELL_ACTIVITY_INDICATOR_TAG 6

@implementation CheckoutViewController

@synthesize deliverySlotsViewController;
@synthesize basketPrice;
@synthesize basketSavings;
@synthesize basketPoints;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		dataManager = [DataManager getInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	//initWithNib does not get called when controller is root in navigation stack
	dataManager = [DataManager getInstance];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];

	[basketView setBackgroundColor: [UIColor clearColor]];
	
	/* prevent the rows from being selected */
	[basketView setAllowsSelection:NO];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	/* add this object as an observer of the method that updates the product basket so we can remove the overlay view when the product basket update is complete */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productBasketUpdateComplete) name:@"ProductBasketUpdateComplete" object:nil];
	
	/* add this object as an observer of the change basket method so we can update the basket details when they change */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineBasketUpdateComplete) name:@"OnlineBasketUpdateComplete" object:nil];
	
	/* scroll the basket to the top */
	[basketView setContentOffset:CGPointMake(0, 0) animated:NO];
	
	if ([dataManager updatingProductBasket] == YES) {
		[dataManager showOverlayView:[[self view] window]];
		[dataManager setOverlayLabelText:@"Updating basket"];
	}
	
	/* Always ensure we have latest basket data loaded */
	[NSThread detachNewThreadSelector:@selector(onlineBasketUpdateComplete) toTarget:self withObject:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)transitionToDeliverySlotView:(id)sender {
	if (deliverySlotsViewController == nil) {
		DeliverySlotsViewController *deliverySlotsView = [[DeliverySlotsViewController alloc] initWithNibName:@"DeliverySlotsView" bundle:nil];
		[self setDeliverySlotsViewController:deliverySlotsView];
		[deliverySlotsView release];
	}
	
	if ([dataManager getTotalProductCount] < 5) {
		UIAlertView *tooFewItemsAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Fewer than 5 items in the basket" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[tooFewItemsAlert show];
		[tooFewItemsAlert release];
	} else {
		/* load the delivery slots into the delivery slot view before we transition */
		[dataManager showOverlayView:[[self view] window]];
		[dataManager setOverlayLabelText:@"Loading delivery slots"];
		[NSThread detachNewThreadSelector:@selector(loadDeliveryDates) toTarget:self withObject:nil];
	}
}

- (void)loadDeliveryDates {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[deliverySlotsViewController loadDeliveryDates];
	[dataManager hideOverlayView];
	
	/* transition to delivery slot view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewController] pushViewController:self.deliverySlotsViewController animated:YES];
	
	[pool release];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		/* this is the shopping list summary section */
		return ([indexPath row] == 0)? 70:50;
	} else {
		/* this is the shopping list itself */
		return ([indexPath row] == 0)? 135:120;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
		/* this is the basket summary section */
		return 4;
	} else {
		/* this is the basket itself */
		return [dataManager getDistinctProductCount];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		/* this is the basket summary section */
		NSString *CellIdentifier = ([indexPath row] == 0)? @"BasketSummaryCellHeader":@"BasketSummaryCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		NSArray *keyValue;
		
		if ([indexPath row] == 0) {
			keyValue = [NSArray arrayWithObjects:@"Number Of Items",[NSString stringWithFormat:@"%d",[dataManager getTotalProductCount]],nil];
			[UITableViewCellFactory createTotalTableCell:&cell withIdentifier:CellIdentifier withNameValuePair:keyValue isHeader:YES];
			UILabel *headerLabel = (UILabel *)[cell viewWithTag:4];
			[headerLabel setText:@"Totals"];
		} else {
			if ([indexPath row] == 1) {
				keyValue = [NSArray arrayWithObjects:@"Total Cost",[NSString stringWithFormat:@"£%.2f", [[self basketPrice] floatValue]],nil];
			} else if ([indexPath row] == 2) {
				keyValue = [NSArray arrayWithObjects:@"MultiBuy Savings",[NSString stringWithFormat:@"£%.2f",[[self basketSavings] floatValue] ],nil];
			} else {
				if ([self basketPoints] == nil) {
					keyValue = [NSArray arrayWithObjects:@"Clubcard Points", @"0",nil];
				} else {
					keyValue = [NSArray arrayWithObjects:@"Clubcard Points",[NSString stringWithFormat:@"%@",[self basketPoints]],nil];
				}
			}
			
			[UITableViewCellFactory createTotalTableCell:&cell withIdentifier:CellIdentifier withNameValuePair:keyValue isHeader:NO];
			UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell viewWithTag:CELL_ACTIVITY_INDICATOR_TAG];
			
			if ([dataManager updatingOnlineBasket] == YES) {
				[activityIndicator startAnimating];
				[activityIndicator setHidden:NO];
			} else {
				[activityIndicator setHidden:YES];
				[activityIndicator stopAnimating];
			}			
		}
	} else if (indexPath.section == 1) {
		/* this is the basket itself */
		static NSString *ProductBasketCellIdentifier = @"ProductBasketCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:ProductBasketCellIdentifier];
		
		Product *product = [dataManager getProductFromBasket:[indexPath row]];
		NSNumber *quantity = [dataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:ProductBasketCellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO isHeader:([indexPath row] == 0)];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(addProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([buttons count] > 1) {
			[[buttons objectAtIndex:1] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:@"Product Basket"];
	}
	
	return cell;	
}

#pragma mark -
#pragma mark Private methods

- (void)productBasketUpdateComplete {
	[dataManager hideOverlayView];
	[basketView reloadData];
}

- (void)onlineBasketUpdateComplete {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	/* Set updating basket back to yes so we still get spinners */
	[dataManager setUpdatingOnlineBasket:YES];
	
	/* In case spinners have disappeared after basket updates finished */
	[basketView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
	
	
	/* get the latest basket details (price, savings etc.) */
	NSDictionary *basketDetails = [dataManager getBasketDetails];
	
	/* Now we have details, spinners can safely disappear*/
	[dataManager setUpdatingOnlineBasket:NO];
	
	[self setBasketPrice:[basketDetails objectForKey:@"BasketPrice"]];
	[self setBasketSavings:[basketDetails objectForKey:@"BasketSavings"]];
	[self setBasketPoints:[basketDetails objectForKey:@"BasketPoints"]];
	
	/* reload the basket details section to show the new values */
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

	[pool release];
}

/*
 * Add this cell's product (identified by the tag of the sender, which will be the product ID)
 * to both the product basket and the online basket
 */
- (void)addProductButtonClicked:(id)sender {
	NSString *productID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	NSEnumerator *productsEnumerator = [[dataManager getProductBasket] keyEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productID] intValue] == [productID intValue]) {
			/* we've found the product that relates to this product ID so increase its quantity in the product basket */
			[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:1]];
			
			/* add the cost of one of these items to the basket price */
			CGFloat productPrice = [[product productPrice] floatValue];
			CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
			[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice + productPrice]];
			
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
	NSString *productID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	NSEnumerator *productsEnumerator = [[dataManager getProductBasket] keyEnumerator];
	Product *product;
	
	while ((product = [productsEnumerator nextObject])) {
		if ([[product productID] intValue] == [productID intValue]) {
			/* we've found the product that relates to this product ID so decrease its quantity in the product basket */
			[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:-1]];
			
			/* deduct the cost of one of these items from the basket price */
			CGFloat productPrice = [[product productPrice] floatValue];
			CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
			[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice - productPrice]];
						
			/* stop looking - we've found it */
			break;			
		}
	}
	
	/* reload the data so the new values are displayed */
	[basketView reloadData];
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
