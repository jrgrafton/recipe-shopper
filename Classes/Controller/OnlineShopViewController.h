//
//  OnlineShopViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AislesViewController.h"
#import "DataManager.h"

@interface OnlineShopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	IBOutlet UISearchBar *searchBarView;
	IBOutlet UITableView *onlineShopView;
@private 
	DataManager *dataManager;
	NSDictionary *departmentImages;
}

@property (nonatomic, retain) AislesViewController *aislesViewController;
@property (nonatomic, retain) ProductsViewController *searchResultsViewController;
@property (nonatomic, retain) NSArray *departments;

@end
