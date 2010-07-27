//
//  Recipe.m
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import "DBRecipe.h"

@interface DBRecipe ()
	// Note: no need to redeclare just in time properties here
	@property (readwrite,copy) NSNumber *recipeID;
	@property (readwrite,copy) NSString *recipeName;
	@property (readwrite,copy) NSString *categoryName;
	@property (readwrite,copy) NSString *recipeDescription;
	@property (readwrite,copy) NSNumber *rating;
	@property (readwrite,assign) NSInteger ratingCount;
	@property (readwrite,copy) NSString *contributor;
	@property (readwrite,copy) NSString *cookingTime;
	@property (readwrite,copy) NSString *preparationTime;
	@property (readwrite,copy) NSString *serves;
	@property (readwrite,copy) UIImage *iconSmall;
	@property (readwrite,copy) NSString *iconLargeRaw;
@end

@implementation DBRecipe

@synthesize recipeID,recipeName,categoryName,recipeDescription,instructions,
rating,ratingCount,contributor,cookingTime,preparationTime,serves,
textIngredients,idProducts,idProductsQuantity,nutritionalInfo,nutritionalInfoPercent,iconSmall,iconLargeRaw;

- (id)initWithRecipeID: (NSNumber*)inRecipeID andRecipeName:(NSString*)inRecipeName 
		andCategoryName:(NSString*)inCategoryName andRecipeDescription:(NSString*)inRecipeDescription 
		andInstructions:(NSArray*)inInstructions andRating:(NSNumber*)inRating 
	    andRatingCount:(NSInteger)inRatingCount andContributor:(NSString*)inContributor 
	    andCookingTime:(NSString*)inCookingTime andPreparationTime:(NSString*)inPreparationTime 
		andServes:(NSString*)inServes andTextIngredients:(NSArray*)inTextIngredients 
		andIDProducts:(NSArray*)inIDProducts andIDProductsQuantity:(NSArray*)inIDProductsQuantity
		andNutritionalInfo:(NSArray*)inNutritionalInfo andNutritionalInfoPercent:(NSArray*)inNutritionalInfoPercent 
		andIconSmall:(UIImage*)inIconSmall andIconLargeRaw:(NSString*)inIconLargeRaw {
	
	if (self = [super init]) {
		[self setRecipeID:inRecipeID];
		[self setRecipeName:inRecipeName];
		[self setCategoryName:inCategoryName];
		[self setRecipeDescription:inRecipeDescription];
		[self setInstructions:inInstructions];
		[self setRating:inRating];
		[self setRatingCount:inRatingCount];
		[self setContributor:inContributor];
		[self setCookingTime:inCookingTime];
		[self setPreparationTime:inPreparationTime];
		[self setServes:inServes];
		[self setTextIngredients:inTextIngredients];
		[self setIdProducts:inIDProducts];
		[self setIdProductsQuantity:inIDProductsQuantity];
		[self setNutritionalInfo:inNutritionalInfo];
		[self setNutritionalInfoPercent:inNutritionalInfoPercent];
		[self setIconSmall:inIconSmall];
		[self setIconLargeRaw:inIconLargeRaw];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"Recipe: ID=%@\nName=%@\nCategory=%@\nDescription=%@\nInstructions=%@\n"
									"Rating=%@\nRatingCount=%@\nContributor=%@\nCookingTime=%@\nPreparationTime=%@\n"
									"Serves=%@\nTextIngredients=%@\nIdProducts=%@\nIdProductsQuantity=%@\n"
									"NutritionalInfo=%@\nNutritionalInfoPercent=%@\n",
									recipeID,recipeName,categoryName,recipeDescription,instructions,rating,ratingCount,
									contributor,cookingTime,preparationTime,serves,textIngredients,idProducts,
									idProductsQuantity,nutritionalInfo,nutritionalInfoPercent];
}

- (void)dealloc {
	[recipeID release];
	[recipeName release];
	[categoryName release];
	[recipeDescription release];
	[instructions release];
	[rating release];
	[contributor release];
	[cookingTime release];
	[preparationTime release];
	[serves release];
	[textIngredients release];
	[idProducts release];
	[idProductsQuantity release];
	[nutritionalInfo release];
	[nutritionalInfoPercent release];
	[iconSmall release];
	[iconLargeRaw release];
	[super dealloc];
}

@end
