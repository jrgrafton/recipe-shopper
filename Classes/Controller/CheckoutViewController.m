//
//  CheckoutViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "CheckoutViewController.h"
#import "OnlineShopViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"
#import "LogManager.h"

@interface CheckoutViewController()

- (void)productsNeedReplacingBeforeProceeding;
- (void)basketHasBeenModified;
- (void)productBasketUpdateComplete;
- (void)onlineBasketUpdateComplete;
- (void)loadDeliveryDates;
- (void)scrollToBottomOfTable;

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
	
	//By default user does not want to proceed
	userWantsToProceed = NO;
	
	//And we're not fetching online basket info
	fetchingOnlineBasketInfo = NO;
	
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
	
	/* Update online basket information unless we are already updating online basket */
	if ([dataManager updatingOnlineBasket] == NO) {
		[NSThread detachNewThreadSelector:@selector(onlineBasketUpdateComplete) toTarget:self withObject:nil];
	}else {
		[basketView reloadData];
	}

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([dataManager updatingProductBasket] == YES) {
		[dataManager showOverlayView:[[self view] window]];
		[dataManager setOverlayLabelText:@"Updating basket"];
	}
	
	/* Does not cover the case where online basket is still updating when view appears... */
	if ([dataManager getDistinctUnavailableOnlineCount] != 0) {
		[self scrollToBottomOfTable];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	//By default user does not want to proceed
	userWantsToProceed = NO;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)transitionToDeliverySlotView:(id)sender {
	if (deliverySlotsViewController == nil) {
		DeliverySlotsViewController *deliverySlotsView = [[DeliverySlotsViewController alloc] initWithNibName:@"DeliverySlotsView" bundle:nil];
		[self setDeliverySlotsViewController:deliverySlotsView];
		[deliverySlotsView release];
	}
	
	//Can't proceed with less than 5 items
	if ([dataManager getTotalProductCount] < 5) {
		UIAlertView *tooFewItemsAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Fewer than 5 items in the basket" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[tooFewItemsAlert show];
		[tooFewItemsAlert release];
	} //Ensure we do one final product basket validation
	else if ([dataManager updatingOnlineBasket]) {
		//Wait for basket to finish updating
		[dataManager showOverlayView:[[self view] window]];
		[dataManager setOverlayLabelText:@"Waiting basket updates to complete"];
		userWantsToProceed = YES;
	} else {
		/* load the delivery slots into the delivery slot view and transition */
		[dataManager showOverlayView:[[self view] window]];
		[NSThread detachNewThreadSelector:@selector(loadDeliveryDates) toTarget:self withObject:nil];
	}
}

- (void)loadDeliveryDates {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[dataManager performSelectorOnMainThread:@selector(setOverlayLabelText:) withObject:@"Verifying Basket" waitUntilDone:YES];
	
	BOOL basketHasBeenModified;
	
	if ([dataManager updatingOnlineBasket]) {
		/* If we are performing online updates at this point it must mean that 
		 completion of last update batch ended in disparency between baskets */
		basketHasBeenModified = YES;
	}else {
		/* No resych going in background so lets check for ourselves */
		basketHasBeenModified = [dataManager synchronizeOnlineOfflineBasket];
	}
	
	if ([dataManager getDistinctUnavailableOnlineCount] != 0) {
		/* User needs to deal with all unavailable products before proceeding */
		[self performSelectorOnMainThread:@selector(productsNeedReplacingBeforeProceeding) withObject:nil waitUntilDone:YES];
		return;
	}
	
	if (basketHasBeenModified) {
		/* User needs to confirm they are OK with basket modifications before proceeding */
		[self performSelectorOnMainThread:@selector(basketHasBeenModified) withObject:nil waitUntilDone:YES];
		return;
	}
	
	[dataManager performSelectorOnMainThread:@selector(setOverlayLabelText:) withObject:@"Loading delivery slots" waitUntilDone:YES];
	[deliverySlotsViewController loadDeliveryDates];
	[dataManager hideOverlayView];
	
	/* transition to delivery slot view */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewNavController] pushViewController:self.deliverySlotsViewController animated:YES];
	
	[pool release];
}

- (void)productsNeedReplacingBeforeProceeding {
	[dataManager hideOverlayView];
	[basketView reloadData];
	
	UIAlertView *productNeedsReplacingAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please replace all unavailble products before proceeding" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[productNeedsReplacingAlert show];
	[productNeedsReplacingAlert release];
	
	[self scrollToBottomOfTable];
}

- (void)basketHasBeenModified {
	[dataManager hideOverlayView];
	[basketView reloadData];
	
	UIAlertView *basketModified = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Basket has been modified, please review contents" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[basketModified show];
	[basketModified release];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0) {
		/* this is the shopping list summary section */
		return ([indexPath row] == 0)? 70:50;
	} else {
		/* this is the shopping list or unavailble online section */
		return ([indexPath row] == 0)? 135:120;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ([dataManager getDistinctUnavailableOnlineCount] == 0)? 2:3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
		/* this is the basket summary section */
		return 4;
	} else if (section == 1) {
		/* this is the basket itself */
		return [dataManager getDistinctAvailableOnlineCount];
	} else if (section == 2) {
		/* this is the unavailable online collection */
		return [dataManager getDistinctUnavailableOnlineCount];
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell;
	
	if (indexPath.section == 0) {
		/* this is the basket summary section */
		NSString *CellIdentifier = ([indexPath row] == 0)? @"BasketSummaryCellHeader":@"BasketSummaryCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		NSArray *keyValue;
		
		if ([indexPath row] == 0) {
			NSInteger test = 0;
			test = [dataManager getTotalProductCount];
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
			
			if ([dataManager updatingOnlineBasket] == YES || fetchingOnlineBasketInfo) {
				[activityIndicator startAnimating];
				[activityIndicator setHidden:NO];
			} else {
				[activityIndicator setHidden:YES];
				[activityIndicator stopAnimating];
			}			
		}
	} else if (indexPath.section == 1) {
		/* this is the basket itself */
		NSString *CellIdentifier = ([indexPath row] == 0)? @"ProductBasketCellHeader":@"ProductBasketCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		Product *product = [dataManager getAvailableOnlineProduct:[indexPath row]];
		
		NSNumber *quantity = [dataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO isProductUnavailableCell:NO isHeader:([indexPath row] == 0)];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(plusProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		if ([buttons count] > 1) {
			[[buttons objectAtIndex:1] addTarget:self action:@selector(minusProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:@"Product Basket"];
	} else if (indexPath.section == 2) {
		/* this is the basket itself */
		NSString *CellIdentifier = ([indexPath row] == 0)? @"UnavailbleOnlineCellHeader":@"UnavailbleOnlineCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		
		Product *product = [dataManager getUnavailableOnlineProduct:[indexPath row]];
		if (product == nil) {
			/* Something's gone wrong... Better reload data! */
			[basketView reloadData];
			return cell;
		}
		
		NSNumber *quantity = [dataManager getProductQuantityFromBasket:product];
		NSArray *buttons = [UITableViewCellFactory createProductTableCell:&cell withIdentifier:CellIdentifier withProduct:product andQuantity:quantity forShoppingList:NO isProductUnavailableCell:YES isHeader:([indexPath row] == 0)];
		
		[[buttons objectAtIndex:0] addTarget:self action:@selector(removeProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[[buttons objectAtIndex:1] addTarget:self action:@selector(replaceProductButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		UILabel *headerLabel = (UILabel *)[cell viewWithTag:13];
		[headerLabel setText:@"Unavailble In Your Area"];
	}
	
	return cell;	
}

#pragma mark -
#pragma mark Private methods

- (void)productBasketUpdateComplete {
	[basketView reloadData];
	[dataManager hideOverlayView];
}

- (void)scrollToBottomOfTable {
	[basketView setContentOffset:CGPointMake(0, basketView.contentSize.height - basketView.frame.size.height) animated:YES];
}

- (void)onlineBasketUpdateComplete {
	@synchronized(self) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		fetchingOnlineBasketInfo = YES;
		
		/* In case spinners have disappeared after basket updates finished */
		[basketView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
		
		/* get the latest basket details (price, savings etc.) */
		NSDictionary *basketDetails = [dataManager getBasketDetails];
		
		[self setBasketPrice:[basketDetails objectForKey:@"BasketPrice"]];
		[self setBasketSavings:[basketDetails objectForKey:@"BasketSavings"]];
		[self setBasketPoints:[basketDetails objectForKey:@"BasketPoints"]];
		
		fetchingOnlineBasketInfo = NO;
		
		/* reload the basket details section to show the new values and hide spinners */
		[basketView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
		
		/* Scroll to bottom if we have any products that are unavailable */
		if ([dataManager getDistinctUnavailableOnlineCount] != 0) {
			[self performSelectorOnMainThread:@selector(scrollToBottomOfTable) withObject:nil waitUntilDone:YES];
		}
		
		/* If the user has already clicked delivery slot button try and proceed to deliveries */
		if (userWantsToProceed) {
			userWantsToProceed = NO;
			[self loadDeliveryDates];
		}
		
		[pool release];
	}
}

/*
 * Add this cell's product (identified by the tag of the sender, which will be the product ID)
 * to both the product basket and the online basket
 */
- (void)plusProductButtonClicked:(id)sender {
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	Product *product = [dataManager getProductByBaseID:productBaseID];
	
	if (product != nil) {
		/* we've found the product that relates to this product ID so increase its quantity in the product basket */
		[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:1]];
		
		/* add the cost of one of these items to the basket price */
		CGFloat productPrice = [[product productPrice] floatValue];
		CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
		[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice + productPrice]];	
	}
	
	/* reload the data so the new values are displayed */
	[basketView reloadData];
}

/*
 * Remove this cell's product (identified by the tag of the sender, which will be the product ID)
 * from both the product basket and the online basket
 */
- (void)minusProductButtonClicked:(id)sender {
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	Product *product = [dataManager getProductByBaseID:productBaseID];
	
	if (product != nil) {
		/* we've found the product that relates to this product ID so decrease its quantity in the product basket */
		[dataManager updateBasketQuantity:product byQuantity:[NSNumber numberWithInt:-1]];
		
		/* deduct the cost of one of these items from the basket price */
		CGFloat productPrice = [[product productPrice] floatValue];
		CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
		[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice - productPrice]];		
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
	
	Product *product = [dataManager getProductByBaseID:productBaseID];
	
	if (product != nil) {
		/* we've found the product that relates to this product ID so decrease its quantity in the product basket */
		NSNumber *removeTotal = [NSNumber numberWithInt:(0 - [[dataManager getProductQuantityFromBasket:product] intValue])];
		[dataManager updateBasketQuantity:product byQuantity:removeTotal];
		
		/* deduct the cost of one of these items from the basket price */
		CGFloat productPrice = [[product productPrice] floatValue];
		CGFloat currentBasketPrice  = [[self basketPrice] floatValue];
		[self setBasketPrice:[NSString stringWithFormat:@"%.2f", currentBasketPrice - productPrice]];
	}
	
	/* reload the data so the new values are displayed */
	[basketView reloadData];
}

- (void)replaceProductButtonClicked:(id)sender {
	/* Remove item from basket */
	[self removeProductButtonClicked:sender];
	
	/* Prompt user to replace by moving them to online shop tab */
	NSString *productBaseID = [NSString stringWithFormat:@"%d", [sender tag]];
	
	Product *product = [dataManager getProductByBaseID:productBaseID];
	
	if (product != nil) {
		[self performSelectorOnMainThread:@selector(replaceAction:) withObject:[product productName] waitUntilDone:YES];
	}
}

- (void)replaceAction:(NSString*)productName {
	[dataManager setReplaceMode:YES];
	[dataManager setReplaceString:productName];
	
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate onlineShopViewNavController] popToRootViewControllerAnimated:FALSE];
	[[appDelegate tabBarController] setSelectedIndex:2];
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
