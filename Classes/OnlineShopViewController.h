//
//  OnlineShopViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AislesViewController.h"
#import "OnlineBasketViewController.h"
#import "SearchResultsViewController.h"

@interface OnlineShopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {

	IBOutlet UISearchBar *searchBarView;
	IBOutlet UITableView *onlineShopView;
@private NSArray *departments;
@private NSDictionary *departmentImages;
@private BOOL letUserSelectRow;

}

@property (nonatomic, retain) AislesViewController *aislesViewController;
@property (nonatomic, retain) OnlineBasketViewController *onlineBasketViewController;
@property (nonatomic, retain) SearchResultsViewController *searchResultsViewController;

- (void)overlayViewTouched;

@end
