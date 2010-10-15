//
//  DeliverySlotsViewController.h
//  RecipeShopper
//
//  Created by Simon Barnett on 17/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeliverySlot.h"

@interface DeliverySlotsViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate> {
	
	IBOutlet UITableView *deliveryInfoView;
	IBOutlet UIPickerView *deliverySlotPickerView;
@private NSDictionary *deliveryDates;
@private NSMutableArray *sortedDeliveryDatesArray;
@private DeliverySlot *selectedDeliverySlot;

}

- (void)loadDeliveryDates;

@end
