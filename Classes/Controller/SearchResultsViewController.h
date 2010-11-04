//
//  SearchResultsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface SearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	IBOutlet UISearchBar *searchBarView;
	IBOutlet UITableView *searchResultsView;
	
@private 
	DataManager *dataManager;
	UIView *footerView;
	NSMutableArray *searchResults;
	NSInteger currentPage;
	NSInteger totalPageCount;
}

@property (nonatomic, retain) NSString *searchTerm;

- (void)newSearch;

@end
