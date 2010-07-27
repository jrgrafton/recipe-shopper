    //
//  APIBookingSlot.m
//  RecipeShopper
//
//  Created by User on 7/20/10.
//  Copyright 2010 Asset Enhancing Software Software. All rights reserved.
//

#import "APIDeliverySlot.h"

@interface APIDeliverySlot ()
@property (readwrite,copy) NSString *deliverySlotID;
@property (readwrite,copy) NSString *deliverySlotBranchNumber;
@property (readwrite,copy) NSDate *deliverySlotStartDate;
@property (readwrite,copy) NSDate *deliverySlotEndDate;
@property (readwrite,copy) NSString *deliverySlotCost;
@end

@implementation APIDeliverySlot

@synthesize deliverySlotID,deliverySlotBranchNumber,deliverySlotStartDate,deliverySlotEndDate,deliverySlotCost;

- (id)initWithDeliverySlotID: (NSString*)inDeliverySlotID andDeliverySlotBranchNumber:(NSString*)inDeliverySlotBranchNumber 
		andDeliverySlotStartDate:(NSDate*)inDeliverySlotStartDate andDeliverySlotEndDate:(NSDate*)inDeliverySlotEndDate 
		 andDeliverySlotCost:(NSString*)inDeliverySlotCost{
	
	if (self = [super init]) {
		[self setDeliverySlotID:inDeliverySlotID];
		[self setDeliverySlotBranchNumber:inDeliverySlotBranchNumber];
		[self setDeliverySlotStartDate:inDeliverySlotStartDate];
		[self setDeliverySlotEndDate:inDeliverySlotEndDate];
		[self setDeliverySlotCost:inDeliverySlotCost];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"DeliverySlot: ID=%@ Branch=%@ Start=%@ End=%@ Cost=%@",deliverySlotID,deliverySlotBranchNumber,deliverySlotStartDate,deliverySlotEndDate,deliverySlotCost];
}

- (NSComparisonResult) compareByDeliverySlotStart:(APIDeliverySlot *)obj
{
    NSComparisonResult retVal = NSOrderedSame;
	
    if ( [[self deliverySlotStartDate] earlierDate:[obj deliverySlotStartDate]]){
		retVal = NSOrderedAscending;
	}
    else if ([[self deliverySlotStartDate] laterDate:[obj deliverySlotStartDate]]){
		retVal = NSOrderedDescending;
	}
	
    return retVal;
}

- (void)dealloc {
	[deliverySlotID release];
	[deliverySlotBranchNumber release];
	[deliverySlotStartDate release];
	[deliverySlotEndDate release];
	[deliverySlotCost release];
    [super dealloc];
}


@end
