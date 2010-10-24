//
//  RecipeHistoryViewController.m
//  RecipeShopper
//
//  Created by Simon Barnett on 13/10/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "RecipeHistoryViewController.h"
#import "DataManager.h"
#import "UITableViewCellFactory.h"
#import "RecipeShopperAppDelegate.h"

@implementation RecipeHistoryViewController

@synthesize recipeViewController;
@synthesize recentRecipes;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[recipeHistoryView setBackgroundColor: [UIColor clearColor]];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self setRecentRecipes:[DataManager getRecentRecipes]];
	[recipeHistoryView reloadData];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	/* transition to recipe view when webview has finished loading */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:[self recipeViewController] animated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([recentRecipes count] == 0)? 1:[recentRecipes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == 0) {
		return ([recentRecipes count] == 0)? 130:110;
	}else {
		return 85;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* create a cell for this row's recipe */
	if ([recentRecipes count] != 0) {
		[recipeHistoryView setAllowsSelection:YES];
		Recipe *recipe = [recentRecipes objectAtIndex:[indexPath row]];
		
		[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier withRecipe:recipe isHeader:([indexPath row] == 0)];
	}else { /* Create special empty history cell */
		[recipeHistoryView setAllowsSelection:NO];
		 NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"RecipeHistoryEmpty" owner:self options:nil];
		
		for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				cell = (UITableViewCell *)viewElement;
		}
	}
	
	UILabel *headerLabel = (UILabel *)[cell viewWithTag:4];
	[headerLabel setText:@"Recent Recipes"];
	
    return cell;	
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([recentRecipes count] == 0) {
		return;
	}
	if (recipeViewController == nil) {
		RecipeViewController *recipeView = [[RecipeViewController alloc] initWithNibName:@"RecipeView" bundle:nil];
		[self setRecipeViewController:recipeView];
		[recipeView release];
	}
	
	[recipeHistoryView deselectRowAtIndexPath:indexPath animated:YES];
	
	/* force view to load all resources before its pushed on to main view stack */
	[[recipeViewController view] setHidden:FALSE];
	[recipeViewController processViewForRecipe:[recentRecipes objectAtIndex:[indexPath row]] withWebViewDelegate:self];
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

