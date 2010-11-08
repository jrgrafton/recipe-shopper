//
//  ProductsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 13/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"

typedef enum ProductViewFor
{
	PRODUCT_SEARCH,
	PRODUCT_SHELF
} ProductViewFor;

@interface ProductsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *productsView;
	
@private 
	DataManager *dataManager;
	NSMutableArray *products;
	NSInteger totalPageCount;
	UIView *footerView;
}

@property (nonatomic, retain) NSString *productTerm;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) ProductViewFor productViewFor;

- (void)loadProducts;

@end
