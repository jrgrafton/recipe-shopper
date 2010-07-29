//
//  CheckoutRecipeBasketViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 6/11/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonSpecificRecipeViewController.h"
#import "CheckoutProductBasketViewController.h"
#import "LoadingView.h"


@interface CheckoutRecipeBasketViewController : UITableViewController <UIWebViewDelegate>{
	IBOutlet UITableView *recipeBasketTableView;
	CommonSpecificRecipeViewController *commonSpecificRecipeViewController;
	CheckoutProductBasketViewController *checkoutProductBasketViewController;
	
	UIView *footerView;
	
	@private
	LoadingView *loadingView;
}

@property (nonatomic,retain) CommonSpecificRecipeViewController *commonSpecificRecipeViewController;
@property (nonatomic,retain) CheckoutProductBasketViewController *checkoutProductBasketViewController;

@end
