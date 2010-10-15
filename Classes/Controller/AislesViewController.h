//
//  AislesViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 12/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShelvesViewController.h"

@interface AislesViewController : UITableViewController {
	IBOutlet UITableView *aislesView;
@private NSMutableArray *aisles;
}

@property (nonatomic, retain) NSString *department;
@property (nonatomic, retain) ShelvesViewController *shelvesViewController;

@end
