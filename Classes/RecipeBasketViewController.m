//
//  RecipeBasketViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "RecipeBasketViewController.h"
#import "RecipeShopperAppDelegate.h"
#import "UITableViewCellFactory.h"
#import "DataManager.h"

@interface RecipeBasketViewController()

- (void)transitionToShoppingListView:(id)sender;

@end

@implementation RecipeBasketViewController

@synthesize recipeViewController;
@synthesize shoppingListViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	/* make sure we reload the table data each time we see the view in case a new recipe has been added */
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Recipe Basket";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [DataManager getRecipeBasketCount];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* create a cell for this row's recipe */
	Recipe *recipe = [DataManager getRecipeFromBasket:[indexPath row]];
	[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier withRecipe:recipe];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 76;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (footerView == nil) {
        footerView = [[UIView alloc] init];
		
		UIImage *shoppingListButtonImage = [[UIImage imageNamed:@"button_green.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
		/* create the shopping list button */
		UIButton *shoppingListButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[shoppingListButton setBackgroundImage:shoppingListButtonImage forState:UIControlStateNormal];
		
		//the button should be as big as a table view cell
		[shoppingListButton setFrame:CGRectMake(10, 16, 300, 44)];
		
		[shoppingListButton setTitle:@"Shopping List" forState:UIControlStateNormal];
		[[shoppingListButton titleLabel] setFont:[UIFont boldSystemFontOfSize:20]];
		[shoppingListButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		/* set action of the button */
		[shoppingListButton addTarget:self action:@selector(transitionToShoppingListView:) forControlEvents:UIControlEventTouchUpInside];
		
		/* add the button to the view */
		[footerView addSubview:shoppingListButton];
    }
	
    return footerView;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* delete the recipe from the recipe basket */
		[DataManager removeRecipeFromBasket:[DataManager getRecipeFromBasket:[indexPath row]]];

		/* delete the row from the view */
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/* show the recipe */
	if (recipeViewController == nil) {
		RecipeViewController *recipeView = [[RecipeViewController alloc] initWithNibName:@"RecipeView" bundle:nil];
		[self setRecipeViewController:recipeView];
		[recipeView release];
	}
	
	[recipeBasketTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[[recipeViewController view] setHidden:FALSE];
	[recipeViewController processViewForRecipe:[DataManager getRecipeFromBasket:[indexPath row]] withWebViewDelegate:self];
}

#pragma mark -
#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	/* transition to recipe view when webview has finished loading */
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate recipeBasketViewController] pushViewController:[self recipeViewController] animated:YES];
}

#pragma mark -
#pragma mark Private methods
- (void)transitionToShoppingListView:(id)sender {
	if (shoppingListViewController == nil) {
		ShoppingListViewController *shoppingListView = [[ShoppingListViewController alloc] initWithNibName:@"ShoppingListView" bundle:nil];
		[self setShoppingListViewController:shoppingListView];
		[shoppingListView release];
	}
	
	RecipeShopperAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	[[appDelegate recipeBasketViewController] pushViewController:shoppingListViewController animated:YES];
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
	[footerView release];
    [super dealloc];
}


@end

