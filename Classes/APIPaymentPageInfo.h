//
//  APIPaymentPageInfo.h
//  RecipeShopper
//
//  Created by James Grafton on 8/10/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <UIKit/UIKit.h>

struct AddressInfo {
	NSString *addressAlias;
	NSArray *addressLines;
};
typedef struct AddressInfo AddressInfo;

CG_INLINE AddressInfo
AddressInfoMake(NSString* addressAlias, NSArray* addressLines)
{
	AddressInfo addressInfo; addressInfo.addressAlias = addressAlias; addressInfo.addressLines = addressLines; return addressInfo;
}

@interface APIPaymentPageInfo : NSObject {
	//Top Panel of our page
	AddressInfo deliveryAddressInfo;
	NSString *deliveryDateHTML;
	NSString *totalSavings;
	NSString *totalItems;
	NSString *deliveryCharge;
	NSString *subtotal;
	NSString *totalClubcardPoints;
	NSString *totalPromotionalPoints;
	
	//Will probably need something for middle panel at some point
	
	//Bottom Panel of our page
	NSArray *cardholderAddressAliases;
	NSString *telephoneNumber;
	NSString *alternativeTelephoneNumber;
	NSString *mobileNumber;
}


@property (readonly,assign) struct AddressInfo deliveryAddressInfo;
@property (readonly,copy) NSString *deliveryDateHTML;
@property (readonly,copy) NSString *totalSavings;
@property (readonly,copy) NSString *totalItems;
@property (readonly,copy) NSString *deliveryCharge;
@property (readonly,copy) NSString *subtotal;
@property (readonly,copy) NSString *totalClubcardPoints;
@property (readonly,copy) NSString *totalPromotionalPoints;

@property (readonly,copy) NSArray *cardholderAddressAliases;
@property (readonly,copy) NSString *telephoneNumber;
@property (readonly,copy) NSString *alternativeTelephoneNumber;
@property (readonly,copy) NSString *mobileNumber;

- (id)initWithDeliveryAddressInfo: (AddressInfo)inDeliveryAddressInfo andDeliveryDateHTML:(NSString*)inDeliveryDateHTML 
			andTotalSavings:(NSString*)inTotalSavings andTotalItems:(NSString*)inTotalItems 
			andDeliveryCharge:(NSString*)inDeliveryCharge andSubtotal:(NSString*)inSubtotal
			andTotalClubcardPoints:(NSString*)inTotalClubcardPoints andTotalPromotionalPoints:(NSString*)inTotalPromotionalPoints
			andCardholderAddressAliases:(NSArray*)inCardholderAddressAliases andTelephoneNumber:(NSString*)inTelephoneNumber
			andAlternativeTelephoneNumber:(NSString*)inAlternativeTelephoneNumber andMobileNumber:(NSString*)inMobileNumber;

@end
