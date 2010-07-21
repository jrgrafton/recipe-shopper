//
//  APIBookingSlot.h
//  RecipeShopper
//
//  Created by User on 7/20/10.
//  Copyright 2010 Assent Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface APIDeliverySlot : NSObject {
	NSString *deliverySlotID;
	NSString *deliverySlotBranchNumber;
	NSDate *deliverySlotStartDate;
	NSDate *deliverySlotEndDate;
	NSString *deliverySlotCost;
}

@property (readonly,copy) NSString *deliverySlotID;
@property (readonly,copy) NSString *deliverySlotBranchNumber;
@property (readonly,copy) NSDate *deliverySlotStartDate;
@property (readonly,copy) NSDate *deliverySlotEndDate;
@property (readonly,copy) NSString *deliverySlotCost;


- (id)initWithDeliverySlotID: (NSString*)inDeliverySlotID andDeliverySlotBranchNumber:(NSString*)inDeliverySlotBranchNumber 
		 andDeliverySlotStartDate:(NSDate*)inDeliverySlotStartDate andDeliverySlotEndDate:(NSDate*)inDeliverySlotEndDate 
	 andDeliverySlotCost:(NSString*)inDeliverySlotCost;

- (NSComparisonResult) compareByDeliverySlotStart:(APIDeliverySlot *)obj;

@end
