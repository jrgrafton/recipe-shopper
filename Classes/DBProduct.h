//
//  DBProduct.h
//  RecipeShopper
//
//  Created by James Grafton on 6/15/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DBProduct : NSObject {
	NSNumber *productID;
	NSString *productName;
	NSString *productPrice;
	NSString *productOffer;
	UIImage *productIcon;
	UIImage *productOfferIcon;
	NSDate *lastUpdated;
	BOOL userAdded;
}

@property (readonly,copy) NSNumber *productID;
@property (readonly,copy) NSString *productName;
@property (readonly,copy) NSString *productPrice;
@property (readonly,copy) NSString *productOffer;
@property (readonly,copy) UIImage *productIcon;
@property (readonly,copy) UIImage *productOfferIcon;
@property (readonly,copy) NSDate *lastUpdated;
@property (readonly,assign) BOOL userAdded;

//So we can be stored in NSDictionary
- (BOOL)isEqual:(id)anObject;
- (NSUInteger)hash;
-(id) copyWithZone: (NSZone *) zone;

- (id)initWithProductID: (NSNumber*)inProductID andProductName:(NSString*)inProductName 
		andProductPrice:(NSString*)inProductPrice andProductOffer:(NSString*)inProductOffer
		 andProductIcon:(UIImage*)inProductIcon andProductOfferIcon:(UIImage *)inProductOfferIcon andLastUpdated:(NSDate*)inLastUpdated 
		   andUserAdded:(BOOL)inUserAdded; 
@end
