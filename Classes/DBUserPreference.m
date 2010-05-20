//
//  UserPreference.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "UserPreference.h"


@implementation DBUserPreference

@synthesize key,value;

- (id)initWithKey: (NSString*)inKey andValue: (NSString*)inValue {
	if (self = [super init]) {
		key = inKey;
		value = inValue;
	}
	return self;
}

- (void) dealloc {
	[key release];
	[value release];
	[super dealloc];
}

@end
