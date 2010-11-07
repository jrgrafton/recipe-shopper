//
//  ProductsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

@interface ProductsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *productsView;
	
@private 
	DataManager *dataManager;
	NSMutableArray *products;
	NSInteger totalPageCount;
	UIView *footerView;
}

@property (nonatomic, retain) NSString *productShelf;
@property (nonatomic, assign) NSInteger currentPage;

- (void)loadProducts;

@end
