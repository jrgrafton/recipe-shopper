//
//  Recipe.m
//  RecipeShopper
//
//  Created by Simon Barnett on 07/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import "Recipe.h"

@implementation Recipe

@synthesize recipeID;
@synthesize recipeName;
@synthesize categoryName;
@synthesize recipeDescription;
@synthesize rating;
@synthesize ratingCount;
@synthesize contributor;
@synthesize cookingTime;
@synthesize preparationTime;
@synthesize serves;
@synthesize smallRecipeImage;
@synthesize largeRecipeImageRaw;
@synthesize largeRecipeImage;

/* extra recipe info */
@synthesize recipeProducts;
@synthesize textIngredients;
@synthesize instructions;
@synthesize nutritionalInfo;
@synthesize nutritionalInfoPercent;

- (BOOL)isEqual:(id)anObject {
	if (![anObject isKindOfClass:[Recipe class]]) return NO;
	
	return [[anObject recipeID] intValue] == [recipeID intValue];
}

- (NSUInteger)hash {
	return [recipeID intValue];
}

- (id)copyWithZone:(NSZone *)zone {
	return [[Recipe allocWithZone:zone] initWithRecipeID:(NSNumber *)recipeID andRecipeName:(NSString *)recipeName 
										  andCategoryName:(NSString *)categoryName andRecipeDescription:(NSString *)recipeDescription 
												andRating:(NSNumber *)rating andRatingCount:(NSInteger)ratingCount 
										   andContributor:(NSString *)contributor andCookingTime:(NSString *)cookingTime 
									   andPreparationTime:(NSString *)preparationTime andServes:(NSString *)serves 
									  andSmallRecipeImage:(UIImage *)smallRecipeImage andLargeRecipeImageRaw:(NSString *)largeRecipeImageRaw
									 andLargeRecipeImage:(UIImage *)largeRecipeImage andRecipeProducts:(NSDictionary *)recipeProducts];
}

- (id)initWithRecipeID:(NSNumber *)inRecipeID andRecipeName:(NSString *)inRecipeName 
	   andCategoryName:(NSString *)inCategoryName andRecipeDescription:(NSString *)inRecipeDescription 
	   andRating:(NSNumber *)inRating andRatingCount:(NSInteger)inRatingCount 
		andContributor:(NSString *)inContributor andCookingTime:(NSString *)inCookingTime 
	andPreparationTime:(NSString *)inPreparationTime andServes:(NSString *)inServes 
   andSmallRecipeImage:(UIImage *)inSmallRecipeImage andLargeRecipeImageRaw:(NSString *)inLargeRecipeImageRaw
   andLargeRecipeImage:(UIImage *)inLargeRecipeImage {
	if (self = [super init]) {
		[self setRecipeID:inRecipeID];
		[self setRecipeName:inRecipeName];
		[self setCategoryName:inCategoryName];
		[self setRecipeDescription:inRecipeDescription];
		[self setRating:inRating];
		[self setRatingCount:inRatingCount];
		[self setContributor:inContributor];
		[self setCookingTime:inCookingTime];
		[self setPreparationTime:inPreparationTime];
		[self setServes:inServes];
		[self setSmallRecipeImage:inSmallRecipeImage];
		[self setLargeRecipeImageRaw:inLargeRecipeImageRaw];
		[self setLargeRecipeImage:inLargeRecipeImage];
	}
	
	return self;
}

- (id)initWithRecipeID:(NSNumber *)inRecipeID andRecipeName:(NSString *)inRecipeName 
	   andCategoryName:(NSString *)inCategoryName andRecipeDescription:(NSString *)inRecipeDescription 
			 andRating:(NSNumber *)inRating andRatingCount:(NSInteger)inRatingCount 
		andContributor:(NSString *)inContributor andCookingTime:(NSString *)inCookingTime 
	andPreparationTime:(NSString *)inPreparationTime andServes:(NSString *)inServes 
   andSmallRecipeImage:(UIImage *)inSmallRecipeImage andLargeRecipeImageRaw:(NSString *)inLargeRecipeImageRaw
   andLargeRecipeImage:(UIImage *)inLargeRecipeImage andRecipeProducts:(NSDictionary *)inRecipeProducts {
	if (self = [super init]) {
		[self setRecipeID:inRecipeID];
		[self setRecipeName:inRecipeName];
		[self setCategoryName:inCategoryName];
		[self setRecipeDescription:inRecipeDescription];
		[self setRating:inRating];
		[self setRatingCount:inRatingCount];
		[self setContributor:inContributor];
		[self setCookingTime:inCookingTime];
		[self setPreparationTime:inPreparationTime];
		[self setServes:inServes];
		[self setSmallRecipeImage:inSmallRecipeImage];
		[self setLargeRecipeImageRaw:inLargeRecipeImageRaw];
		[self setLargeRecipeImage:inLargeRecipeImage];
		[self setRecipeProducts:inRecipeProducts];
	}
	
	return self;
}

- (void)dealloc {
	[recipeID release];
	[recipeName release];
	[categoryName release];
	[recipeDescription release];
	[rating release];
	[contributor release];
	[cookingTime release];
	[preparationTime release];
	[serves release];
	[smallRecipeImage release];
	[largeRecipeImageRaw release];
	[largeRecipeImage release];
	
	[recipeProducts release];
	[textIngredients release];
	[instructions release];
	[nutritionalInfo release];
	[nutritionalInfoPercent release];
	
	[super dealloc];
}

@end
