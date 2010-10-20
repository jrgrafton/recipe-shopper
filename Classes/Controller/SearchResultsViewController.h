//
//  SearchResultsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 20/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchResultsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
	IBOutlet UISearchBar *searchBarView;
	IBOutlet UITableView *searchResultsView;
@private NSMutableArray *searchResults;
@private int currentPage;
@private int totalPageCount;
}

@property (nonatomic, retain) NSString *searchTerm;

- (void)newSearch;

@end