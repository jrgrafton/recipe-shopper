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
- (void) bookDeliverySlotAction:(id)sender;
- (void) decreaseCountForProduct:(id)sender;
- (void) increaseCountForProduct:(id)sender;
- (void) addProduct:(id)sender;
- (void) loginToStore:(id)sender;
- (void) showLoginError;
- (void) transmitBasket;
- (void) transitionToDeliverySelection:(NSArray*)deliverySlots;
- (void) showLoadingOverlay;
- (void) hideLoadingOverlay;
@end

@implementation CheckoutProductBasketViewController

@synthesize checkoutChooseDeliveryDateController;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

#pragma mark -
#pragma mark View Lifecycle Management

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

-(void)showLoadingOverlay {
	[productBasketTableView setScrollEnabled:FALSE];
	loadingView = [LoadingView loadingViewInView:(UIView *)productBasketTableView withText:@"Logging in..." 
										 andFont:[UIFont systemFontOfSize:16.0f] andFontColor:[UIColor grayColor]
								 andCornerRadius:0 andBackgroundColor:[UIColor colorWithRed:1.0 
																					  green:1.0 
																					   blue:1.0
																					  alpha:1.0]
								   andDrawStroke:FALSE];
}

-(void)hideLoadingOverlay{
	if(loadingView != nil){
		[loadingView removeView];
		loadingView = nil;
	}
	[productBasketTableView setScrollEnabled:TRUE];
}


- (void)currentViewControllerDidFinish:(UIViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
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
		[button addTarget:self action:@selector(bookDeliverySlotAction:)
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
			[accLabel release];
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
			[accLabel release];
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
		[minusButton release];
		[plusButton release];
		[countLabel release];
		[priceLabel release];
	}
	
    return cell;
}

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

#pragma mark -
#pragma mark Additional Instance Functions

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

- (void) bookDeliverySlotAction:(id)sender {
	if ([DataManager getTotalProductCount] < 5) {
		UIAlertView *networkError = [[UIAlertView alloc] initWithTitle: @"Checkout error" message: @"Unable checkout order containing less than 5 products" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[networkError show];
		[networkError release]; 
		return;
	}
	
	if (![DataManager phoneIsOnline]) {
		[LogManager log:@"Internet connection could not be detected" withLevel:LOG_WARNING fromClass:@"CheckoutProductBasketViewController"];
		UIAlertView *networkError = [[UIAlertView alloc] initWithTitle: @"Network error" message: @"Feature unavailable offline" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[networkError show];
		[networkError release]; 
		return;
	}
	//Fetch cached username and password (if they exist)
	NSString* cachedEmail = [DataManager fetchUserPreference:@"login.email"];
	NSString* cachedPassword = [DataManager fetchUserPreference:@"login.password"];
	
	UIAlertView *loginPrompt = [[UIAlertView alloc] initWithTitle: @"Login" message: @"Please login to your account\n\n\n\n\n" delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"OK", nil];
	
	UITextField *emailField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 80.0, 260.0, 30.0)];
	[emailField setBackgroundColor:[UIColor whiteColor]];
	[emailField setPlaceholder:@"john@example.com"];
	[emailField setAutocorrectionType: UITextAutocorrectionTypeNo];
	[emailField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[emailField setBorderStyle:UITextBorderStyleBezel];
	[emailField setKeyboardType:UIKeyboardTypeEmailAddress];
	if (cachedEmail != nil){
		[emailField setText:cachedEmail];
	}
	[loginPrompt addSubview:emailField];
	
	UITextField *passwordField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 120.0, 260.0, 30.0)];
	[passwordField setBackgroundColor:[UIColor whiteColor]];
	[passwordField setPlaceholder:@"Password"];
	[passwordField setSecureTextEntry:YES];
	[passwordField setAutocorrectionType: UITextAutocorrectionTypeNo];
	[passwordField setBorderStyle:UITextBorderStyleBezel];
	if (cachedPassword != nil){
		[passwordField setText:cachedPassword];
	}
	[loginPrompt addSubview:passwordField];
	
	//[loginPrompt setTransform:CGAffineTransformMakeTranslation(0.0, 110.0)]; //Not needed on iOS >= 4.0
	[emailField becomeFirstResponder];
	[loginPrompt show];
    [loginPrompt release];
	[passwordField release];
	[emailField release];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([[alertView title] isEqualToString:@"Login"] && [alertView cancelButtonIndex] != buttonIndex){
		UITextField *emailField = [[alertView subviews] objectAtIndex:4];
		[emailField resignFirstResponder];
		[self showLoadingOverlay];
	}
}

-(void)alertView: (UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex{
	//Login Request
	if ([[alertView title] isEqualToString:@"Login"] && [alertView cancelButtonIndex] != buttonIndex){
		NSString *emailText = [[[alertView subviews] objectAtIndex:4] text];
		NSString *passwordText = [[[alertView subviews] objectAtIndex:5] text];
		if (emailText == nil){
			emailText = @"";
		}
		if (passwordText == nil) {
			passwordText = @"";
		}
		
		NSMutableArray *details = [NSMutableArray arrayWithCapacity:2];
		[details addObject:emailText];
		[details addObject:passwordText];
		
		//Detach worker thread so that this function can exit and keyboard can disappear!!
		[NSThread detachNewThreadSelector: @selector(loginToStore:) toTarget:self withObject:details];
	}
	//Retry button after failed login
	else if ([[alertView title] isEqualToString:@""] && [alertView cancelButtonIndex] != buttonIndex){
		[self bookDeliverySlotAction:nil];
	}
}

-(void) loginToStore:(NSArray*)details {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	BOOL loginSuccessful = [DataManager loginToStore:[details objectAtIndex:0] withPassword:[details objectAtIndex:1]];
	if (!loginSuccessful) {
		[self performSelectorOnMainThread:@selector(hideLoadingOverlay) withObject:nil waitUntilDone:TRUE];
		[self performSelectorOnMainThread:@selector(showLoginError) withObject:nil waitUntilDone:TRUE];
	}else {
		//Save username and password in preferences
		[DataManager putUserPreference: @"login.email" andValue:[details objectAtIndex:0]];
		[DataManager putUserPreference: @"login.password" andValue:[details objectAtIndex:1]];
		
		//Dont want to perform this on main thread
		[self transmitBasket];
	}
	
	[pool release];
}

-(void) showLoginError {
	UIAlertView *loginError = [[UIAlertView alloc] initWithTitle: @"" message: @"Your Tesco login details were incorrect. Please try again." delegate: self cancelButtonTitle: @"Cancel" otherButtonTitles: @"Retry", nil];
	[loginError show];
	[loginError release];
}

-(void) transmitBasket {
	[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewLoadingText:) withObject:@"Adding products to Tesco.com basket" waitUntilDone:TRUE];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		//Add product basket to online basket
		[DataManager addProductBasketToStoreBasket];
		
		//Fetch delivery slots
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewLoadingText:) withObject:@"Fetching Delivery Slots" waitUntilDone:TRUE];
		[[LoadingView class] performSelectorOnMainThread:@selector(updateCurrentLoadingViewProgressText:) withObject:@"" waitUntilDone:TRUE];
		[self performSelectorOnMainThread:@selector(transitionToDeliverySelection:) withObject:[DataManager fetchAvailableDeliverySlots] waitUntilDone:FALSE];
	}@catch (id exception) {
		NSString *msg = [NSString stringWithFormat:@"Exception: '%@'.",exception];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CheckoutProductBasketViewController"];
	}@finally {
		[pool release];
	}
}

-(void) transitionToDeliverySelection:(NSArray*)deliverySlots{
	//Create next view
	if (checkoutChooseDeliveryDateController == nil) {
		CheckoutChooseDeliveryDateController *checkoutView = [[CheckoutChooseDeliveryDateController alloc] initWithNibName:@"CheckoutChooseDeliveryDateView" bundle:nil];
		[self setCheckoutChooseDeliveryDateController: checkoutView];
		[checkoutView release];
	}
	
	if ([deliverySlots count] == 0) {
		//Show error
		UIAlertView *apiError = [[UIAlertView alloc] initWithTitle: @"Tesco API error" message: @"Unable to fetch delivery slots. Please try logging in again" delegate: self cancelButtonTitle: @"Dismiss" otherButtonTitles: nil];
		[apiError show];
		[apiError release]; 
		
		//Hide loading screen
		[self hideLoadingOverlay];
	}else {
		//Hide loading overlay
		[self hideLoadingOverlay];
		
		//Set delivery slots for next view
		[checkoutChooseDeliveryDateController processDeliverySlots:deliverySlots];
		
		//Do transition
		RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		[[appDelegate checkoutViewNavController] pushViewController:checkoutChooseDeliveryDateController animated:YES];
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

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[productBasketTableView release];
	[footerView release];
	[checkoutChooseDeliveryDateController release];
    [super dealloc];
}

@end

