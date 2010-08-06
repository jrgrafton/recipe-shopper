//
//  APIPaymentManager.m
//  RecipeShopper
//
//  Created by User on 8/6/10.
//  Copyright 2010 Assentec Global. All rights reserved.
//

#import "APIPaymentManager.h"


@implementation APIPaymentManager

- (id)init {
	if (self = [super init]) {
		//Initialisation code
		NSURL *tescoUrl = [NSURL URLWithString:@"http://www.tesco.com/superstore/"];
		NSURLRequest *tescoDotComRequest = [NSURLRequest requestWithURL:tescoUrl];
		urlConnection = [[urlConnection alloc] initWithRequest:tescoDotComRequest delegate:self];
	}
	return self;
}

@end
