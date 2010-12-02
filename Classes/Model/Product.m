//
//  Product.m
//  RecipeShopper
//
//  Created by Simon Barnett on 07/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "Product.h"

@implementation Product

@synthesize productID;
@synthesize productBaseID;
@synthesize productName;
@synthesize productPrice;
@synthesize productOffer;
@synthesize productOfferValidity;
@synthesize productImage;
@synthesize productOfferImage;
@synthesize productFetchedOffline;

//Fields used for fetching data JIT
@synthesize productOfferImageURL;
@synthesize productImageURL;

- (BOOL)isEqual:(id)anObject {
	if (![anObject isKindOfClass:[Product class]]) return NO;
	
	return [[anObject productBaseID] intValue] == [productBaseID intValue];
}

- (NSUInteger)hash {
	return [productBaseID intValue];
}

- (id)copyWithZone:(NSZone *)zone {
	return [[Product allocWithZone:zone] initWithProductBaseID:productBaseID andProductID:productID andProductName:productName
											   andProductPrice:productPrice andProductOffer:productOffer
									   andProductOfferValidity:productOfferValidity andProductImage:productImage 
										  andProductOfferImage:productOfferImage andProductFetchedOffline:productFetchedOffline];
}

- (id)initWithProductBaseID:(NSNumber *)inProductBaseID andProductID:(NSNumber *)inProductID andProductName:(NSString *)inProductName 
			andProductPrice:(NSString *)inProductPrice andProductOffer:(NSString *)inProductOffer
	andProductOfferValidity:(NSString *)inProductOfferValidity andProductImage:(UIImage *)inProductImage 
	   andProductOfferImage:(UIImage *)inProductOfferImage andProductFetchedOffline:(BOOL)inProductFetchedOffline {
	if (self = [super init]) {
		[self setProductBaseID:inProductBaseID];
		[self setProductID:inProductID];
		[self setProductName:inProductName];
		[self setProductPrice:inProductPrice];
		[self setProductOffer:inProductOffer];
		[self setProductOfferValidity:inProductOfferValidity];
		[self setProductImage:inProductImage];
		[self setProductOfferImage:inProductOfferImage];
		[self setProductFetchedOffline:inProductFetchedOffline];
	}
	
	return self;
}

- (void)dealloc {
	[productBaseID release];
	[productID release];
	[productName release];
	[productPrice release];
	[productOffer release];
	[productOfferValidity release];
	[productImage release];
	[productOfferImage release];
	[super dealloc];
}

@end
