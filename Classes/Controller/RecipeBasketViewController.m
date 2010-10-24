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

@implementation RecipeBasketViewController

@synthesize recipeViewController;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	//Add logo to nav bar
	UIImage *image = [UIImage imageNamed: @"header.png"];
	UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
	self.navigationItem.titleView = imageView;
	[imageView release];
	
	[recipeBasketTableView setBackgroundColor: [UIColor clearColor]];
	
	//[[self navigationItem] setTitle:@"Recipe Basket"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

	/* make sure we reload the table data each time we see the view in case a new recipe has been added */
	[recipeBasketTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath row] == 0) {
		return ([DataManager getRecipeBasketCount] == 0)? 130:110;
	}else {
		return 85;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([DataManager getRecipeBasketCount] == 0)? 1 : [DataManager getRecipeBasketCount];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"RecipeCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* create a cell for this row's recipe */
	
	if([DataManager getRecipeBasketCount] != 0) {
		[recipeBasketTableView setAllowsSelection:YES];
		Recipe *recipe = [DataManager getRecipeFromBasket:[indexPath row]];
		[UITableViewCellFactory createRecipeTableCell:&cell withIdentifier:CellIdentifier withRecipe:recipe isHeader:([indexPath row] == 0)];
	} else { /* Create special empty basket cell */
		[recipeBasketTableView setAllowsSelection:NO];
		NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"RecipeBasketEmpty" owner:self options:nil];
		
		for (id viewElement in bundle) {
			if ([viewElement isKindOfClass:[UITableViewCell class]])
				cell = (UITableViewCell *)viewElement;
		}
	}
	
	UILabel *headerLabel = (UILabel *)[cell viewWithTag:4];
	[headerLabel setText:@"Recipe Basket"];
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([DataManager getRecipeBasketCount] != 0);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        /* delete the recipe from the recipe basket */
		[DataManager removeRecipeFromBasket:[DataManager getRecipeFromBasket:[indexPath row]]];

		/* delete the row from the view */
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		[tableView reloadData];
    }
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([DataManager getRecipeBasketCount] == 0) {
		return;
	}
	
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

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [recipeBasketTableView cellForRowAtIndexPath:indexPath];
	UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
	[titleLabel setFrame:CGRectMake([titleLabel frame].origin.x,[titleLabel frame].origin.y,[titleLabel frame].size.width - 40,[titleLabel frame].size.height)];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [recipeBasketTableView cellForRowAtIndexPath:indexPath];
	UILabel *titleLabel = (UILabel*)[cell viewWithTag:2];
	[titleLabel setFrame:CGRectMake([titleLabel frame].origin.x,[titleLabel frame].origin.y,[titleLabel frame].size.width + 40,[titleLabel frame].size.height)];
}

#pragma mark -
#pragma mark UIWebView delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	/* transition to recipe view when webview has finished loading */
	RecipeShopperAppDelegate *appDelegate = (RecipeShopperAppDelegate *)[[UIApplication sharedApplication] delegate];
	[[appDelegate homeViewController] pushViewController:[self recipeViewController] animated:YES];
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

