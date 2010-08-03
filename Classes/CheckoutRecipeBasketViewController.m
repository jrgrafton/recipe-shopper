//
//  CheckoutRecipeBasketViewController.m
//  RecipeShopper
//
//  Created by James Grafton on 6/11/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "CheckoutRecipeBasketViewController.h"
#import "DataManager.h"
#import "RecipeShopperAppDelegate.h"
#import "LogManager.h"
#import "UITableViewCellFactory.h"


@interface CheckoutRecipeBasketViewController ()
//Private class functions
- (void) createProductList:(id)sender;
- (void) verifyProductBasket;
- (void) transitionToProductPage;
- (void) showLoadingOverlay;
- (void) hideLoadingOverlay;
@end

@implementation CheckoutRecipeBasketViewController

@synthesize commonSpecificRecipeViewController,checkoutProductBasketViewController;

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
	[recipeBasketTableView setBackgroundColor: [UIColor colorWithRed:0.8745098039215686 
														   green:0.9137254901960784 
															blue:0.9568627450980392
														   alpha:1.0]];
	
	self.title = NSLocalizedString(@"Recipe Basket", @"Current recipe basket");
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	//Ensure loading overlay is removed
	[self hideLoadingOverlay];
}

-(void)showLoadingOverlay {
	loadingView = [LoadingView loadingViewInView:(UIView *)recipeBasketTableView withText:@"Verifying Products..." 
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
}



#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[DataManager getRecipeBasket]count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"Recipe List";
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    return 90;
}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 76;
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
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
		[button setTitle:@"Create Product List" forState:UIControlStateNormal];
		[[button titleLabel] setFont:[UIFont boldSystemFontOfSize:20]];
		[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//set action of the button
		[button addTarget:self action:@selector(createProductList:)
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
    
    // Set up the cell...
	NSMutableArray *recipeBasket = [DataManager getRecipeBasket];
	DBRecipe *recipeObject = [recipeBasket objectAtIndex:[indexPath row]];
	[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier usingRecipeObject:recipeObject];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Open specific recipe view
	if (commonSpecificRecipeViewController == nil) {
		CommonSpecificRecipeViewController *specificRecipeView = [[CommonSpecificRecipeViewController alloc] initWithNibName:@"CommonSpecificRecipeView" bundle:nil];
		[self setCommonSpecificRecipeViewController: specificRecipeView];
		[specificRecipeView release];
	}
	[recipeBasketTableView  deselectRowAtIndexPath:indexPath  animated:YES];
	
	//This forces view to load all resources before its pushed on to main view stack
	[[commonSpecificRecipeViewController view] setHidden:FALSE];
	[commonSpecificRecipeViewController processViewForRecipe:[[DataManager getRecipeBasket] objectAtIndex:[indexPath row]] withWebViewDelegate:self];
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
		[[DataManager getRecipeBasket] removeObjectAtIndex:[indexPath row]];
		
		//Decrement badge number
		RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
		UITabBarController *rootController = [appDelegate rootController];
		[[rootController.tabBar.items objectAtIndex:2] setBadgeValue: [NSString stringWithFormat:@"%d",[[DataManager getRecipeBasket]count]]];
		
		if ([[DataManager getRecipeBasket] count] == 0) {
			[[rootController.tabBar.items objectAtIndex:2] setBadgeValue: NULL];
		}
		
		
		// Delete row from table view
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	//Only transition when webview has finished loading
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewNavController] pushViewController:[self commonSpecificRecipeViewController] animated:YES];
}

#pragma mark -
#pragma mark Additional Instance Functions

- (void) createProductList:(id)sender {
	if ([DataManager phoneIsOnline] && [[DataManager getRecipeBasket] count] > 0){
		//Perform product verification
		[recipeBasketTableView setScrollEnabled:FALSE];
		[self showLoadingOverlay];
		[NSThread detachNewThreadSelector: @selector(verifyProductBasket) toTarget:self withObject:nil];
	}else if([[DataManager getRecipeBasket] count] > 0){
		//Phone is offline but we have recipes in basket
		[DataManager createProductListFromRecipeBasket];
		[self transitionToProductPage];
	}else{
		//Phone is offline and we have empty basket (just transition to next view!!)
		[self transitionToProductPage];
	}
}

-(void)verifyProductBasket {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	@try {
		[DataManager createProductListFromRecipeBasket];
		[self performSelectorOnMainThread:@selector(transitionToProductPage) withObject:nil waitUntilDone:TRUE];
	}@catch (id exception) {
		NSString *msg = [NSString stringWithFormat:@"Exception: '%@'.",exception];
		[LogManager log:msg withLevel:LOG_ERROR fromClass:@"CheckoutRecipeBasketViewController"];
	}@finally {
		[pool release];
	}
}

-(void)transitionToProductPage {
	[recipeBasketTableView setScrollEnabled:TRUE];
	[self hideLoadingOverlay];
	
	if (checkoutProductBasketViewController == nil) {
		CheckoutProductBasketViewController *productBasketView = [[CheckoutProductBasketViewController alloc] initWithNibName:@"CheckoutProductBasketView" bundle:nil];
		[self setCheckoutProductBasketViewController: productBasketView];
		[productBasketView release];
	}
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewNavController] pushViewController:checkoutProductBasketViewController animated:YES];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[commonSpecificRecipeViewController release];
	[footerView release];
    [super dealloc];
}


@end

