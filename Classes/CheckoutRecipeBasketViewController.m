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


@interface CheckoutRecipeBasketViewController ()
//Private class functions
- (void) createProductList:(id)sender;
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


- (void)viewDidLoad {
    [super viewDidLoad];
	
	//Add Tesco logo to nav bar
	UIImage *image = [UIImage imageNamed: @"tesco_header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataManager getRecipeBasketSize];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
	return @"Recipe List";
}

- (CGFloat) tableView: (UITableView *) tableView heightForRowAtIndexPath: (NSIndexPath *) indexPath{
    return 60;
}

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value
    return 50;
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
		[button setFrame:CGRectMake(10, 3, 300, 44)];
		
		//set title, font size and font color
		[button setTitle:@"Create Product List" forState:UIControlStateNormal];
		[button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
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
	[[cell textLabel] setText: [recipeObject recipeName]];
	[[cell textLabel] setFont:[UIFont boldSystemFontOfSize:14]];
	[[cell imageView] setImage: [recipeObject iconSmall]];
	cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
	
	
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
	[commonSpecificRecipeViewController processViewForRecipe:[[DataManager getRecipeBasket] objectAtIndex:[indexPath row]]];
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewNavController] pushViewController:commonSpecificRecipeViewController animated:YES];
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
		[[rootController.tabBar.items objectAtIndex:2] setBadgeValue: [NSString stringWithFormat:@"%d",[DataManager getRecipeBasketSize]]];
		
		if ([DataManager getRecipeBasketSize] == 0) {
			[[rootController.tabBar.items objectAtIndex:2] setBadgeValue: NULL];
		}
		
		
		// Delete row from table view
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


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

- (void) createProductList:(id)sender {
	NSMutableDictionary *productIDToCountMap = [NSMutableDictionary dictionary];
	NSArray *recipeBasket = [DataManager getRecipeBasket];
	
	//First figure out total for all products we need and fetch them from the DB
	for (DBRecipe *recipe in recipeBasket) {
		NSArray *productIDs = [recipe idProducts];
		
		NSUInteger productIndex = 0;
		for (NSNumber *productID in productIDs){
			NSNumber *productCount = [[recipe idProductsQuantity] objectAtIndex:productIndex];
			for (int i=0; i<[productCount intValue]; i++) {
				NSNumber *productTotalCount = [productIDToCountMap objectForKey:productID];
				if (productTotalCount == nil) {
					[productIDToCountMap setObject:[NSNumber numberWithInt:1] forKey:productID];
				}else{
					productTotalCount = [NSNumber numberWithInt:[productTotalCount intValue] + 1];
					[productIDToCountMap setObject:productTotalCount forKey:productID];
				}
			}
			productIndex++;
		}
	}
	
	//Now add all the DBProduct objects to the product basket
	NSArray *individualProducts = [DataManager fetchProductsFromIDs:[productIDToCountMap allKeys]];
	
	for (DBProduct *product in individualProducts) {
		NSNumber *productCount = [productIDToCountMap objectForKey:[NSString stringWithFormat:@"%d",[product productBaseID]]];
		
	    for (int i=0; i<[productCount intValue]; i++) {
			[DataManager addProductToBasket:product];
		}
	}
	
	//Open product basket view
	if (checkoutProductBasketViewController == nil) {
		CheckoutProductBasketViewController *productBasketView = [[CheckoutProductBasketViewController alloc] initWithNibName:@"CheckoutProductBasketView" bundle:nil];
		[self setCheckoutProductBasketViewController: productBasketView];
		[productBasketView release];
	}
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate checkoutViewNavController] pushViewController:checkoutProductBasketViewController animated:YES];
}

- (void)dealloc {
	[commonSpecificRecipeViewController release];
	[footerView release];
    [super dealloc];
}


@end

