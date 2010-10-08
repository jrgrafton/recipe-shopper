//
//  RecipeBasketViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 05/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecipeViewController.h"
#import "ShoppingListViewController.h"

@interface RecipeBasketViewController : UITableViewController <UIWebViewDelegate> {
	IBOutlet UITableView *recipeBasketTableView;
@private UIView *footerView;
}

@property (nonatomic, retain) RecipeViewController *recipeViewController;
@property (nonatomic, retain) ShoppingListViewController *shoppingListViewController;

- (void)transitionToShoppingListView:(id)sender;

@end
