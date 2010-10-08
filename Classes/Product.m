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
@synthesize productImage;
@synthesize productOfferImage;

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
										   andProductImage:productImage andProductOfferImage:productOfferImage];
}

- (id)initWithProductBaseID:(NSNumber *)inProductBaseID andProductID:(NSNumber *)inProductID andProductName:(NSString *)inProductName 
		andProductPrice:(NSString *)inProductPrice andProductOffer:(NSString *)inProductOffer
		 andProductImage:(UIImage *)inProductImage andProductOfferImage:(UIImage *)inProductOfferImage {
	if (self = [super init]) {
		[self setProductBaseID:inProductBaseID];
		[self setProductID:inProductID];
		[self setProductName:inProductName];
		[self setProductPrice:inProductPrice];
		[self setProductOffer:inProductOffer];
		[self setProductImage:inProductImage];
		[self setProductOfferImage:inProductOfferImage];
	}
	
	return self;
}

- (void)dealloc {
	[productBaseID release];
	[productID release];
	[productName release];
	[productPrice release];
	[productOffer release];
	[productImage release];
	[productOfferImage release];
	[super dealloc];
}

@end
