//
//  CheckoutRecipeBasketViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/11/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonSpecificRecipeViewController.h"


@interface CheckoutRecipeBasketViewController : UITableViewController {
	IBOutlet UITableView *recipeBasketTableView;
	CommonSpecificRecipeViewController *commonSpecificRecipeViewController;
}

@property (nonatomic,retain) CommonSpecificRecipeViewController *commonSpecificRecipeViewController;

@end
