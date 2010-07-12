//
//  HomeStoreViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface HomeStoreViewController : UITableViewController {
	IBOutlet UITableView *homeStoreTableView;
	IBOutlet UISearchBar *searchBar;

	@private
	BOOL busyFetchingClosestStores;
	LoadingView *loadingView;
	NSArray *closestStores;
}

@end
