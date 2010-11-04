//
//  DeliverySlot.h
//  RecipeShopper
//
//  Created by Simon Barnett on 17/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeliverySlot : NSObject {
}

@property (readonly,copy) NSString *deliverySlotID;
@property (readonly,copy) NSString *deliverySlotBranchNumber;
@property (readonly,copy) NSDate *deliverySlotDate;
@property (readonly,copy) NSDate *deliverySlotStartTime;
@property (readonly,copy) NSDate *deliverySlotEndTime;
@property (readonly,copy) NSString *deliverySlotCost;

- (id)initWithDeliverySlotID:(NSString *)inDeliverySlotID andDeliverySlotBranchNumber:(NSString *)inDeliverySlotBranchNumber 
	andDeliverySlotDate:(NSDate *)inDeliverySlotDate andDeliverySlotStartTime:(NSDate *)inDeliverySlotStartTime
	  andDeliverySlotEndTime:(NSDate *)inDeliverySlotEndTime andDeliverySlotCost:(NSString *)inDeliverySlotCost;

@end
