//
//  DeliverySlot.m
//  RecipeShopper
//
//  Created by Simon Barnett on 17/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "DeliverySlot.h"

@interface DeliverySlot ()

@property (readwrite,copy) NSString *deliverySlotID;
@property (readwrite,copy) NSString *deliverySlotBranchNumber;
@property (readwrite,copy) NSDate *deliverySlotDate;
@property (readwrite,copy) NSDate *deliverySlotStartTime;
@property (readwrite,copy) NSDate *deliverySlotEndTime;
@property (readwrite,copy) NSString *deliverySlotCost;

@end

@implementation DeliverySlot

@synthesize deliverySlotID;
@synthesize deliverySlotBranchNumber;
@synthesize deliverySlotDate;
@synthesize deliverySlotStartTime;
@synthesize deliverySlotEndTime;
@synthesize deliverySlotCost;

- (id)initWithDeliverySlotID:(NSString *)inDeliverySlotID andDeliverySlotBranchNumber:(NSString *)inDeliverySlotBranchNumber 
	andDeliverySlotDate:(NSDate *)inDeliverySlotDate andDeliverySlotStartTime:(NSDate *)inDeliverySlotStartTime
	  andDeliverySlotEndTime:(NSDate *)inDeliverySlotEndTime andDeliverySlotCost:(NSString *)inDeliverySlotCost {
	if (self = [super init]) {
		[self setDeliverySlotID:inDeliverySlotID];
		[self setDeliverySlotBranchNumber:inDeliverySlotBranchNumber];
		[self setDeliverySlotDate:inDeliverySlotDate];
		[self setDeliverySlotStartTime:inDeliverySlotStartTime];
		[self setDeliverySlotEndTime:inDeliverySlotEndTime];
		[self setDeliverySlotCost:inDeliverySlotCost];
	}
	
	return self;
}

- (void)dealloc {
	[deliverySlotID release];
	[deliverySlotBranchNumber release];
	[deliverySlotDate release];
	[deliverySlotStartTime release];
	[deliverySlotEndTime release];
	[deliverySlotCost release];
    [super dealloc];
}


@end