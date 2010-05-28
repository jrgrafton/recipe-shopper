//
//  Recipe.h
//  RecipeShopper
//
//  Created by James Grafton on 5/20/10.
//  Copyright 2010 Asset Enhancing Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImage-Extended.h"

@interface DBRecipe : NSObject {
	NSInteger recipeID;
	NSString *recipeName;
	NSString *categoryName;
	NSString *description;
	NSArray *instructions;
	NSNumber *rating;
	NSInteger ratingCount;
	NSString *contributor;
	NSString *cookingTime;
	NSString *preparationTime;
	NSString *serves;
	NSArray *textIngredients;
	NSArray *idProducts;
	NSArray *idProductsQuantity;
	NSArray *nutritionalInfo;
	NSArray *nutritionalInfoPercent;
	UIImage *iconSmall;	
	NSString *iconLargeRaw;	//Base64 encoded image
}

@property (readonly,assign) NSInteger recipeID;
@property (readonly,copy) NSString *recipeName;
@property (readonly,copy) NSString *categoryName;
@property (readonly,copy) NSString *description;
@property (readonly,copy) NSArray *instructions;
@property (readonly,copy) NSNumber *rating;
@property (readonly,assign) NSInteger ratingCount;
@property (readonly,copy) NSString *contributor;
@property (readonly,copy) NSString *cookingTime;
@property (readonly,copy) NSString *preparationTime;
@property (readonly,copy) NSString *serves;
@property (readonly,copy) NSArray *textIngredients;
@property (readonly,copy) NSArray *idProducts;
@property (readonly,copy) NSArray *idProductsQuantity;
@property (readonly,copy) NSArray *nutritionalInfo;
@property (readonly,copy) NSArray *nutritionalInfoPercent;
@property (readonly,copy) UIImage *iconSmall;
@property (readonly,copy) NSString *iconLargeRaw;

- (id)initWithRecipeID: (NSInteger)inRecipeID andRecipeName:(NSString*)inRecipeName 
	  andCategoryName:(NSString*)inCategoryName andDescription:(NSString*)inDescription 
	  andInstructions:(NSArray*)inInstructions andRating:(NSNumber*)inRating 
	  andRatingCount:(NSInteger)inRatingCount andContributor:(NSString*)inContributor 
	  andCookingTime:(NSString*)inCookingTime andPreparationTime:(NSString*)inPreparationTime 
	  andServes:(NSString*)inServes andTextIngredients:(NSArray*)inTextIngredients 
	  andIDProducts:(NSArray*)inIDProducts andIDProductsQuantity:(NSArray*)inIDProductsQuantity
	  andNutritionalInfo:(NSArray*)inNutritionalInfo andNutritionalInfoPercent:(NSArray*)inNutritionalInfoPercent 
	  andIconSmall:(UIImage*)inIconSmall andIconLargeRaw:(NSString*)inIconLargeRaw;
@end
