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
#import "DataManager.h"

@interface RecipeBasketViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIWebViewDelegate> {
	IBOutlet UITableView *recipeBasketTableView;
	
@private
	DataManager *dataManager;
}

@property (nonatomic, retain) RecipeViewController *recipeViewController;

@end
