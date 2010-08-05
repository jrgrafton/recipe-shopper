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
@property (readwrite,copy) NSNumber *productBaseID;
@property (readwrite,copy) NSString *productName;
@property (readwrite,copy) NSString *productPrice;
@property (readwrite,copy) UIImage *productIcon;
@property (readwrite,copy) NSDate *lastUpdated;
@property (readwrite,assign) BOOL userAdded;
@end

@implementation DBProduct

@synthesize productID,productBaseID,productName,productPrice,productIcon,lastUpdated,userAdded;


- (BOOL)isEqual:(id)anObject{
	if (![anObject isKindOfClass:[DBProduct class]]) return NO;
	
	return [[anObject productBaseID]intValue] == [productBaseID intValue];
}

- (NSUInteger)hash{
	return [productBaseID intValue];
}

-(id) copyWithZone: (NSZone *) zone{
	DBProduct *productCopy = [[DBProduct allocWithZone:zone] initWithProductID:productID andProductBaseID:productBaseID andProductName:productName
														  andProductPrice:productPrice andProductIcon:productIcon
														   andLastUpdated:lastUpdated andUserAdded:userAdded];
	return productCopy;	
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Product:\nID=%@\nBaseID=%@\nName=%@\nPrice=%@\nLastUpdated=%@\nUserAdded=%d\n",productID,productBaseID,productName,productPrice,lastUpdated,userAdded];
}

- (id)initWithProductID: (NSNumber*)inProductID andProductBaseID:(NSNumber*)inProductBaseID 
		 andProductName:(NSString*)inProductName andProductPrice:(NSString*)inProductPrice
		 andProductIcon:(UIImage*)inProductIcon andLastUpdated:(NSDate*)inLastUpdated
		   andUserAdded:(BOOL)inUserAdded {
	
	if (self = [super init]) {
		[self setProductID:inProductID];
		[self setProductBaseID:inProductBaseID];
		[self setProductName:inProductName];
		[self setProductPrice:inProductPrice];
		[self setProductIcon:inProductIcon];
		[self setLastUpdated:inLastUpdated];
		[self setUserAdded:inUserAdded];
	}
	return self;
	
}

- (void)dealloc {
	[productID release];
	[productBaseID release];
	[productName release];
	[productPrice release];
	[productIcon release];
	[lastUpdated release];
	[super dealloc];
}


@end
