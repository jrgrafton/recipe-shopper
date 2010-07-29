//
//  CheckoutAddProductViewController.h
//  RecipeShopper
//
//  Created by User on 7/11/10.
//  Copyright 2010 Asset Enhancing Software Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckoutProductBasketViewController.h"
#import "LoadingView.h"

@interface CheckoutAddProductViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	IBOutlet UITableView *productSearchTableView;
	UIView *footerView;
	IBOutlet UISearchBar *searchBar;
	IBOutlet UINavigationBar *navigationBar;
	id <PreviousViewControllerDelegate> delegate;
	
	@private
	LoadingView *loadingView;
	NSArray *foundProducts;
	NSInteger currentPage;
	NSInteger maxPage;
	NSString *lastSearchTerm;
}

@property (nonatomic, assign) id <PreviousViewControllerDelegate> delegate;

- (IBAction)actionDone;

@end
