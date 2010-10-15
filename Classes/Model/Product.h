//
//  Product.h
//  RecipeShopper
//
//  Created by Simon Barnett on 07/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject {
	
}

@property (nonatomic, retain) NSNumber *productBaseID;
@property (nonatomic, retain) NSNumber *productID;
@property (nonatomic, retain) NSString *productName;
@property (nonatomic, retain) NSString *productPrice;
@property (nonatomic, retain) NSString *productOffer;
@property (nonatomic, retain) UIImage *productImage;
@property (nonatomic, retain) UIImage *productOfferImage;

- (id)initWithProductBaseID:(NSNumber *)inProductBaseID andProductID:(NSNumber *)productID andProductName:(NSString *)inProductName 
		andProductPrice:(NSString *)inProductPrice andProductOffer:(NSString *)inProductOffer
		andProductImage:(UIImage *)inProductImage andProductOfferImage:(UIImage *)inProductOfferImage;

@end
