//
//  APIPaymentPageInfo.m
//  RecipeShopper
//
//  Created by James Grafton on 8/10/10.
//  Copyright 2010  Assentec Global. All rights reserved.
//

#import "APIPaymentPageInfo.h"

@interface APIPaymentPageInfo ()
@property (readwrite,assign) struct AddressInfo deliveryAddressInfo;
@property (readwrite,copy) NSString *deliveryDateHTML;
@property (readwrite,copy) NSString *totalSavings;
@property (readwrite,copy) NSString *totalItems;
@property (readwrite,copy) NSString *deliveryCharge;
@property (readwrite,copy) NSString *subtotal;
@property (readwrite,copy) NSString *totalClubcardPoints;
@property (readwrite,copy) NSString *totalPromotionalPoints;

@property (readwrite,copy) NSArray *cardholderAddressAliases;
@property (readwrite,copy) NSString *telephoneNumber;
@property (readwrite,copy) NSString *alternativeTelephoneNumber;
@property (readwrite,copy) NSString *mobileNumber;
@end

@implementation APIPaymentPageInfo

@synthesize deliveryAddressInfo,deliveryDateHTML,totalSavings,totalItems,deliveryCharge,subtotal,totalClubcardPoints,totalPromotionalPoints,cardholderAddressAliases,telephoneNumber,alternativeTelephoneNumber,mobileNumber;

- (id)initWithDeliveryAddressInfo: (AddressInfo)inDeliveryAddressInfo andDeliveryDateHTML:(NSString*)inDeliveryDateHTML 
			andTotalSavings:(NSString*)inTotalSavings andTotalItems:(NSString*)inTotalItems 
			andDeliveryCharge:(NSString*)inDeliveryCharge andSubtotal:(NSString*)inSubtotal
			andTotalClubcardPoints:(NSString*)inTotalClubcardPoints andTotalPromotionalPoints:(NSString*)inTotalPromotionalPoints
			andCardholderAddressAliases:(NSArray*)inCardholderAddressAliases andTelephoneNumber:(NSString*)inTelephoneNumber
			andAlternativeTelephoneNumber:(NSString*)inAlternativeTelephoneNumber andMobileNumber:(NSString*)inMobileNumber{

	if (self = [super init]) {
		[self setDeliveryAddressInfo:inDeliveryAddressInfo];
		[self setDeliveryDateHTML:inDeliveryDateHTML];
		[self setTotalSavings:inTotalSavings];
		[self setTotalItems:inTotalItems];
		[self setDeliveryCharge:inDeliveryCharge];
		[self setSubtotal:inSubtotal];
		[self setTotalClubcardPoints:inTotalClubcardPoints];
		[self setTotalPromotionalPoints:inTotalPromotionalPoints];
		[self setCardholderAddressAliases:inCardholderAddressAliases];
		[self setTelephoneNumber:inTelephoneNumber];
		[self setAlternativeTelephoneNumber:inAlternativeTelephoneNumber];
		[self setMobileNumber:inMobileNumber];
	}
	return self;
}

- (void)dealloc {
	[deliveryDateHTML release];
	[totalSavings release];
	[totalItems release];
	[deliveryCharge release];
	[subtotal release];
	[totalClubcardPoints release];
	[totalPromotionalPoints release];
	[cardholderAddressAliases release];
	[telephoneNumber release];
	[alternativeTelephoneNumber release];
	[mobileNumber release];
    [super dealloc];
}

@end
