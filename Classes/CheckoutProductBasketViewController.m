//
//  CheckoutProductBasketViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "CheckoutProductBasketViewController.h"
#import "CheckoutAddProductViewController.h"
#import "DBProduct.h"
#import "DataManager.h"
#import "LogManager.h"
#import "RecipeShopperAppDelegate.h"

@interface CheckoutProductBasketViewController ()
//Private class functions
- (void) bookDeliverySlot:(id)sender;
- (void) decreaseCountForProduct:(id)sender;
- (void) increaseCountForProduct:(id)sender;
- (void) addProduct:(id)sender;
@end

@implementation CheckoutProductBasketViewController

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];

	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	//Set background colour
	[productBasketTableView setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
															   green:0.9137254901960784 
																blue:0.9568627450980392
															   alpha:1.0]];
	//Ensure rows are not selectable
	[productBasketTableView setAllowsSelection:NO];
	
	//Add product add button to top right corner
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProduct:)];
	
	self.navigationItem.rightBarButtonItem = addButton;
	
	//Set title
	self.title = NSLocalizedString(@"Product Basket", @"Current product basket");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods



// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 2;
	}else {
		return [[DataManager getProductBasket] count];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return @"Summary";
	}else {
		return @"Product List";
	}
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
	if (indexPath.section == 0) {
		return 50;
	}else{
		return 60;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 0){
		return 0;
	}else{
		return 76;
	}
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (section == 0){
		return nil;
	}
	
    if(footerView == nil) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
		
		UIImage *image = [[UIImage imageNamed:@"button_green.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
		//create the button
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[button setBackgroundImage:image forState:UIControlStateNormal];
		
		//the button should be as big as a table view cell
		[button setFrame:CGRectMake(10, 16, 300, 44)];
		
		//set title, font size and font color
		[button setTitle:@"Book Delivery Date" forState:UIControlStateNormal];
		[button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//set action of the button
		[button addTarget:self action:@selector(bookDeliverySlot:)
		 forControlEvents:UIControlEventTouchUpInside];
		
		//add the button to the view
		[footerView addSubview:button];
		
    }
	
    //return the view for the footer
    return footerView;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	
	if(indexPath.section == 0) {
		if ([indexPath row] == 0) {
			//Ensure we dont show an image
			[[cell imageView] setImage: nil];
			
			//Total number of items
			[[cell textLabel] setText: @"Total Items Needed:"];
			[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
			
			//Create the accessoryView so we can pad uilabel
			UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,70,40)];
			
			//Create accessory view
			UILabel *accLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,60,40)];
			[accLabel setText:[NSString stringWithFormat:@"%d", [DataManager getTotalProductCount]]];
			[accLabel setTextAlignment: UITextAlignmentRight];
			
			[accessoryView addSubview:accLabel];
			[cell setAccessoryView:accessoryView];
			[accessoryView release];
		}else {
			//Ensure we dont show an image
			[[cell imageView] setImage: nil];
			
			//Total cost
			[[cell textLabel] setText: @"Total Cost:"];
			[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
			
			//Create the accessoryView so we can pad uilabel
			UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,80,40)];
			
			//Create accessory view
			UILabel *accLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,70,40)];
			[accLabel setText:[NSString stringWithFormat:@"£%.2f", [DataManager getTotalProductBasketCost]]];
			[accLabel setTextAlignment: UITextAlignmentRight];
			
			[accessoryView addSubview:accLabel];
			[cell setAccessoryView:accessoryView];
			[accessoryView release];
		}
	}else if (indexPath.section == 1) {
		// Set up the cell...
		NSArray *productBasket = [DataManager getProductBasket];
		DBProduct *product = [productBasket objectAtIndex:[indexPath row]];
		[[cell textLabel] setNumberOfLines:2];
		[[cell textLabel] setText: [product productName]];
		[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:10]];
		[[cell imageView] setImage: [product productIcon]];
		
		
		//Create the accessoryView for everything to be inserted into
		UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0,0,126,54)];
		
		//Minus button
		UIButton *minusButton  = [[UIButton alloc] initWithFrame:CGRectMake(0,6,44,44)];
		[minusButton setTag:[[product productBaseID] intValue]];
		[minusButton addTarget:self action:@selector(decreaseCountForProduct:) forControlEvents:UIControlEventTouchUpInside];
		UIImage *minusImage = [UIImage imageNamed:@"button_minus.png"];
		[minusButton setImage:minusImage forState:UIControlStateNormal];
		
		//Count label
		UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(37,0,13,54)];
		NSInteger productQuantity = [DataManager getCountForProduct:product];
		[countLabel setText:[NSString stringWithFormat:@"%d", productQuantity]];
		[countLabel setFont:[UIFont boldSystemFontOfSize:11]];
		[countLabel setTextAlignment: UITextAlignmentCenter];
		
		//Plus button
		UIButton *plusButton = [[UIButton alloc] initWithFrame:CGRectMake(43,6,44,44)];
		[plusButton setTag:[[product productBaseID] intValue]];
		[plusButton addTarget:self action:@selector(increaseCountForProduct:) forControlEvents:UIControlEventTouchUpInside];
		UIImage *plusImage = [UIImage imageNamed:@"button_plus.png"];
		[plusButton setBackgroundImage:plusImage forState:UIControlStateNormal];
		
		//Price label
		UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(80,0,42,54)];
		[priceLabel setText:[NSString stringWithFormat:@"£%.2f", ([[product productPrice] floatValue] * productQuantity)]];
		[priceLabel setFont:[UIFont boldSystemFontOfSize:11]];
		[priceLabel setTextAlignment: UITextAlignmentRight];
		
		//Add everything to accessory view
		[accessoryView addSubview:minusButton];
		[accessoryView addSubview:plusButton];
		[accessoryView addSubview:countLabel];
		[accessoryView addSubview:priceLabel];
		
		//Ensure count label is in front of button
		[accessoryView bringSubviewToFront:countLabel];
		
		//Finally add accessory view itself
		[cell setAccessoryView:accessoryView];
		[accessoryView release];
	}
	
    return cell;
}

- (void) decreaseCountForProduct:(id)sender {
	NSInteger productBaseID = [sender tag];
	
	NSArray *productBasket = [DataManager getProductBasket];
	for (DBProduct *product in productBasket) {
		if ([[product productBaseID] intValue] == productBaseID) {
			[DataManager decreaseCountForProduct:product];
		}
	}
	
	[self.tableView reloadData];
}

- (void) increaseCountForProduct:(id)sender {
	NSInteger productBaseID = [sender tag];
	
	NSArray *productBasket = [DataManager getProductBasket];
	for (DBProduct *product in productBasket) {
		if ([[product productBaseID] intValue] == productBaseID) {
			[DataManager increaseCountForProduct:product];
		}
	}
	
	[self.tableView reloadData];
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}*/


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == 0){
		return NO;
	}else{
		return YES;
	}
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		DBProduct *product = [[DataManager getProductBasket] objectAtIndex:[indexPath row]];
		[DataManager removeProductFromBasket:product];		
		
		// Delete row from table view
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
		//Will need to update totals
		[self.tableView reloadData];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void) bookDeliverySlot:(id)sender {
	if ([[DataManager getRecipeBasket] count] == 0) {
		return;
	}
}

- (void) addProduct:(id)sender {
	//Check for network connectivity
	if (![DataManager phoneIsOnline]) {
		[LogManager log:@"Internet connection could not be detected" withLevel:LOG_WARNING fromClass:@"CheckoutProductBasketViewController"];
		UIAlertView *networkError = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Feature unavailable offline" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[networkError show];
		[networkError release]; 
		return;
	}else {
		[LogManager log:@"Internet connection successfully detected" withLevel:LOG_INFO fromClass:@"CheckoutProductBasketViewController"];
	}
	
	//Want to present modal view controller here
	CheckoutAddProductViewController *controller = [[CheckoutAddProductViewController alloc] initWithNibName:@"CheckoutAddProductView" bundle:nil];
	controller.title = @"Add Product";
	controller.delegate = self;
	
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:controller animated:YES];
	
	[controller release];
}

- (void)dealloc {
	[productBasketTableView release];
	[footerView release];
    [super dealloc];
}


- (void)currentViewControllerDidFinish:(UIViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

@end

