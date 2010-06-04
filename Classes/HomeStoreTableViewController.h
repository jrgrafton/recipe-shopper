//
//  HomeStoreTableViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 5/24/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"


@interface HomeStoreTableViewController : UITableViewController {
	IBOutlet UITableView *homeStoreTableView;
	
	@private
	BOOL busyFetchingClosestStores;
	LoadingView *loadingView;
}

@end
