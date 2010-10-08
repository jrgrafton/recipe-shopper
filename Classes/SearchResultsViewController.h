//
//  SearchResultsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UITableViewController <UISearchBarDelegate> {

	IBOutlet UISearchBar *searchBarView;
	IBOutlet UITableView *searchResultsView;
@private UIView *footerView;
@private NSMutableArray *searchResults;
@private int currentPage;
@private int totalPageCount;
	
}

@property (nonatomic, retain) NSString *searchTerm;

@end
