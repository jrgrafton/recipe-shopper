//
//  Recipe.h
//  RecipeShopper
//
//  Created by Simon Barnett on 07/09/2010.
//  Copyright 2010 Assentec. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Recipe : NSObject {

}

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
@property (readwrite,copy) UIImage *smallRecipeImage;
@property (readwrite,copy) NSString *largeRecipeImageRaw;
@property (readwrite,copy) UIImage *largeRecipeImage;

@property (readwrite,copy) NSDictionary *recipeProducts;
@property (readwrite,copy) NSArray *textIngredients;
@property (readwrite,copy) NSArray *instructions;
@property (readwrite,copy) NSArray *nutritionalInfo;
@property (readwrite,copy) NSArray *nutritionalInfoPercent;

- (id)initWithRecipeID:(NSNumber *)inRecipeID andRecipeName:(NSString *)inRecipeName 
	   andCategoryName:(NSString *)inCategoryName andRecipeDescription:(NSString *)inRecipeDescription 
			 andRating:(NSNumber *)inRating andRatingCount:(NSInteger)inRatingCount 
		andContributor:(NSString *)inContributor andCookingTime:(NSString *)inCookingTime 
	andPreparationTime:(NSString *)inPreparationTime andServes:(NSString *)inServes 
   andSmallRecipeImage:(UIImage *)inSmallRecipeImage andLargeRecipeImageRaw:(NSString *)inLargeRecipeImageRaw
   andLargeRecipeImage:(UIImage *)inLargeRecipeImage;

- (id)initWithRecipeID:(NSNumber *)inRecipeID andRecipeName:(NSString *)inRecipeName 
	   andCategoryName:(NSString *)inCategoryName andRecipeDescription:(NSString *)inRecipeDescription 
			 andRating:(NSNumber *)inRating andRatingCount:(NSInteger)inRatingCount 
		andContributor:(NSString *)inContributor andCookingTime:(NSString *)inCookingTime 
	andPreparationTime:(NSString *)inPreparationTime andServes:(NSString *)inServes 
   andSmallRecipeImage:(UIImage *)inSmallRecipeImage andLargeRecipeImageRaw:(NSString *)inLargeRecipeImageRaw
   andLargeRecipeImage:(UIImage *)inLargeRecipeImage andRecipeProducts:(NSDictionary *)inRecipeProducts;

@end
