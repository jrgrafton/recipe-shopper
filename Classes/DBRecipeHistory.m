//
//  RecipeHistory.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "RecipeHistory.h"


@implementation DBRecipeHistory

@synthesize recipeID,dateTime;

- (id)initWithRecipeID: (NSString*)inRecipeID andDateTime:(NSDate*)inDateTime {
	if (self = [super init]) {
		recipeID = inRecipeID;
		dateTime = inDateTime;
	}
	return self;
}

- (void) dealloc {
	[recipeID release];
	[dateTime release];
	[super dealloc];
}

@end
