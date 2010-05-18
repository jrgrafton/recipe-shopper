//
//  HomeTableViewController.h
//  RecipeShopper
//
//  Created by James Grafton on 5/18/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HomeTableViewController : UITableViewController <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet UITableView *homeTableView;
}

@end
