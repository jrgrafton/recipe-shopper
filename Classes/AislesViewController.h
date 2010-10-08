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
@private NSArray *aisles;
	
}

@property (nonatomic, retain) ShelvesViewController *shelvesViewController;

- (void)loadAislesForDepartment:(NSString *)department;

@end
