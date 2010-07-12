//
//  CheckoutAddProductViewController.h
//  RecipeShopper
//
//  Created by User on 7/11/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckoutProductBasketViewController.h"
#import "LoadingView.h"

@interface CheckoutAddProductViewController : UITableViewController {
	IBOutlet UITableView *productSearchTableView;
	IBOutlet UISearchBar *searchBar;
	IBOutlet UINavigationBar *navigationBar;
	id <PreviousViewControllerDelegate> delegate;
	
	@private
	BOOL busyFindingProducts;
	LoadingView *loadingView;
	NSArray *foundProducts;
}

@property (nonatomic, assign) id <PreviousViewControllerDelegate> delegate;

- (IBAction)actionDone;

@end
