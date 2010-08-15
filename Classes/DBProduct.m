//
//  DBProduct.m
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "DBProduct.h"

@interface DBProduct ()
@property (readwrite,copy) NSNumber *productID;
@property (readwrite,copy) NSString *productName;
@property (readwrite,copy) NSString *productPrice;
@property (readwrite,copy) NSString *productOffer;
@property (readwrite,copy) UIImage *productIcon;
@property (readwrite,copy) UIImage *productOfferIcon;
@property (readwrite,copy) NSDate *lastUpdated;
@property (readwrite,assign) BOOL userAdded;
@end

@implementation DBProduct

@synthesize productID,productName,productPrice,productOffer,productIcon,productOfferIcon,lastUpdated,userAdded;


- (BOOL)isEqual:(id)anObject{
	if (![anObject isKindOfClass:[DBProduct class]]) return NO;
	
	return [[anObject productID]intValue] == [productID intValue];
}

- (NSUInteger)hash{
	return [productID intValue];
}

-(id) copyWithZone: (NSZone *) zone{
	DBProduct *productCopy = [[DBProduct allocWithZone:zone] initWithProductID:productID andProductName:productName
															   andProductPrice:productPrice andProductOffer:productOffer
																andProductIcon:productIcon andProductOfferIcon:productOfferIcon andLastUpdated:lastUpdated 
																  andUserAdded:userAdded];
	return productCopy;	
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Product:\nID=%@\nName=%@\nPrice=%@\nLastUpdated=%@\nUserAdded=%d\n",productID,productName,productPrice,lastUpdated,userAdded];
}

- (id)initWithProductID: (NSNumber*)inProductID andProductName:(NSString*)inProductName 
		andProductPrice:(NSString*)inProductPrice andProductOffer:(NSString*)inProductOffer
		 andProductIcon:(UIImage*)inProductIcon andProductOfferIcon:(UIImage *)inProductOfferIcon andLastUpdated:(NSDate*)inLastUpdated 
		   andUserAdded:(BOOL)inUserAdded{
	
	if (self = [super init]) {
		[self setProductID:inProductID];
		[self setProductName:inProductName];
		[self setProductPrice:inProductPrice];
		[self setProductOffer:inProductOffer];
		[self setProductIcon:inProductIcon];
		[self setProductOfferIcon:inProductOfferIcon];
		[self setLastUpdated:inLastUpdated];
		[self setUserAdded:inUserAdded];
	}
	return self;
	
}

- (void)dealloc {
	[productID release];
	[productName release];
	[productPrice release];
	[productOffer release];
	[productIcon release];
	[productOfferIcon release];
	[lastUpdated release];
	[super dealloc];
}


@end
