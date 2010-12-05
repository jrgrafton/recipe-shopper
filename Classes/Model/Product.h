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
@property (nonatomic) BOOL productFetchedOffline;
@property (nonatomic, retain) NSURL *productImageURL;

/* These may have concurrent read/write access */
@property (retain) UIImage *productImage;
@property (retain) UIImage *productOfferImage;
@property (retain) NSString *productOffer;
@property (retain) NSString *productOfferValidity;
@property (retain) NSURL *productOfferImageURL;

- (id)initWithProductBaseID:(NSNumber *)inProductBaseID andProductID:(NSNumber *)productID andProductName:(NSString *)inProductName 
			andProductPrice:(NSString *)inProductPrice andProductOffer:(NSString *)inProductOffer
	andProductOfferValidity:(NSString *)inProductOfferValidity andProductImage:(UIImage *)inProductImage 
	   andProductOfferImage:(UIImage *)inProductOfferImage andProductFetchedOffline:(BOOL)productFetchedOffline;

- (void)removeProductOffer;

@end
