//
//  APIPaymentManager.h
//  RecipeShopper
//
//  Created by User on 8/6/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APIPaymentManager : NSObject {

	@private
	NSURLConnection *urlConnection;	//Used to do all navigation
	NSMutableData *receivedData;
}

- (void)navigateToPaymentPage;

- (id)init;

@end
