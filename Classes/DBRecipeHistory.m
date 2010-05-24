//
//  RecipeHistory.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "DBRecipeHistory.h"

@interface DBRecipeHistory ()
	@property (readwrite,copy) NSString *recipeID;
	@property (readwrite,copy) NSDate *dateTime;
@end

@implementation DBRecipeHistory

@synthesize recipeID,dateTime;

- (id)initWithRecipeID: (NSString*)inRecipeID andDateTime:(NSDate*)inDateTime {
	if (self = [super init]) {
		[self setRecipeID:inRecipeID];
		[self setDateTime:inDateTime];
	}
	return self;
}

- (void)dealloc {
	[recipeID release];
	[dateTime release];
	[super dealloc];
}

@end
