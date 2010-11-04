//
//  DeliverySlotsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 17/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeliverySlot.h"
#import "DataManager.h"

@interface DeliverySlotsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
	IBOutlet UITableView *deliveryInfoView;
	IBOutlet UIPickerView *deliverySlotPickerView;
	
@private 
	DataManager *dataManager;
	NSDictionary *deliveryDates;
	NSMutableArray *sortedDeliveryDatesArray;
	DeliverySlot *selectedDeliverySlot;
	BOOL deliveryTimesReset;
}

- (void)loadDeliveryDates;

@end
